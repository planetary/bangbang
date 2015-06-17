module.exports = (gulp, plugins) ->
    gulp.task 'lint', 'runs all registered linters and out prints any detected issues', [
        # Add your lint tasks here (must be prefixed with lint:)
        'lint:coffee'
        'lint:scss'
    ]
