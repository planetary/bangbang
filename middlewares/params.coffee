{Build, Project, Screenshot} = require '../models'

Promise = require 'bluebird'


module.exports = (app) ->
    app.param 'build', (req, res, next, value) ->
        # populates `app.build`; expects `app.project` to be populated by a previous middleware
        if not value.match(/^[0-9]+$/)
            # builds must be numbers
            return next('route')

        Build.findOneAsync(
            'project': req.project.id
            'number': value
        )
        .then (build) ->
            if not build
                throw new Error("No such build in #{req.project.name}:
                                #{value}")
            req.build = build
            next()
        .catch (err) ->
            console.error(err)
            next('route')


    app.param 'profile', (req, res, next, value) ->
        # populates `app.profile`
        Profile.findOneAsync(
            'name': value
        )
        .then (profile) ->
            if not profile
                throw new Error("No such profile: #{value}")
            req.profile = profile
            next()
        .catch (err) ->
            console.error(err)
            next('route')


    app.param 'project', (req, res, next, value) ->
        # populates `app.project`
        Project.findOneAsync(
            'slug': value
        )
        .then (project) ->
            if not project
                throw new Error("No such project: #{value}")
            req.project = project
            next()
        .catch (err) ->
            console.error(err)
            next('route')


    app.param 'screenshot', (req, res, next, value) ->
        # populates either `app.screenshot` or `app.screenshots`, depending on whether `app.build`
        # was populated by a previous middleware; expects `app.project` to be populated by a
        # previous middleware

        if not value.match(/^[0-9a-z-_]*$/) or not value.match(/[^0-9]/)
            # screenshots must be lowercase, url friendly and must contain at least one
            # non-alphanumeric character
            return next('route')

        Promise.try ->
            if req.build
                Screenshot.findOneAsync(
                    'project': req.project.id
                    'build': req.build.number
                    'slug': value
                )
                .then (screenshot) ->
                    if not screenshot
                        throw new Error("No such screenshot in
                                         #{req.project.name} /
                                         #{req.build.number}: #{value}")
                    req.screenshot = screenshot
                    next()
            else
                Screenshot.findAsync(
                    'project': req.project.id
                    'slug': value
                )
                .then (screenshots) ->
                    if not screenshots
                        throw new Error("No such screenshot in
                                         #{req.project.name} /
                                         #{req.build.number}: #{value}")
                    req.screenshots = screenshots
                    next()
        .catch (err) ->
            console.error(err)
            next('route')
