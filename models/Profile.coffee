assimilate = require '../services/assimilate'

extend = require 'deep-extend'
mongoose = require 'mongoose'


Profile = mongoose.Schema({
    'slug':
        'type': String
        'required': true
        'unique': true
        'minlength': 2
        'maxlength': 100
        'lowercase': true
        'match': /^[a-z0-9\-\.]+$/
        'validate':
            'type': 'unique'
            'validator': (value, next) ->
                Model.findOne 'slug': @slug, (err, profile) =>
                    next(not err? and (not profile? or profile.id is @id))

    'width':
        'type': Number
        'required': true
        'min': 128

    'height':
        'type': Number
        'required': true
        'min': 128

    'agent':
        'type': String

    'createdAt': Date
    'updatedAt': Date
})


Profile.method 'jsonify', (extra={}) ->
    # Returns a json-serializable representation of a profile, but with all sensitive information
    # stripped out, optionally appending `extra` to the result
    return extend(
        'slug': @slug
        'width': @width
        'height': @height
        'agent': @agent
        'createdAt': @createdAt
        'updatedAt': @updatedAt
    , extra)


Profile.pre 'save', (next) ->
    @updatedAt = new Date()
    if @isNew
        @createdAt = @updatedAt
    next()


module.exports = Model = assimilate mongoose.model('Profile', Profile)
