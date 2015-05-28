assimilate = require '../services/assimilate'
Build = require './Build'

mongoose = require 'mongoose'
uuid = require 'uuid'


Project = mongoose.Schema({
    'name':
        'type': String
        'required': true

    'slug':
        'type': String
        'required': true
        'unique': true

    'key':
        # API key for this project
        'type': String
        'required': true

    'head':
        # the most recent build number
        'type': Number
        'default': 0

    # api specified metadata, if any
    'meta': mongoose.Schema.Types.Mixed

    'createdAt': Date
    'updatedAt': Date
})


Project.pre 'validate', (next) ->
    if @isNew
        @regenerate()

    base = @name.toLowerCase().replace(/[^a-z0-9]+/g, '-')
    if not @slug
        @slug = base

    trySlug = (model) =>
        Model.findOneAsync(
            'slug': @slug
        )
        .then (project) =>
            if project and project.id isnt @id
                # already exists; generate a new suffix
                rand = Math.floor(1679616 * Math.random())
                @slug = base + '-' + rand.toString(36)
                trySlug()

    # enforce slug uniqueness
    trySlug()
    .then -> next()
    .catch (err) -> next(err)


Project.method 'regenerate', ->
    # generates a new API key
    @key = @key = uuid.v4().replace(/-/g, '')


Project.pre 'save', (next) ->
    @updatedAt = new Date()
    if @isNew
        @createdAt = @updatedAt
    next()


Project.pre 'remove', (next) ->
    # delete all builds before deleting this project
    Build.findAsync(
        'project': @id
    )
    .then (builds) ->
        build.removeAsync() for build in builds
    .spread ->
        next()
    .catch (err) ->
        next(err)


module.exports = Model = assimilate mongoose.model('Project', Project)
