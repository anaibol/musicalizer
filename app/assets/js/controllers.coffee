class Music.AppController extends Batman.Controller
  index: ->
    Music.Song.destroyAll()
    @render false
  search: =>
    alert 'batman doesnt fly!'
    Music.set 'hasSearched', yes
    Music.Song.destroyAll()
    $.ajax '/search?q=' + encodeURI(Music.query),
      dataType: 'jsonp'
      success: (data) ->
        for obj in data.results
          song = new Music.Song obj
          song.save (error, record) -> throw error if error