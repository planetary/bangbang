assimilate = require '../services/assimilate'
config = require '../config'

bcrypt = require 'bcrypt'
extend = require 'deep-extend'
mongoose = require 'mongoose'


User = mongoose.Schema({
    'name':
        'type': String
        'required': true
        'match': /.+\s+.+/
        'maxlength': 100

    'email':
        'type': String
        'required': true
        'unique': true
        'lowercase': true
        'validate':
            'type': 'unique'
            'validator': (value, next) ->
                Model.findOne 'email': @email, (err, user) =>
                    next(not err? and (not user? or user.id is @id))

    'password':
        'type': String
        'minlength': 4
        'maxlength': 100
        'required': true

    'createdAt': Date
    'updatedAt': Date
})


User.method 'authenticate', (password, next) ->
    # compares `password` with the password stored in the model and calls `next` with true if they
    # match, otherwise false
    bcrypt.compare(password, @password, next)


User.method 'jsonify', (extra={}) ->
    # Returns a json-serializable representation of a user, but with all sensitive information
    # stripped out, optionally appending `extra` to the result
    return extend(
        'name': @name
        'email': @email
        'createdAt': @createdAt
        'updatedAt': @updatedAt
    , extra)


User.pre 'save', (next) ->
    @updatedAt = new Date()
    if @isNew
        @createdAt = @updatedAt

    if /^\$[a-z0-9]{2}\$[a-z0-9]{2}\$[a-z0-9\.\/]{53}$/i.test(@password)
        # password looks already hashed; if you want to use that format for your password, too bad!
        next()
    else
        # password looks brand new, hash it
        bcrypt.hash @password, config.server.salt, (err, hash) =>
            if not err
                @password = hash
            next(err)


module.exports = Model = assimilate mongoose.model('User', User)
