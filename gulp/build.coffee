module.exports = (gulp, plugins) ->
    gulp.task 'build', 'builds all the registered static resources from assets into build', [
        # Add your build tasks here (must be prefixed with build:)
        'build:coffee'
        'build:img'
        'build:scss'
    ]
