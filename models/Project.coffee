assimilate = require '../services/assimilate'
Build = require './Build'

extend = require 'deep-extend'
mongoose = require 'mongoose'
uuid = require 'uuid'


Project = mongoose.Schema({
    'name':
        'type': String
        'required': true
        'maxlength': 100

    'slug':
        'type': String
        'unique': true
        'lowercase': true
        'maxlength': 100

    'key':
        # API key for this project
        'type': String

    'head':
        # the most recent build number
        'type': Number
        'default': 0

    # api specified metadata, if any
    'meta': mongoose.Schema.Types.Mixed

    'createdAt': Date
    'updatedAt': Date
})


Project.method 'jsonify', (extra={}) ->
    # Returns a json-serializable representation of a profile, but with all sensitive information
    # stripped out, optionally appending `extra` to the result
    return extend(
        'name': @name
        'slug': @slug
        'meta': @meta
        'createdAt': @createdAt
        'updatedAt': @updatedAt
    , extra)


Project.method 'regenerate', ->
    # generates a new API key
    @key = @key = uuid.v4().replace(/-/g, '')


Project.pre 'save', (next) ->
    @updatedAt = new Date()
    if @isNew
        @createdAt = @updatedAt
        @regenerate()

    # if a slug was provided, use it as a starting point; else use the project's name as one
    # in both cases, convert to lowercase and remove any non-alphanum characters before continuing
    @slug = base = (if @slug then @slug else @name).toLowerCase().replace(/[^a-z0-9]+/g, '-')

    # enforce slug uniqueness by appending a unique suffix if the requested one already exists
    trySlug = (model) =>
        Model.findOneAsync('slug': @slug)
        .then (project) =>
            if project and project.id isnt @id
                # already exists; try a new random suffix
                rand = Math.floor(1679616 * Math.random())
                @slug = base + '-' + rand.toString(36)
                trySlug()

    trySlug()
    .then -> next()
    .catch (err) -> next(err)


Project.pre 'remove', (next) ->
    # delete all builds before deleting this project
    Build.findAsync('project': @id)
    .then (builds) ->
        build.removeAsync() for build in builds
    .spread ->
        next()
    .catch (err) ->
        next(err)


module.exports = Model = assimilate mongoose.model('Project', Project)
