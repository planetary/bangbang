module.exports = (gulp, plugins) ->
    gulp.task 'watch', 'watches all configured files and lints, builds then deploys them', [
        # add your watch tasks here
        'watch:coffeescript'
    ]
