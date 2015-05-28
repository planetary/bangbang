config = require '../config'

Promise = require 'bluebird'
mongoose = require 'mongoose'


module.exports.connect = (next) ->
    if mongoose.connection.readyState is 0
        mongoose.connect(config.mongo.uri)
        mongoose.connection.once('open', next)
    else
        next()


module.exports.disconnect = (next) ->
    if mongoose.connection.readyState isnt 0
        mongoose.connection.close()
    next()


module.exports.clean = ->
    # delete data from existing collections, without discarding their indices
    Promise.map(
        mongoose.connection.collections[name] for own name of mongoose.connection.collections
        (collection) -> Promise.fromNode(collection.remove.bind(collection))
        'concurrency': 1
    )
