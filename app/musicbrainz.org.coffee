###
APIConnect = require 'APIConnect'

api = new APIConnect()
api.domain('musicbrainz.org/ws/2/')
api.params({ query: 'Alice in CHains' })

api.connect('artist')


api.getArtist {},
  success: ->
    console.log 1

  error: ->
    console.log error
###

#artist?query=alice%20in%20chains


request = require 'request'
qs = require 'qs'
xml2js = require 'xml2js'
select = require 'js-select'


host = 'musicbrainz.org/ws/2'

params = new Object
parser = new xml2js.Parser()


#debugging errors and disambiguation ej: Tool


requestApi = (scope, strParams, cb)->
  url = 'http://' + host + '/' + scope + '?' + strParams

  console.log scope + '?' + strParams
  request url, (error, response, body) ->
    parser.parseString body, (err, result) ->
      cb(result)
       

searchArtist = (query) ->
  scope = 'artist'
  params.query = query
  strParams = qs.stringify(params)
  
  requestApi scope, strParams, (result) ->
    artists = result.metadata['artist-list'][0].artist

    select(artists).forEach (node) ->
      if node['life-span']
        console.log node.$.id
        console.log node.name
        console.log node['sort-name']
        console.log node.$.type
        console.log node.country
        console.log node['life-span']
        console.log node.disambiguation
        console.log node['tag-list'].tag
      

    #artists.forEach (a) ->
      #console.log(a['$'].id)
    #  console.log(a['$'].type)
    #  console.log(a.name)
    #  console.log(a.disambiguation)
    #  console.log(a['life-span'])
      #mb = require 'musicbrainz'          
      #mb.lookupRelease a['$'].id, ['artists'], (error, release) ->
      #console.log release

searchAlbum = (query) ->
  scope = 'release'
  params.query = query
  strParams = qs.stringify(params)

  requestApi scope, strParams, (result) ->
    albums = result.metadata['release-list'][0].release

    albums.forEach (a) ->
      #console.log(a['$'].id)

searchSong = (query) ->
  scope = 'recording'
  params.query = query
  strParams = qs.stringify(params)

  requestApi scope, strParams, (result) ->
    songs = result.metadata['recording-list'][0].recording
    console.log songs
    songs.forEach (a) ->
      #console.log(a['$'].id)
      console.log(a.title)
      console.log(a.length)
      console.log(a['artist-credit'])

searchArtist('megadeth')
#searchAlbum('black')
#searchSong('guerrilla radio')
