module.exports = ->
  # Search
  app.get '/search', (req, res) ->
    res.send('que???')

  #app.get '/search', app.AppController.search

  # Error handling (No previous route found. Assuming it’s a 404)
  app.get '/*', (req, res) ->
    NotFound res

  NotFound = (res) ->
    res.render '404', status: 404, view: 'four-o-four'