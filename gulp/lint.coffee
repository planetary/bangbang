# requies: gulp-coffeelint
path = require 'path'

module.exports = (gulp, plugins) ->
    paths =
        'coffeescript': [
            path.resolve(__dirname, '../config/**/*.coffee')
            path.resolve(__dirname, '../gulp/**/*.coffee')
            path.resolve(__dirname, '../handlers/**/*.coffee')
            path.resolve(__dirname, '../middlewares/**/*.coffee')
            path.resolve(__dirname, '../models/**/*.coffee')
            path.resolve(__dirname, '../services/**/*.coffee')
            path.resolve(__dirname, '../tests/**/*.coffee')
            path.resolve(__dirname, '../*.coffee')
        ]


    gulp.task 'lint:coffeescript', 'lints all project coffeescript files', ->
        gulp
            .src(paths.coffeescript)
            .pipe(plugins.coffeelint())
            .pipe(plugins.coffeelint.reporter())
            .pipe(plugins.coffeelint.reporter('failOnWarning'))


    gulp.task 'lint', 'lints all project files', [
        # add your linters here
        'lint:coffeescript'
    ]
