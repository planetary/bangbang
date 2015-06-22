{User} = require '../../models'

{Error} = require 'mongoose'


module.exports = (app) ->
    app.post '/api/users', (req, res) ->
        # Creates a new user using `email`, `password` and `name`
        User.createAsync(
            'email': req.body.email
            'password': req.body.password
            'name': req.body.name
        )
        .then (user) ->
            res.status(200).send(
                'code': 'OK'
                'message': 'Success'
                'data': user.jsonify()
            )
        .catch Error.ValidationError, (err) ->
            console.log((err.errors[key].message for key of err.errors).join("\n"))
            res.status(400).send(
                'code': 'VALIDATION'
                'message': (err.errors[key].message for key of err.errors).join("\n")
                'data': err.errors
            )


    app.post '/api/users/exists', (req, res) ->
        # Returns true if an user with a particular e-mail exists
        User.findOneAsync('email': req.body.email)
        .then (user) ->
            res.status(200).send(
                'code': 'OK'
                'message': 'Success'
                'data': Boolean(user)
            )
        .catch (err) ->
            console.error(err.stack)
            res.status(500).send(
                'code': 'INTERNAL'
                'message': 'The server had an internal error'
            )
