{Profile} = require '../../models'

{Error} = require 'mongoose'


module.exports = (app) ->
    app.post '/api/profiles', (req, res) ->
        # Creates a new profile
        Profile.createAsync(
            'name': req.body.name
            'width': req.body.width
            'agent': req.body.agent
        )
        .then ->
            res.status(201).send(
                'code': 'OK'
                'message': 'Created'
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


    app.get '/api/profiles', (req, res) ->
        # Returns a list of profiles
        Profile.findAsync()
        .then (profiles) ->
            res.status(200).send(
                'code': 'OK'
                'message': 'Success'
                'data': profile.jsonify() for profile in profiles
            )
        .catch (err) ->
            console.error(err.stack)
            res.status(500).send(
                'code': 'INTERNAL'
                'message': 'The server had an internal error'
            )


    app.put '/api/profiles/:profile', (req, res) ->
        # Updates an existing profile
        req.params.profile.set(
            'name': req.body.name
            'width': req.body.width
            'agent': req.body.agent
        )
        req.params.profile.saveAsync()
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


    app.delete '/api/profiles/:profile', (req, res) ->
        # Deletes a profile. All previously generated screenshots are still
        # available
        req.params.profile.removeAsync()
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

