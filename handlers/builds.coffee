{Error} = require 'mongoose'


module.exports = (app) ->
    app.post '/api/projects/:project', (req, res) ->
        # Creates a new build in a project
        number = req.project.head++
        req.project.saveAsync()
        .then ->
            Build.createAsync(
                'project': req.project.id
                'number': number
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
            console.error(err)
            res.status(500).send(
                'code': 'INTERNAL'
                'message': 'The server had an internal error'
            )


    app.put '/api/projects/:project/:build', (req, res) ->
        # Updates the metadata associated with a build


    app.delete '/api/projects/:project/:build', (req, res) ->
        # Deletes a build, together with all of its screenshots
        req.build.removeAsync()
        .then ->
            res.status(200).send(
                'code': 'OK'
                'message': 'Deleted'
            )
        .catch (err) ->
            console.error(err)
            res.status(500).send(
                'code': 'INTERNAL'
                'message': 'The server had an internal error'
            )
