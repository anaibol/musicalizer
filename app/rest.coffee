lingo = require 'lingo'
en = lingo.en
#es = lingo.es

actions = ['index', 'new', 'create', 'show', 'edit', 'update', 'destroy']
collections = []

app.get '*', (req, res) ->
  params = req.params[0].split '/'
  params.collection = params[1]
  params.collectionQuery = params[2]
  params.action = params[3]
  params.action = 'index' if params.action is undefined

  for model in models
    collection = model.modelName.toLowerCase()
    collection = en.pluralize(collection)
    if collection is params.collection
      for action in actions
        if action is params.action
          res.send(JSON.stringify(model))
          return

          model.findOne
            name: params.collectionQuery
          , (err, result) ->
            res.json result

          #.populate('albums')
          #.populate('albums.songs')
          #.exec (err, docs) ->
          #  res.send docs

            #if req.format is 'json'


#  GET  /
#  GET  /new
#  POST /
#  GET  /:id
#  GET  /edit/:id
#  PUT  /:id
#  DEL  /:id
