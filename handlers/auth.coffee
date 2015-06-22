{User} = require '../models'

{Error} = require 'mongoose'


module.exports = (app) ->
    app.post '/api/auth', (req, res) ->
        # Attempts to log an user in using `email` and `password`
        User.findOneAsync(req.body.email)
        .then (user) ->
            if not user
                return res.status(403).send(
                    'code': 'FORBIDDEN'
                    'message': 'User does not exist'
                )
            user.authenticateAsync(req.body.password)
            .then (match) ->
                if not match
                    return res.status(403).send(
                        'code': 'FORBIDDEN'
                        'message': 'Invalid password'
                    )
                req.session.userId = user.id
                res.status(200).send(
                    'code': 'OK'
                    'message': 'Success'
                    'data': user.jsonify()
                )
        .catch (err) ->
            console.error(err.stack)
            res.status(500).send(
                'code': 'INTERNAL'
                'message': 'The server had an internal error'
            )


    app.get '/api/auth', (req, res) ->
        # Returns the currently authenticated user, or null if no user is logged in
        res.status(200).send(
            'code': 'OK'
            'message': 'Success'
            'data': if req.user then req.user.jsonify() else null
        )


    app.delete '/api/auth', (req, res) ->
        # Signs the currently authenticated user out
        delete req.session.userId
        res.status(200).send(
            'code': 'OK'
            'message': 'Success'
        )

