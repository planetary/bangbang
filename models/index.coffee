# exports all exported symbols of all sub-modules; if a particular sub-module exports a function,
# class or any other object with a prototype, it is bound directly to this model's symbol table,
# using the module's basename as a key
#
# TL;DR: use this as index.coffee in all `models` subfolders and you can do
# {User, Article, Comment} = require '../models'
path = require "path"
fs = require "fs"


symbols = {}


update = (file) ->
    # updates the symbol table by including those from `file`
    module = require("./" + file)

    if typeof(module::) is 'undefined'
        # assume a dictionary was exported and shallow-copy all properties
        for prop of module
            symbols[prop] = module[prop]
    else
        # assume a function or a class was exported and bind it to `modulename`
        symbols[file] = module


for file in fs.readdirSync(__dirname)
    stat = fs.statSync(path.join(__dirname, file))
    if stat.isDirectory()
        # subfolder; assume submodule
        update(file)
    else
        # subfile; only load coffee and js files to avoid .gitkeep, coffeelint.json, etc.
        [file, extension] = file.split(".", 2)
        if file isnt "index" and extension in ["coffee", "js"]
            update(file, module)


module.exports = symbols
