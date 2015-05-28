# attempts to recursively import and register any sub-handlers in the current module
#
# TL;DR; use this as the head of index.coffee files in all handler subfolders
path = require "path"
fs = require "fs"


module.exports = (app) ->
    for file in fs.readdirSync(__dirname)
        stat = fs.statSync(path.join(__dirname, file))
        if stat.isDirectory()
            # subfolder; assume submodule
            require("./" + file)(app)
        else
            # subfile; only load coffee and js files to avoid .gitkeep, coffeelint.json, etc.
            [file, extension] = file.split(".", 2)
            if file isnt "index" and extension in ["coffee", "js"]
                require("./" + file)(app)
