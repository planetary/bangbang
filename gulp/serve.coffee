# requies: gulp-nodemon
path = require 'path'

module.exports = (gulp, plugins) ->
    options =
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


    gulp.task 'serve', 'serves the app in development mode', ->
        plugins.nodemon(options)
