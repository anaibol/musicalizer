fs = require 'fs'

# Recursively require a folder’s files
global.autoload = autoload = (dir, app) ->
  fs.readdirSync(dir).forEach (file) ->
    path = "#{dir}/#{file}"
    stats = fs.lstatSync(path)

    # Go through the loop again if it is a directory
    if stats.isDirectory()
      autoload path, app
    else
      require(path)?(app)