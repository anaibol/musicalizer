fs = require 'fs'
path = require 'path'

# Recursively require a folder’s files
global.autoload = autoload = (dir) ->
  fs.readdirSync(dir).forEach (file) ->
    pathStr = path.join dir, file
    stats = fs.lstatSync(pathStr)

    # Go through the loop again if it is a directory
    if stats.isDirectory()
      autoload pathStr
    else
      require(pathStr)?()