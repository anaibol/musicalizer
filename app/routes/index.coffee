module.exports = ->
  # Index
	app.get '/', (req, res) ->
		res.render 'index', layout: false

  app.get '/search', (req, res) ->
    term = req.query.term 
    Song.search term, (err, result) ->
      res.send result

  # Error handling (No previous route found. Assuming it’s a 404)
  app.get '/*', (req, res) ->
    NotFound res

  NotFound = (res) ->
    res.render '404', status: 404, view: 'four-o-four'