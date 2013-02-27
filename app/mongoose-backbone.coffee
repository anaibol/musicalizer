MongooseBackboneBridge = ->
MongooseBackboneBridge::expose = ->

  script = ''

  for model in models
    collection = model.modelName.toLowerCase() + "s"
    
    script += "window." + model.modelName + " = Backbone.Model.extend({});"
    script += "window." + model.modelName + "s = Backbone.Collection.extend({model:window." + model.modelName + ", url:'/" + collection + "'});"
    console.log "/" + collection
    app.get "/" + collection, (req, res) ->      
      model
      .find()
      #.populate('albums')
      #.populate('albums.songs')
      .exec (err, docs) ->
        res.send docs


  app.get "/backbone.models.js", (req, res) ->    
    res.send script

module.exports = new MongooseBackboneBridge()