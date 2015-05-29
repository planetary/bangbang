###
npm install --save include-all \
                   gulp \
                   gulp-help \
                   gulp-load-plugins
###


# load plugins
plugins = require('gulp-load-plugins')({
    # the glob to search for
    'pattern': [ 'gulp-*', 'merge-*', 'run-*', 'main-*' ]

    # remove from the name of the module when adding it to the context...
    'replaceString': /\bgulp[\-.]|run[\-.]|merge[\-.]|main[\-.]/

    # ...and convert it to camel case
    'camelizePluginName': true

    # only load plugins on demand
    'lazy': true
})


# setup env as a gulp plugin wannabe
plugins.env =
    'current': process.env.NODE_ENV or 'development'
    'is': {}
for env in ['development', 'testing', 'staging', 'production']
    plugins.env[env.toUpperCase()] = env
    plugins.env.is[env] = env.current is env


# load and register gulp tasks
gulp = require('gulp-help')(require('gulp'))
tasks = require('include-all')({
    'dirname': __dirname
    'filter': /(.+)\.(coffee|litcoffee|js|es6})$/
    'dontLoad': true
})
for own task of tasks
    if task isnt 'index'
        require("./#{task}")(gulp, plugins)
