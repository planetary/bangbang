{Profile, Screenshot} = require '../../models'

{Error} = require 'mongoose'


module.exports = (app) ->
    app.post '/api/projects/:project/:build', (req, res) ->
        # Take screenshots of `target` after `delay` milliseconds, as part of `build` of `project`,
        # using the `profiles` profile list and storing as `slug` or the sha1 of `target` if `slug`
        # is not provided. Each member of `profiles` must be either the name of a well-known
        # profile or a {width, height, agent} pair.
        profiles = []
        for profile in req.body.profiles
            if typeof profile is 'string'
                profiles.push(
                    'id': profile
                )
            else
                profiles.push(
                    'agent': profile.agent
                    'width': profile.width
                )

        Screenshot.createAsync(
            'project': req.project.id,
            'build': req.build.number
            'slug': req.body.slug
            'target': req.body.target
            'delay': req.body.delay or 0
            'format': req.body.format or 'jpeg'
            'meta': req.body.meta
            'profiles': profiles
        )
        .then (screenshot) ->
            res.status(200).send(
                'code': 'OK'
                'message': 'Created'
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


    app.get '/api/projects/:project/:screenshot', (req, res) ->
        # Returns a list of profiles in which a screenshot is available
        profiles = {}
        for screenshot in req.screenshots
            for profile in screenshot.profiles
                profiles[profile.slug] = true

        res.status(200).send(
            'code': 'OK'
            'message': 'Success'
            'data': profile for profile of profiles
        )


    app.get '/api/projects/:project/:screenshot/:profile', (req, res) ->
        # Returns a list of builds in which a particular profile of a screenshot is available
        builds = {}
        for screenshot in req.screenshots
            for profile in screenshot.profiles
                if profile.slug is req.params.profile
                    builds[screenshot.build] = true

        res.status(200).send(
            'code': 'OK'
            'message': 'Success'
            'data': Number(build) for build of builds
        )


    app.get '/api/projects/:project/:build/:screenshot', (req, res) ->
        # Returns the metadata associated with a screenshot in a particular build, including the
        # available profiles
        res.status(200).send(
            'code': 'OK'
            'message': 'Success'
            'data':
                'target': req.screenshot.target
                'delay': req.screenshot.delay
                'format': req.screenshot.format
                'meta': req.screenshot.meta
                'profiles': ver.id for ver in req.screenshot.profiles
                'createdAt': req.project.createdAt
                'updatedAt': req.project.updatedAt
        )


    app.put '/api/projects/:project/:build/:screenshot', (req, res) ->
        # Updates the metadata associated with this screenshot in this particular build
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


    app.get '/api/projects/:project/:build/:screenshot/:profile', (req, res) ->
        # Returns the metadata associated with a particular profile of a particular build of a
        # screenshot, including the S3 URL needed to display the resource
        for profile in req.screenshot.profiles
            if profile.slug is req.params.profile
                return res.status(200).send(
                    'code': 'OK'
                    'message': 'Success'
                    'data':
                        'width': profile.width
                        'agent': profile.agent
                        'url': req.screenshot.serve(profile)
                )

        # profile not found in this build
        res.status(404).send(
            'code': 'NOT_FOUND'
            'message': "Screenshot #{req.screenshot.slug} does not have a
                        #{req.params.profile} profile"
        )
