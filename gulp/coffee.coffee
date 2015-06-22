browserify = require 'browserify'
browserSync = require 'browser-sync'
buffer = require 'vinyl-buffer'
source = require 'vinyl-source-stream'
extend = require 'deep-extend'
watchify = require 'watchify'
stylish = require 'coffeelint-stylish'


module.exports = (gulp, plugins) ->
    paths =
        'lint': [
            # coffee files to lint (ignore vendor)
            './**/*.coffee'
            '!./node_modules/**/*.coffee'
        ]
        'build': [
            # coffee files to bundle
            './assets/scripts/index.coffee'
        ],
        # destination folder
        'output': './build/js'


    bundler = browserify(paths.build, extend(watchify.args,
        # browserify options
        'extensions': ['.coffee']
        'debug': true
        'fullPaths': true
        'insertGlobals': true
        'transform': ['coffeeify', 'brfs', 'bulkify']
    ))

    bundle = ->
        bundler.bundle()
            .on 'error', plugins.notify.onError (err) ->
                "#{err.message} in #{err.fileName} at line #{err.lineNumber}"
            .pipe(source('bundle.js'))
            .pipe(buffer())
            .pipe(plugins.sourcemaps.init('loadMaps': true))
            .pipe(plugins.uglify())
            .pipe(plugins.sourcemaps.write('.'))
            .pipe(gulp.dest(paths.output))
            .pipe(browserSync.reload('stream': true))
            .pipe(plugins.notify('message': 'Coffee compilation complete', 'onLast': true))
        undefined


    gulp.task 'build:coffee', 'bundles all client-side coffeescript files into the build folder
                               via browserify', bundle


    gulp.task 'watch:coffee', 'waits for client-side coffee files to change, then builds them', ->
        watchify(bundler).on('update', bundle)
        bundle()


    gulp.task 'lint:coffee', 'lints all coffee files against coffeelint.json', ->
        gulp
            .src(paths.lint)
            .pipe(plugins.coffeelint())
            .pipe(plugins.coffeelint.reporter(stylish.reporter()))
            .pipe(plugins.coffeelint.reporter('failOnWarning'))
