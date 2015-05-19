#!/usr/bin/env coffee
app = require './app'
config = require './config'

mongoose = require 'mongoose'

# connect to database
mongoose.connect(config.mongo.uri, config.mongo.options)
mongoose.connection.once 'open', ->

    # start server
    app.listen config.server.port, ->
        console.log("Server started on #{config.server.port}. To stop, hit
                     Ctrl + C")
