browserSync = require 'browser-sync'


module.exports = (gulp, plugins) ->
    paths = {
        'build': [
            # images that should be compressed
            './assets/images/**/*'
        ]
        # destination folder
        'output': './build/img'
    }


    gulp.task 'build:img', 'compresses images and moves them to the build folder', ->
        gulp
            .src(paths.build )
            .pipe(plugins.newer(paths.output))
            .pipe(plugins.image())
            .pipe(gulp.dest(paths.output))
            .pipe(browserSync.reload('stream': true))
            .pipe(plugins.notify('message': 'Image minification complete', 'onLast': true))


    gulp.task 'watch:img', 'watches the source images folders and recompresses them when
                            changed', ['build:img'], ->
        gulp.watch(paths.build, ['build:img'])
