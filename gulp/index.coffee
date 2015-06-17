# load plugins
plugins = require('gulp-load-plugins')({
    # the glob to search for
    'pattern': ['gulp-*']

    # remove from the name of the module when adding it to the context...
    'replaceString': /\bgulp[\-.]|run[\-.]|merge[\-.]|main[\-.]/

    # ...and convert it to camel case
    'camelizePluginName': true

    # only load plugins on demand
    'lazy': true
})


# load and register gulp tasks
gulp = require('gulp-help')(require('gulp'))
tasks = require('include-all')(
    'dirname': __dirname
    'filter': /(.+)\.(coffee|litcoffee|js|es6})$/
    'dontLoad': true
)
for own task of tasks
    if task not in ['index']
        require("./#{task}")(gulp, plugins)
