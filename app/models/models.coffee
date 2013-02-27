global.mongoose = require 'mongoose'
mongooseSubpopulate = require('mongoose-subpopulate').extendMongoose
createdModifiedPlugin = require('mongoose-createdmodified').createdModifiedPlugin

Schema = mongoose.Schema
ObjectId = Schema.Types.ObjectId

#required fields in schema?

tagSchema = new Schema
  title: String

songSchema = new Schema
  title: String
  duration: String #Number
  track: String
  fileName: String
  fullFileName:
    type: String
    #index:
    #  unique: true
    #  dropDups: true
  tags: [tagSchema]
  timesPlayed: String #Number

albumSchema = new Schema
  songs: [
    type: ObjectId
    ref: "Song"
  ]
  title: String
  year: String
  duration: String #Number
  picture: String
  tracks: String #Number
  tags: [tagSchema]

artistSchema = new Schema
  albums: [
    type: ObjectId
    ref: "Album"
  ]
  name:
    type: String
    #index:
    #  unique: true
    #  dropDups: true    
  year: String
  picture: String
  type: String
  begin: String
  end: String
  tags: [tagSchema]

playlistSchema = new Schema
  title: String
  description: String
  songs: [songSchema]  

#Songs, Albums, Artists, Tags, Playlists

###
songSchema.statics.search = (term, cb) ->
  regExp = new RegExp('.*' + term + '.*', 'i')
  
  Song.find
    $or: [
      artist: regExp
    ,
      album: regExp
    ,
      title: regExp
    ,
      tag: regExp
    ,
      fileName: regExp
    ]
    #group: 'artist'
  , cb
###

exports.save = (data) ->
  Song.find
    fullFileName: data.filename
  , (err, result) ->

    if result.length < 0
      console.log 'SONG REPETIDO: ' + data.filename
    
    else
      song = new Song
        title: data.filename
        albumId: data.filename
        duration: data.filename
        track: data.filename
        fileName: data.filename
        fullFileName: data.filename

        #tags: [tagSchema]
        #timesPlayed: Number

      song.save (err) ->    
        console.log err.err  if err

        Album.find
          title: data.file
        , (err, result) ->

          if result.length > 0
            console.log 'ALBUM REPETIDO: ' + data.file
          
          else
            album = new Album
              title: data.filename
              year: data.filename
              duration: data.filename
              picture: data.filename
              tracks: data.filename

            album.songs.push song

            album.save (err) ->
              console.log err.err  if err

              Artist.find
                name: data.file
              , (err, result) ->

                if result.length > 0
                  console.log 'ARTIST REPETIDO: ' + data.file
                
                else
                  artist = new Artist
                    name: 'metallica'
                    year: data.year
                    picture: data.picture
                    type: data.type
                    begin: data.begin
                    end: data.end

                  artist.albums.push album

                  artist.save (err) ->
                    console.log artist
                    console.log err.err  if err

            ###
            Tag.find
              title: data.tag
            , (err, result) ->
              if result.length > 0
                console.log 'GENRE REPETIDO: ' + data.file
              else
                tag = new Tag
                  artists: [artistId]
                  title: data.tag

                tag.save (err) ->    
                  console.log err.err  if err
                  #console.log tag._id
            ###

#songSchema.plugin createdModifiedPlugin, {index: true}
#albumSchema.plugin createdModifiedPlugin, {index: true}
#artistSchema.plugin createdModifiedPlugin, {index: true}
#tagSchema.plugin createdModifiedPlugin, {index: true}
#playlistSchema.plugin createdModifiedPlugin, {index: true}

global.Song = mongoose.model 'Song', songSchema
global.Album = mongoose.model 'Album', albumSchema
global.Artist = mongoose.model 'Artist', artistSchema
global.Tag = mongoose.model 'Tag', tagSchema
global.Playlist = mongoose.model 'Playlist', playlistSchema

#mongooseSubpopulate.wrapSchema mongoose.model 'User'


global.models = [Artist, Album, Song, Playlist, Tag]

mongoose.set 'debug', true
#mongoose.connect 'localhost', 'music'

#rest = require 'mongoose-rest'

#rest.use app, mongoose
#rest.createRoutes()


mers = require 'mers'
app.use '/rest', mers(uri: 'mongodb://localhost/music').rest()

#require './rest'