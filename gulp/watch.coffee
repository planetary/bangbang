module.exports = (gulp, plugins) ->
    gulp.task 'watch', 'waits for changes in project files and attempts to rebuild them', [
        # add your watch tasks here (must be prefixed with watch:)
        'watch:coffee'
        'watch:img'
        'watch:scss'
    ]
