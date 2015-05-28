assimilate = require '../services/assimilate'
Screenshot = require './Screenshot'

mongoose = require 'mongoose'


Build = mongoose.Schema({
    'project':
        # the project this build belongs to
        'type': mongoose.Schema.Types.ObjectId
        'ref': 'Project'
        'required': true

    'number':
        # the build number (auto-incrementing)
        'type': Number
        'required': true

    # api specified metadata, if any
    'meta': mongoose.Schema.Types.Mixed

    'createdAt': Date
    'updatedAt': Date
})


Build.pre 'save', (next) ->
    @updatedAt = new Date()
    if @isNew
        @createdAt = @updatedAt
    next()


Build.pre 'remove', (next) ->
    # delete all screenshots before deleting this build
    Screenshot.findAsync(
        'project': @project
        'build': @number
    )
    .then (screenshots) ->
        screenshot.removeAsync() for screenshot in screenshots
    .spread ->
        next()
    .catch (err) ->
        next(err)


Build.index({'project': 1, 'number': 1}, {'unique': true})


module.exports = Model = assimilate mongoose.model('Build', Build)
