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

host = 'ws.audioscrobbler.com/2.0'

params = new Object
params.api_key = '883e1f5aa33e5af53bae2f06ac0914ca'
params.format = 'json'

#debugging errors and disambiguation ej: Tool


requestApi = (strParams, cb)->
  url = 'http://' + host + '/?' + strParams
  console.log url
  request url, (error, response, body) ->
    cb(body)
       

searchArtist = (query) ->
  params.method = 'artist.search'
  params.artist = query
  params.limit = 1

  strParams = qs.stringify(params)
  
  requestApi strParams, (result) ->
    console.log result

getArtistInfo = (artistName = null, mbid = null) ->
  params.method = 'artist.info'
  params.lang = 'spa'

  if mbid
    params.mbid = mbid
  else
    params.artist = artistName
    params.autocorrect = 1

  strParams = qs.stringify(params)
  
  requestApi strParams, (result) ->
    artist = JSON.parse result
    console.log artist.artist.bio

searchAlbum = (query) ->


searchSong = (query) ->


#mbid = searchArtist('megadeth')
info = getArtistInfo('rage against the machine')

#searchAlbum('black')
#searchSong('guerrilla radio')


###
name
mbid
url
image
stats
  listeners
  playcount
similar
  artists
    name
tags
  tag
    name
bio
  summary
  content