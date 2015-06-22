assimilate = require '../services/assimilate'

bcrypt = require 'bcrypt'
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


User.pre 'save', (next) ->
    @updatedAt = new Date()
    if @isNew
        @createdAt = @updatedAt

    if /^\$[a-z0-9]{2}\$[a-z0-9]{2}\$[a-z0-9\.\/]{53}$/i.test(@password)
        # password looks already hashed; if you want to use that format for your password, too bad!
        next()
    else
        # password looks brand new, hash it
        bcrypt.hash @password, 10, (err, hash) =>
            if not err
                @password = hash
            next(err)


User.method 'authenticate', (password, next) ->
    # compares `password` with the password stored in the model and calls `next` with true if they
    # match, otherwise false
    bcrypt.compare(password, @password, next)


User.method 'jsonify', ->
    # Returns a json-serializable representation of a user, but with all sensitive information
    # stripped out
    return {
        'email': @email
        'name': @name
    }


module.exports = Model = assimilate mongoose.model('User', User)
