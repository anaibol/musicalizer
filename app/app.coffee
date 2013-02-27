_ = require 'lodash'
express = require 'express'
path = require 'path'

#Resource = require 'express-resource'
stylus = require 'stylus'
#rack = require 'asset-rack'
#batman = require 'batman'
#nib = require 'nib'
#bootstrap = require 'bootstrap-stylus'

global.Server = {}
Server.root = __dirname
global.app = express()

global.baseDir = __dirname
#global.configDir = path.join baseDir, '../config'
#global.libDir = path.join baseDir, '../lib'
global.publicDir = path.join baseDir, '../public'
global.modelsDir = path.join baseDir, 'models'
global.viewsDir = path.join baseDir, 'views'
global.routesDir = path.join baseDir, 'routes'
global.controllersDir = path.join baseDir, 'controllers'
global.helpersDir = path.join baseDir, 'helpers'
global.assetsDir = path.join baseDir, 'assets'
global.vendorAssetsDir = path.join assetsDir, 'vendor'
global.batmanDir = path.join baseDir, '../node_modules', 'batman'

require('./setup')(express)