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
        'required': true
        'validate': [
            'validator': (val) -> val.match(/^[a-z0-9\-\.]+$/)
            'msg': 'Slugs must be lowercase and URL friendly'

            'validator': (val) -> val.match(/[^0-9]$/)
            'msg': 'Slugs must contain at least one non-numeric character'
        ]

    'target':
        # the URL of the page that is rendered in this group of screenshots
        'type': String
        'required': true
        'validate':
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

    # api specified metadata, if any
    'meta': mongoose.Schema.Types.Mixed

    # all the profiles available for this screenshot
    'profiles': [{
        'slug':
            # Either the name of the profile, or the sha1 hash of width + height + agent
            'type': String
            'required': true
            'validate':
                'validator': (val) -> val.match(/^[a-z0-9\-\.]+$/)
                'msg': 'Profiles must be lowercase and URL friendly'

        # the width of the viewport this screenshot was rendered on, in pixels. Note that this is a
        # hint; the actual screenshot width may be larger if the site does not scale and creates a
        # horizontal scrollbar (in general, you want to fix such things as horizontal scrollbars
        # cause a bad user experience)
        'width':
            'type': Number
            'required': true

        # the height of the viewport this screenshot was rendered on, in pixels. Note that this is
        # a hint; the actual output width may be larger if the site does not scale correctly and
        # creates a horizontal scrollbar (in general, you want to fix such things as horizontal
        # scrollbars cause a bad user experience)
        'height':
            'type': Number
            'required': true

        # the user agent used to generate this screenshot (may be undefined / null if the default
        # was used)
        'agent': String

        # say no to ObjectIds!
        '_id': false
    }]

    'createdAt': Date
    'updatedAt': Date
})


Screenshot.method 'key', (profile) ->
    if typeof profile is 'object'
        profile = profile.slug
    "#{@project.toString()}-#{@build}-#{@slug}-#{profile}"


Screenshot.method 'serve', (profile) ->
    "https://#{config.aws.bucket}.s3.amazonaws.com/#{@key(profile)}"


Screenshot.pre 'validate', (next) ->
    if not @isNew
        return next(new Error('Screenshots are immutable'))
    if not @target
        return next()  # will fail validation
    if not @profiles or not @profiles.length
        return next(new Error('Screenshots must have at least one profile'))

    if not @slug
        # auto generate slug if not present
        hash = crypto.createHash('sha1')
        hash.update(@target)
        @slug = hash.digest('base64').replace('+', '-').replace('/', '.')
            .toLowerCase()
            .substring(0, 8)

        if @slug.match(/^[0-9]+$/)
            # one in a million chance; avoid collision with build numbers
            @slug = @slug.substring(0, 4) + '-' + @slug.substring(4)


    Profile.findAsync({})
    .then (profiles) =>
        # move 'default' profile to the end of the profile list to prevent all unspecified named
        # profiles from matching 'default' if there's a better match
        defaultProfileIndex = -1
        builtinProfiles.some (profile, index) ->
            if not profile.width and not profile.agent
                defaultProfileIndex = index
                return true
        if defaultProfileIndex isnt -1
            [defaultProfile] = builtinProfiles.splice(defaultProfileIndex, 1)
            builtinProfiles.push(defaultProfile)

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
                    (profile.width or ''),
                    (profile.height or ''),
                    (profile.agent or '')
                ].join(''))

                profile.slug = hash.digest('base64')
                    .replace('+', '-')
                    .replace('/', '.')
                    .toLowerCase()
                    .substring(0, 8)

        next()


Screenshot.pre 'save', (next) ->
    @updatedAt = new Date()
    if @isNew
        @createdAt = @updatedAt

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


module.exports = Model = assimilate mongoose.model('Screenshot', Screenshot)
