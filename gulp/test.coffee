path = require 'path'


module.exports = (gulp, plugins) ->
    paths =
        'base': [
            # always executed
            path.resolve(__dirname, '../tests/index.coffee')
        ]
        'unit': [
            # only executed by test:unit
            path.resolve(__dirname, '../tests/unit/**/*.coffee')
        ]
        'integration': [
            # only executed by test:integration
            path.resolve(__dirname, '../tests/integration/**/*.coffee')
        ]
    config =
        'require': [
            path.resolve(__dirname, '../register-coverage')
        ]


    gulp.task 'test:unit', 'runs unit tests using mocha', ->
        gulp
            .src(paths.base.concat(paths.unit), 'read': false)
            .pipe(plugins.mocha(config))


    gulp.task 'test:integration', 'runs integration tests using mocha', ->
        gulp
            .src(paths.base.concat(paths.integration), 'read': false)
            .pipe(plugins.mocha(config))


    gulp.task 'test', 'runs both unit and integration tests using mocha', ->
        gulp
            .src(paths.base.concat(paths.unit).concat(paths.integration), 'read': false)
            .pipe(plugins.mocha(config))
