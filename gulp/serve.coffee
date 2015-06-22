browserSync = require 'browser-sync'


module.exports = (gulp, plugins) ->
    paths =
        'frontend': [
            './build/**/*.*'
            './views/**/*.jade'
        ]
        'backend': [
            # nodemon won't accept leading ./
            'config'
            'handlers'
            'middlewares'
            'models'
            'services'
            '*.coffee'
        ]
    ports =
        'frontend': 3000
        'backend': 4610


    gulp.task 'serve:browsersync', 'proxies the development server via BrowserSync to
                                    dynamically update static assets', ->
        browserSync(
            'port': ports.frontend,
            'files': paths.frontend,
            'proxy': 'http://localhost:' + ports.backend
        )


    gulp.task 'serve', 'waits for server-side coffeescript files to change, and restarts
                        the development server when they do', ['serve:browsersync'], ->
        plugins.nodemon(
            'script': 'serve.coffee'
            'watch': paths.backend
            'env':
                'NODE_ENV': 'development'
        )
