config = require '../config'

Promise = require 'bluebird'
mongoose = require 'mongoose'


before (next) ->
    # before running tests, connect to the mongo database
    if mongoose.connection.readyState is 0
        mongoose.connect(config.mongo.uri)
        mongoose.connection.once('open', next)
    else
        next()


beforeEach ->
    # delete data from existing collections, without discarding their indices; this is faster and
    # safer than dropping the entire database (faster because no indices are recomputed, and safer
    # because we don't 'steal' collections from underneath a running mongoose instance)
    Promise.map(
        mongoose.connection.collections[name] for own name of mongoose.connection.collections
        (collection) -> Promise.fromNode(collection.remove.bind(collection))
        'concurrency': 1
    )


after (next) ->
    # after all scheduled tests have been run, close any existing database connections to allow
    # graceful shutdown
    if mongoose.connection.readyState isnt 0
        mongoose.connection.close()
    next()
