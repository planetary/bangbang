# requies: gulp-coffeelint
# requies: gulp-nodemon
path = require 'path'

module.exports = (gulp, plugins) ->
    paths = [
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


    gulp.task 'watch:coffeescript', 'serves the app in development mode', ->
        plugins.nodemon(
            'script': 'serve.coffee'
            'ext': 'coffee'
            'watch': [
                path.resolve(__dirname, '../config/*')
                path.resolve(__dirname, '../handlers/*')
                path.resolve(__dirname, '../middlewares/*')
                path.resolve(__dirname, '../models/*')
                path.resolve(__dirname, '../services/*')
            ]
            'env':
                'NODE_ENV': 'development'
        )
