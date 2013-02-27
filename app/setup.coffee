module.exports = (express) ->
  assets = require 'connect-assets'
  partials = require 'express-partials'
  path = require 'path'

  require './autoload'
  autoload helpersDir
  #autoload 'libDir'
  #autoload 'configDir'

  #global.models or
  global.db = require(path.join modelsDir, 'models')

  #mongooseBackbone = require './mongoose-backbone'
  #mongooseBackbone.expose() #expose all models

  #models = [Artist, Album, Song, Playlist, Tag]
  #mongooseBackbone.expose(models)

  #require './controllers'

  # Configuration
  app.configure ->
    port = process.env.PORT || 3000
    if process.argv.indexOf('-p') >= 0
      port = process.argv[process.argv.indexOf('-p') + 1]

    app.set 'port', port
    app.set 'views', viewsDir
    app.set 'view engine', 'jade'
    app.use express.static(publicDir)
    #app.use express.static(path.join(batmanDir, 'lib'))
    app.use express.favicon()
    app.use express.logger('dev')
    app.use express.bodyParser()
    app.use express.methodOverride()
    app.use partials()
    app.use assets(src: assetsDir)
    app.use app.router

  app.configure 'development', ->
    app.use express.errorHandler
      dumpExceptions: true
      showStack: true

  app.configure 'production', ->
    app.use express.errorHandler()

  ###
  assets = new rack.AssetRack([new rack.LessAsset(
    url: '/style.css'
    filename: __dirname + '/path/to/file.less'
  ), new rack.BrowserifyAsset(
    url: '/app.js'
    filename: __dirname + '/path/to/app.coffee'
  ), new rack.JadeAsset(
    url: '/templates.js'
    dirname: __dirname + '/templates'
  )])
  assets.on 'complete', ->
    console.log 'hey all my assets were created!'

  assets.on 'complete', ->
    app.configure ->
      app.use assets # that's all you need to do

      app.listen(app.get('port'))  
  ###

  #stylus().include('bootstrap-stylus', 'nib')

  #compile = (str, path) ->
  #  stylus(str).set('filename', path).set('compress', true).use(nib())

  #app.use stylus.middleware
  #  src: baseDir
  #  compile: compile

  global.music = require './music'

  #beginPath = '/home/anibal/Descargas'
  #beginPath = 'C:\\m'
  #music.traverseFileSystem beginPath

  app.get '/', (req, res) ->
    res.render 'index', layout: false

  app.get '/views/songs/index.html', (req, res) ->
    res.render 'songs', layout: false    

  #app.get '/search', (req, res) ->
  #  term = req.query.term 
  #  Song.search term, (err, result) ->
  #    res.send result 

  app.listen app.get('port')
  console.log 'Music explorer server listening on port %d in %s mode', app.get('port'), app.settings.env