module.exports = (gulp, plugins) ->
    gulp.task 'lint', 'lints all project files', [
        # Add your lint tasks here (must be prefixed with lint:)
        'lint:coffeescript'
    ]
