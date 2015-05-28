extend = require 'deep-extend'
path = require 'path'
fs = require 'fs'


config = {}


load = (folder) ->
    # reads all the non-index files in `folder` and stores their values into the config namespace
    # identified by their basename, merging with any existing data and overriding on conflict
    for file in fs.readdirSync(folder)
        stat = fs.statSync(path.join(folder, file))
        if stat.isDirectory()
            continue

        [file, extension] = file.split('.', 2)
        if file isnt 'index' and extension in ['coffee', 'js', 'json']
            oldData = config[file] or {}
            newData = require('./' + file)
            config[file] = extend(oldData, newData)


# read everything in the current folder (which is the de-facto development environment)
load(__dirname)


# if the NODE_ENV shell variable exists and points to a valid subfolder, attempt to overwrite any
# global configuration options with their per-environment values
if process.env.NODE_ENV and process.env.NODE_ENV isnt 'development'
    envName = process.env.NODE_ENV
    envPath = path.join(__dirname, envName)

    stat = fs.statSync(envPath)
    if stat.isDirectory()
        load(envPath)
    else
        console.warn('Invalid environment provided: ' + envName)


module.exports = config
