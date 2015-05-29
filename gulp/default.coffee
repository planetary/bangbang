module.exports = (gulp) ->
    gulp.task 'default', 'watches all files for changes and (re)starts the development server', [
        'watch'
    ]
