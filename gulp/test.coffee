# requies: gulp-mocha
path = require 'path'

module.exports = (gulp, plugins) ->
    paths =
        'unit': [
            path.resolve(__dirname, '../tests/unit/**/*.coffee')
        ]
        'integration': [
            path.resolve(__dirname, '../tests/integration/**/*.coffee')
        ]


    gulp.task 'test:unit', 'runs unit tests using mocha', ->
        gulp.src(paths.unit, 'read': false).pipe(plugins.mocha())


    gulp.task 'test:integration', 'runs integration tests using mocha', ->
        gulp.src(paths.integration, 'read': false).pipe(plugins.mocha())


    gulp.task 'test', 'runs both unit and integration tests using mocha', [
        'test:unit'
        'test:integration'
    ]
