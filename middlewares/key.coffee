module.exports = (app) ->
    app.use '/api/projects/:project', module.exports.key = (req, res, next) ->
        # only allows non-safe requests that set the `X-API-Key` header
        if not req.params.project
            return res.status(404).send(
                'code': 'PROJECT_NOT_FOUND'
                'message': 'No such project exists'
            )

        if req.method in ['GET', 'HEAD']
            return next()

        key = req.get('X-API-Key')
        if not key
            return res.status(403).send(
                'code': 'KEY_REQUIRED'
                'message': 'No api key received. Please populate the `X-API-Key` header'
            )

        if key isnt req.params.project.key
            return res.status(403).send(
                'code': 'INVALID_KEY'
                'message': 'Your API key is incorrect.'
            )

        next()
