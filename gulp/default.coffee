module.exports = (gulp, plugins) ->
    gulp.task 'default', 'watches all files for changes and (re)starts the development server',
              ['serve']
