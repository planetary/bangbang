{Profile, Screenshot} = require '../models'

{Error} = require 'mongoose'


module.exports = (app) ->
    app.post '/api/projects/:project/:build', (req, res) ->
        # Take screenshots of `target` after `delay` milliseconds, using the
        # `versions` profiles as part of `build` of `project`, storing as
        # `slug` or the sha1 of `target` if `slug` is not  provided, optionally
        # binding it with `meta`. Each member of `versions` must be either the
        # name of a well-known profile or a {width, agent} pair.
        versions = []
        for version in req.body.versions
            if typeof version is 'string'
                versions.push(
                    'id': version
                )
            else
                versions.push(
                    'agent': version.agent
                    'width': version.width
                )

        screenshot = new Screenshot(
            'project': req.project.id,
            'build': req.build.number
            'slug': req.body.slug
            'target': req.body.target
            'delay': req.body.delay or 0
            'format': req.body.format or 'jpeg'
            'meta': req.body.meta
            'versions': versions
        )
        screenshot.validateAsync()
        .then ->
            # data looks okay; perform request in background...
            screenshot.saveAsync()
            .then ->
                console.log('Success')
            .catch (err) ->
                console.error(err.stack)

            # ... and inform the client that we'll do our best effort here
            res.status(202).send(
                'code': 'OK'
                'message': 'Accepted'
                'data': screenshot.slug
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


    ###app.get '/api/projects/:project/:screenshot', (req, res) ->
        # Returns a list of versions in which a screenshot is available
        versions = {}
        for screenshot in req.screenshots
            for version in screenshot.versions
                versions[version.id] = true

        res.status(200).send(
            'code': 'OK'
            'message': 'Success'
            'data': version for version of versions
        )


    app.get '/api/projects/:project/:screenshot/:version', (req, res) ->
        # Returns a list of builds in which a particular version of a
        # screenshot is available
        builds = {}
        for screenshot in req.screenshots
            for version in screenshot.versions
                if version.id is req.params.version
                    builds[screenshot.build] = true

        res.status(200).send(
            'code': 'OK'
            'message': 'Success'
            'data': Number(build) for build of builds
        )###


    app.get '/api/projects/:project/:build/:screenshot', (req, res) ->
        # Returns the metadata associated with a screenshot in a particular
        # build, including the available versions
        res.status(200).send(
            'code': 'OK'
            'message': 'Success'
            'data':
                'target': req.screenshot.target
                'delay': req.screenshot.delay
                'format': req.screenshot.format
                'meta': req.screenshot.meta
                'versions': ver.id for ver in req.screenshot.versions
                'createdAt': req.project.createdAt
                'updatedAt': req.project.updatedAt
        )


    app.put '/api/projects/:project/:build/:screenshot', (req, res) ->
        # Updates the metadata associated with this screenshot in this
        # particular build
        req.screenshot.updateAsync(
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


    app.get '/api/projects/:project/:build/:screenshot/:version', (req, res) ->
        # Returns the metadata associated with a particular version of a
        # particular build of a screenshot, including the S3 URL needed to
        # display the resource
        for version in req.screenshot.versions
            if version.id is req.params.version
                return res.status(200).send(
                    'code': 'OK'
                    'message': 'Success'
                    'data':
                        'width': version.width
                        'agent': version.agent
                        'url': req.screenshot.serve(version)
                )

        # version not found in this build
        res.status(404).send(
            'code': 'NOT_FOUND'
            'message': "Screenshot #{req.screenshot.slug} does not have a
                        #{req.params.version} version"
        )
