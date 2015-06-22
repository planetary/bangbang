assimilate = require '../services/assimilate'

mongoose = require 'mongoose'


Profile = mongoose.Schema({
    'slug':
        'type': String
        'required': true
        'lowercase': true
        'unique': true
        'minlength': 4
        'maxlength': 100
        'match': /^[a-z0-9\-\.]+$/

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


Profile.pre 'save', (next) ->
    @updatedAt = new Date()
    if @isNew
        @createdAt = @updatedAt
    next()


module.exports = Model = assimilate mongoose.model('Profile', Profile)
