{User} = require '../models'

Promise = require 'bluebird'


module.exports = (app) ->
    app.use (req, res, next) ->
        # populate req.user from req.session.userId
        Promise.try ->
            if req.session.userId
                User.findOneAsync('_id': req.session.userId)
            else
                null
        .then (user) ->
            req.user = user
            next()
        .catch (err) ->
            console.error(err.stack)
            res.status(500).send(
                'code': 'INTERNAL'
                'message': 'The server had an internal error'
            )
