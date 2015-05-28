module.exports = (gulp, plugins) ->
    gulp.task 'lint', 'lints all project files', [
        # add your linters here
        'lint:coffeescript'
    ]
