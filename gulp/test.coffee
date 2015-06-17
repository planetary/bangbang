path = require 'path'


module.exports = (gulp, plugins) ->
    paths =
        'unit': [
            path.resolve(__dirname, '../tests/index.coffee')
            path.resolve(__dirname, '../tests/unit/**/*.coffee')
        ]
        'integration': [
            path.resolve(__dirname, '../tests/index.coffee')
            path.resolve(__dirname, '../tests/integration/**/*.coffee')
        ]
    config =
        'timeout': 2000


    gulp.task 'test:unit', 'runs unit tests using mocha', ->
        gulp
            .src(paths.unit, 'read': false)
            .pipe(plugins.mocha(config))


    gulp.task 'test:integration', 'runs integration tests using mocha', ->
        gulp
            .src(paths.integration, 'read': false)
            .pipe(plugins.mocha(config))


    gulp.task 'test', 'runs both unit and integration tests using mocha', ->
        gulp
            .src(paths.unit.concat(paths.integration), 'read': false)
            .pipe(plugins.mocha(config))
