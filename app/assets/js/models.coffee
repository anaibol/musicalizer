window.Player = class Player extends Batman.App
  @resources 'songs'
  @root 'songs#index'

# dataJSON = '[{"type":"I","published":"2012-08-11 18:48:29.678663","event_start":"2012-08-11 18:48:29.678663","event_stop":"2012-08-25 22:48:51.678663","event_duration":"14d 4h","a_c":[],"a_s":[],"u":[],"a_a":["AA3"],"f":["NG"],"notes":"SC","meta":{"total_count":106}},{"type":"T","published":"2012-05-15 09:56:25.678663","event_start":"2012-10-13 09:51:27.678663","event_stop":"2012-10-14 12:57:06.678663","event_duration":"1d 3h 5m","a_c":[["AA2","AA3"]],"a_s":[],"u":[0],"a_a":["CC","AA2","AA4"],"f":["NG"],"notes":"M"},{"type":"P","published":"2012-05-09 20:43:57","event_start":"2013-01-01 00:00:00","event_stop":"","event_duration":"","a_c":[["AA1","AA2"]],"a_s":[["R",["R2"]]],"u":[0],"a_a":["AA3"],"f":["N"],"notes":"M"},{"type":"I","published":"2012-04-26 11:01:00","event_start":"2012-05-01 00:00:00","event_stop":"","event_duration":"","a_c":[],"a_s":[],"u":[],"a_a":[],"f":[],"notes":"O"},{"type":"P","published":"2012-04-25 23:01:13","event_start":"2012-04-30 22:47:00","event_stop":"","event_duration":"","a_c":[],"a_s":[["R",["R1"]]],"u":[855],"a_a":["AA1","AA2","AA3","AA4"],"f":["N"],"notes":"F"},{"type":"P","published":"2012-04-20 14:20:00","event_start":"2012-04-21 01:00:00","event_stop":"2012-04-21 02:30:00","event_duration":"1h 30m","a_c":[["AA2","AA3"]],"a_s":[["R",["R1","R2"]]],"u":[272,0],"a_a":["AA3"],"f":["N"],"notes":"M"},{"type":"T","published":"2012-04-20 14:10:22","event_start":"2012-05-31 06:00:00","event_stop":"2012-05-31 18:00:00","event_duration":"12h","a_c":[["AA1","AA2"],["AA2","AA1"]],"a_s":[],"u":[740,680],"a_a":["AA1","AA2"],"f":[],"notes":"M"},{"type":"T","published":"2012-04-20 14:05:37","event_start":"2012-06-01 08:00:00","event_stop":"","event_duration":"","a_c":[["AA2","AA3"],["AA3","AA2"]],"a_s":[],"u":[],"a_a":["AA1","AA2","AA3"],"f":[],"notes":"EEC"},{"type":"I","published":"2012-04-13 21:44:02.678663","event_start":"2012-04-13 21:44:02.678663","event_stop":"2012-04-22 20:01:38.678663","event_duration":"8d 22h 17m","a_c":[["AA2","AA3"]],"a_s":[],"u":[0],"a_a":["AA4"],"f":[],"notes":"T"},{"type":"P","published":"2012-03-24 10:00:25.678663","event_start":"2012-03-24 10:00:25.678663","event_stop":"2012-03-25 16:49:45.678663","event_duration":"1d 5h 49m","a_c":[],"a_s":[],"u":[],"a_a":["CC","AA1","AA2"],"f":[],"notes":"M"}]'

songs = new Batman.Set
data = JSON.parse(dataJSON)
for mData in data
  m = new Player.Message
  m.fromJSON(mData)
  songs.add m

###
class Player.songsController extends Batman.Controller
  routingKey: 'songs'
  index: ->
    @render false
    @songs = songs
    v = @render source: 'songs/index'
###

class Player.Artist extends Batman.Model
  @resourceName: 'artist'
  @storageKey: 'artists'

  # fields
  @encode 'title', 'content', 'id'

  # validations
  @validate 'title', presence: true
  @validate 'content', presence: true

  # associations
  @hasMany 'albums', {inverseOf: 'artists', saveInline: false}

class Player.Album extends Batman.Model
  @resourceName: 'album'
  @storageKey: 'albums'

  # fields
  @encode 'title', 'content', 'id'

  # validations
  @validate 'title', presence: true
  @validate 'content', presence: true

  # associations
  @hasMany 'songs', {inverseOf: 'album', saveInline: false}

class Player.Song extends Batman.Model
  @resourceName: 'song'
  @storageKey: 'songs'

  # fields
  # @encode 'title', 'content', 'id'
  @encode 'type', 'published', 'event_start', 'event_stop', 'event_duration',
          'a_c', 'a_s', 'u',
          'a_a', 'f', 'notes', 'meta'

  # validations
  @validate 'title', presence: true
  @validate 'content', presence: true

  # associations
  # @hasMany 'covers', {inverseOf: 'post', saveInline: false}


window.Player = class Player extends Batman.App
  @resources 'songs'
  @root 'songs#index'


$ ->
  Player.run()

return
