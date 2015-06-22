assimilate = require '../services/assimilate'
capture = require '../services/capture'
config = require '../config'
Profile = require './Profile'

aws = require 'aws-sdk'
Promise = require 'bluebird'
crypto = require 'crypto'
mongoose = require 'mongoose'
url = require 'url'


s3 = new aws.S3(
    'apiVersion': '2006-03-01'
    'region': config.aws.region
)


Screenshot = mongoose.Schema({
    'project':
        # the project this group of screenshots belongs to
        'type': mongoose.Schema.Types.ObjectId
        'ref': 'Project'
        'required': true

    'build':
        # the build this group of screenshots were taken in
        'type': Number
        'required': true

    'slug':
        # the name of this group of screenshots; if not set, the sha1 of `target` will be used
        'type': String
        'validate': [
            'type': 'base64'
            'validator': (val) -> val.match(/^[a-z0-9\-\.]+$/)
            'msg': 'Slugs must be lowercase and URL friendly'

            'type': 'alpha'
            'validator': (val) -> val.match(/[^0-9]$/)
            'msg': 'Slugs must contain at least one non-numeric character'
        ]

    'target':
        # the URL of the page that is rendered in this group of screenshots
        'type': String
        'required': true
        'validate':
            'type': 'loopback'
            'validator': (val) ->
                # this is a bit of a joke, but may prevent some rather common mistakes
                pieces = url.parse(val)
                if pieces.protocol not in ['http:', 'https:']
                    return false

                if pieces.hostname in ['localhost', '127.0.0.1', '[127.0.0.1]'
                                       '[::ffff:127.0.0.1]', '[::1]']
                    return false

                true
            'msg': 'Only valid non-loopback HTTP(S) urls are supported'

    'delay':
        # the amount of time given to the site to finish rendering before snapping screenshots in
        # this group, in milliseconds.
        'type': Number
        'required': true
        'min': 0
        'max': 5000

    'format':
        # the format the screenshots in this group were saved in
        'type': String
        'required': true
        'enum': ['png', 'gif', 'jpeg']

    # api-specified metadata, if any
    'meta': mongoose.Schema.Types.Mixed

    # all the profiles available for this screenshot
    'profiles':
        'required': true
        'type': [
            # Will either be the name of the profile, or the sha1 hash of width + height + agent
            'slug':
                'type': String
                'lowercase': true
                'minlength': 4
                'maxlength': 100
                'match': /^[a-z0-9\-\.]+$/

            # the width of the viewport this screenshot was rendered on, in pixels. Note that this
            # is a hint; the actual screenshot width may be larger if the site does not scale and
            # creates a horizontal scrollbar (in general, you want to fix such things as horizontal
            # scrollbars cause a bad user experience)
            'width':
                'type': Number
                'required': true
                'min': 128

            # the height of the viewport this screenshot was rendered on, in pixels. Note that this
            # is a hint; the actual output width may be larger if the site does not scale correctly
            # and creates a horizontal scrollbar (in general, you want to fix such things as
            # horizontal scrollbars cause a bad user experience)
            'height':
                'type': Number
                'required': true
                'min': 128

            # the user agent used to generate this screenshot (may be undefined / null if the
            # default was used)
            'agent': String

            # say no to ObjectIds!
            '_id': false
        ]
        'validate':
            'type': 'unique'
            'validator': (values, next) ->
                profiles = Object.create(null)
                for value in values
                    if profiles[value.slug]
                        return next(false)

                next(true)

    'createdAt': Date
    'updatedAt': Date
})


Screenshot.method 'key', (profile) ->
    if typeof profile is 'object'
        profile = profile.slug
    "#{@project.toString()}-#{@build}-#{@slug}-#{profile}"


Screenshot.method 'jsonify', (extra={}) ->
    # Returns a json-serializable representation of a screenshot, but with all sensitive
    # information stripped out, optionally appending `extra` to the result
    return extend(
        'slug': @slug
        'target': @target
        'delay': @delay
        'format': @format
        'meta': @meta
        'profiles': {
            'slug': profile.slug
            'width': profile.width
            'height': profile.height
            'agent': profile.agent
            'url': @serve(profile)
        } for profile in @profiles
        'createdAt': @createdAt
        'updatedAt': @updatedAt
    , extra)


Screenshot.method 'serve', (profile) ->
    "https://#{config.aws.bucket}.s3.amazonaws.com/#{@key(profile)}"


Screenshot.pre 'validate', (next) ->
    if not (@profiles? or @profiles.length)
        return next()  # shortcircuit

    Profile.findAsync({})
    .then (builtinProfiles) =>
        # matches requested profiles against builtin profiles:
        # * if the requested profile has a slug that matches the slug of a builtin profile, then
        #   any other requested properties are discarded in favor of the builtin profile's settings
        # * if the requested profile's settings match the settings of a builtin profile, its slug
        #   is updated to the slug of the matching builtin profile
        # * in every other case, the slug is generated by hashing the profile settings; NOTE THAT
        #   IN THIS CASE, BOTH WIDTH AND HEIGHT MUST BE SPECIFIED!
        for profile in @profiles
            matched = false
            for builtinProfile in builtinProfiles
                if profile.slug is builtinProfile.slug or (
                    profile.width is builtinProfile.width and
                    profile.height is builtinProfile.height and
                    profile.agent is builtinProfile.agent
                )
                    profile.slug = builtinProfile.slug
                    profile.width = builtinProfile.width
                    profile.agent = builtinProfile.agent
                    matched = true

            if not matched
                # auto-generate profile id if not present or invalid
                hash = crypto.createHash('sha1')
                hash.update([
                    profile.width
                    profile.height
                    profile.agent or ''
                ].join(''))

                profile.slug = hash.digest('base64')
                    .replace('+', '-')
                    .replace('/', '.')
                    .substring(0, 8)

        next()


Screenshot.pre 'save', (next) ->
    @updatedAt = new Date()
    if @isNew
        @createdAt = @updatedAt

    if not @slug
        # if not present, auto-generate slug from the target url
        hash = crypto.createHash('sha1')
        hash.update(@target)
        @slug = hash.digest('base64').replace('+', '-').replace('/', '.')
            .toLowerCase()
            .substring(0, 8)

        if @slug.match(/^[0-9]+$/)
            # one in a million chance; avoid collision with build numbers
            @slug = @slug.substring(0, 4) + '-' + @slug.substring(4)

    # create and wait for screenshot capture tasks for every registered profile
    requests = []
    for profile in @profiles
        request =
            'key': @key(profile)
            'target': @target
            'width': profile.width
            'agent': profile.agent
            'delay': @delay
            'format': @format
        requests.push(capture(request))

    Promise.all(requests)
    .then -> next()
    .catch (err) -> next(err)


Screenshot.pre 'delete', (next) ->
    s3.deleteObjects({
        'Bucket': config.aws.bucket
        'Delete':
            'Objects': [{
                'Key': @key(profile)
            } for profile in @profiles]
    }, next)


Screenshot.index({'project': 1, 'slug': 1, 'build': 1}, {'unique': true})
Screenshot.index({'project': 1, 'profiles.slug': 1})


module.exports = Model = assimilate mongoose.model('Screenshot', Screenshot)
