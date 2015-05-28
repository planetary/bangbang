assimilate = require '../services/assimilate'

mongoose = require 'mongoose'


Profile = mongoose.Schema({
    'slug':
        'type': String
        'required': true
        'unique': true

    'width':
        'type': Number
        'required': true
    'height':
        'type': Number
        'required': true

    'agent': String

    'createdAt': Date
    'updatedAt': Date
})


Profile.pre 'save', (next) ->
    @updatedAt = new Date()
    if @isNew
        @createdAt = @updatedAt
    next()


module.exports = Model = assimilate mongoose.model('Profile', Profile)
