{Build, Screenshot} = require '../../models'

{Error} = require 'mongoose'


module.exports = (app) ->
    app.post '/api/projects/:project', (req, res) ->
        # Creates a new build in a project, returning the new build number
        number = req.params.project.head++
        req.params.project.saveAsync()
        .then ->
            Build.createAsync(
                'project': req.params.project.id
                'number': number
                'meta': req.body.meta
            )
        .then ->
            res.status(201).send(
                'code': 'OK'
                'message': 'Created'
                'data': number
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


    app.get '/api/projects/:project/:build', (req, res) ->
        # Returns the metadata associated with a build, including a list of all available
        # screenshots
        Screenshot.findAsync(
            'project': req.params.project.id
            'build': req.params.build.number
        )
        .then (screenshots) ->
            res.status(200).send(
                'code': 'OK'
                'message': 'Success'
                'data': req.params.build.jsonify(
                    'screenshots': shot.slug for shot in screenshots
                )
            )


    app.put '/api/projects/:project/:build', (req, res) ->
        # Updates the metadata associated with a build
        req.build.updateAsync(
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


    app.delete '/api/projects/:project/:build', (req, res) ->
        # Deletes a build, together with all of its screenshots
        req.params.build.removeAsync()
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
