###
npm install --save gulp-coffeelint \
                   gulp-nodemon
###
path = require 'path'

module.exports = (gulp, plugins) ->
    paths =
        'watch': [
            path.resolve(__dirname, '../config/**/*.coffee')
            path.resolve(__dirname, '../gulp/**/*.coffee')
            path.resolve(__dirname, '../handlers/**/*.coffee')
            path.resolve(__dirname, '../middlewares/**/*.coffee')
            path.resolve(__dirname, '../models/**/*.coffee')
            path.resolve(__dirname, '../services/**/*.coffee')
            path.resolve(__dirname, '../tests/**/*.coffee')
            path.resolve(__dirname, '../*.coffee')
        ]
        'serve': [
            path.resolve(__dirname, '../config/*')
            path.resolve(__dirname, '../handlers/*')
            path.resolve(__dirname, '../middlewares/*')
            path.resolve(__dirname, '../models/*')
            path.resolve(__dirname, '../services/*')
            path.resolve(__dirname, '../*')
        ]


    gulp.task 'lint:coffeescript', 'lints all project coffeescript files', ->
        gulp
            .src(paths.watch)
            .pipe(plugins.coffeelint())
            .pipe(plugins.coffeelint.reporter())
            .pipe(plugins.coffeelint.reporter('failOnWarning'))


    gulp.task 'watch:coffeescript', 'waits for coffeescript files to change, then lints them', ->
        gulp.watch(paths.watch, ['lint:coffeescript'])


    gulp.task 'watch:coffeescript:serve', 'waits for coffeescript files to change, and restarts
                                           the development server when they do', ->
        plugins.nodemon(
            'script': 'serve.coffee'
            'ext': 'coffee'
            'watch': paths.serve
            'env':
                'NODE_ENV': 'development'
        )
