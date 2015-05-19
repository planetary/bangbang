config = require '../config'

request = require 'request'


module.exports = (gulp, plugins) ->
    gulp.task 'create-project', 'creates a new project for this app', (next) ->
        arg = require 'yargs'
            .usage 'gulp create-project [options]'
            .option 'n',
                'alias': 'name'
                'demand': true
                'describe': 'the name of the new project'
            .option 'm',
                'alias': 'meta'
                'describe': 'metadata associated with this project'
            .option 'c',
                'alias': 'config'
                'describe': 'use config file instead of args'
            .config('config')
            .argv

        request
            'url': "http://localhost:#{config.server.port}/api/projects"
            'method': 'POST'
            'body':
                'name': arg.name
                'meta': arg.meta
            'json': true
            'gzip': true
        , (err, res, body) ->
            if err
                return next(err)
            if body.code isnt 'OK'
                return next(new Error(body.message))

            console.log('----------')
            console.log('Project created!')
            console.log()
            console.log("Slug: #{body.data.slug}")
            console.log("API key: #{body.data.key}")
            console.log('----------')
            next()
        undefined  # sometimes, cofee's implicit return is weird
