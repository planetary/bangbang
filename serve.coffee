#!/usr/bin/env coffee
app = require './app'
config = require './config'

mongoose = require 'mongoose'

# connect to database
mongoose.connect(config.mongo.uri, config.mongo.options)
mongoose.connection.once 'open', ->

    # start server
    port = config.server.port + (process.env.NODE_APP_INSTANCE or 0)
    app.listen port, ->
        console.log("Server started on #{port}. To stop, hit Ctrl + C")
