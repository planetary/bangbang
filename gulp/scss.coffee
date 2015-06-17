browserSync = require 'browser-sync'


module.exports = (gulp, plugins) ->
    paths =
        'watch': [
            # scss files to watch for changes
            './assets/styles/**/*.scss'
        ],
        'lint': [
            # scss files to lint (ignore vendor)
            './assets/styles/**/*.scss',
            '!./assets/styles/vendor/**/*'
        ],
        'build': [
            # scss files to build
            './assets/styles/main.scss'
        ],
        # destination folder
        'output': './build/css'


    gulp.task 'build:scss', 'compiles all scss files into the build folder', ->
        gulp
            .src(paths.build)
            .pipe(plugins.sourcemaps.init())
            .pipe(plugins.sass())
            .on 'error', plugins.notify.onError (err) ->
                "#{err.message} in #{err.fileName} at line #{err.lineNumber}"
            .pipe(plugins.autoprefixer())
            .pipe(plugins.minifyCss())
            .pipe(plugins.sourcemaps.write('.'))
            .pipe(gulp.dest(paths.output))
            .pipe(browserSync.reload('stream': true))
            .pipe(plugins.notify('message': 'SCSS compilation complete', 'onLast': true))


    gulp.task 'watch:scss', 'waits for scss files to change, then builds them', ['build:scss'], ->
        gulp.watch(paths.watch, ['build:scss'])


    gulp.task 'lint:scss', 'lints all non-vendor scss files against scss-lint.yml', ->
        gulp
            .src(paths.lint)
            .pipe(plugins.scssLint('customReport': plugins.scssLintStylish))
            .pipe(plugins.scssLint.failReporter())

