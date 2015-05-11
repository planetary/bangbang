{Build, Project, Screenshot} = require '../models'

Promise = require 'bluebird'
{Error} = require 'mongoose'


module.exports = (app) ->
    app.post '/api/projects', (req, res) ->
        # Creates a new project, returning its slug and api key
        if req.ip not in ['127.0.0.1', '::ffff:127.0.0.1', '::1']
            return res.status(400).send(
                'code': 'ACCESS_DENIED'
                'message': 'Only localhost may create projects'
            )
        Project.createAsync(
            'name': req.body.name
            'meta': req.body.meta
        )
        .then (project) ->
            res.status(201).send(
                'code': 'OK'
                'message': 'Created'
                'data':
                    'slug': project.slug
                    'key': project.key
            )
        .catch Error.ValidationError, (err) ->
            res.status(400).send(
                'code': 'VALIDATION'
                'message': err.message
                'data': err.errors
            )
        .catch (err) ->
            console.error(err.stack)
            res.status(500).send(
                'code': 'INTERNAL'
                'message': 'The server had an internal error'
            )


    app.get '/api/projects/:project', (req, res) ->
        # Returns a project's metadata together with a list of all builds and
        # available screenshots
        Promise.try -> [
            Build.findAsync(
                'project': req.project.id
            )
            Screenshot.findAsync(
                'project': req.project.id
            )
        ]
        .spread (builds, screenshots) ->
            res.status(200).send(
                'code': 'OK'
                'message': 'Success'
                'data':
                    'name': req.project.name
                    'meta': req.project.meta
                    'head': req.project.head
                    'builds': build.number for build in builds
                    'screenshots': shot.name for shot in screenshots
                    'createdAt': req.project.createdAt
                    'updatedAt': req.project.updatedAt
            )
        .catch (err) ->
            console.error(err.stack)
            res.status(500).send(
                'code': 'INTERNAL'
                'message': 'The server had an internal error'
            )


    app.put '/api/projects/:project', (req, res) ->
        # Updates an existing project's metadata, returning its slug (usually
        # the same but it might be modified)
        req.project.updateAsync(
            'name': req.body.name
            'meta': req.body.meta
        )
        .then ->
            res.status(200).send(
                'code': 'OK'
                'message': 'Saved'
            )
        .catch Error.ValidationError, (err) ->
            res.status(400).send(
                'code': 'VALIDATION'
                'message': err.message
                'data': err.errors
            )
        .catch (err) ->
            console.error(err.stack)
            res.status(500).send(
                'code': 'INTERNAL'
                'message': 'The server had an internal error'
            )


    app.delete '/api/projects/:project', (req, res) ->
        # Deletes a project, together with all of its builds and screenshots
        req.project.removeAsync()
        .then ->
            res.status(200).send(
                'code': 'OK'
                'message': 'Deleted'
            )
        .catch (err) ->
            console.error(err.stack)
            res.status(500).send(
                'code': 'INTERNAL'
                'message': 'The server had an internal error'
            )
