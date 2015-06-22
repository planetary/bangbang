{Build, Project, Screenshot} = require '../models'

Promise = require 'bluebird'


module.exports = (app) ->
    app.param 'build', (req, res, next, value) ->
        # populates `req.params.build`; expects `req.params.project` to be populated a-priori
        if not value.match(/^[0-9]+$/)
            # builds must be numbers
            return next('route')

        Build.findOneAsync(
            'project': req.params.project.id
            'number': value
        )
        .then (build) ->
            if not build
                throw new Error("No such build in #{req.params.project.name}: #{value}")
            req.params.build = build
            next()
        .catch (err) ->
            console.error(err)
            next('route')


    app.param 'profile', (req, res, next, value) ->
        # populates `req.params.profile`
        Profile.findOneAsync(
            'name': value
        )
        .then (profile) ->
            if not profile
                throw new Error("No such profile: #{value}")
            req.params.profile = profile
            next()
        .catch (err) ->
            console.error(err)
            next('route')


    app.param 'project', (req, res, next, value) ->
        # populates `req.params.project`
        Project.findOneAsync(
            'slug': value
        )
        .then (project) ->
            if not project
                throw new Error("No such project: #{value}")
            req.params.project = project
            next()
        .catch (err) ->
            console.error(err)
            next('route')


    app.param 'screenshot', (req, res, next, value) ->
        # populates either `req.params.screenshot` or `req.params.screenshots`, depending on
        # whether `req.params.build` was populated by a previous middleware; expects
        # `req.params.project` to be populated a-priori

        if not value.match(/^[0-9a-z-_]*$/) or not value.match(/[^0-9]/)
            # screenshots must be lowercase, url friendly and must contain at least one
            # non-alphanumeric character
            return next('route')

        Promise.try ->
            if req.params.build
                Screenshot.findOneAsync(
                    'project': req.params.project.id
                    'build': req.params.build.number
                    'slug': value
                )
                .then (screenshot) ->
                    if not screenshot
                        throw new Error("No such screenshot in #{req.params.project.name} /
                                         #{req.params.build.number}: #{value}")
                    req.params.params.screenshot = screenshot
                    next()
            else
                Screenshot.findAsync(
                    'project': req.params.project.id
                    'slug': value
                )
                .then (screenshots) ->
                    if not screenshots
                        throw new Error("No such screenshot in #{req.params.project.name} /
                                         #{req.params.build.number}: #{value}")
                    req.params.params.screenshots = screenshots
                    next()
        .catch (err) ->
            console.error(err)
            next('route')
