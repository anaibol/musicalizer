fs = require 'fs'
path = require 'path'

musicmetadata = require 'musicmetadata'
probe = require 'node-ffprobe'

params = ['-I', 'dummy', '-V', 'dummy', '--verbose', '1', '--no-video-title-show', '--no-disable-screensaver', '--no-snapshot-preview']
#vlc = require('node-vlc')(params)

#getExtension = (fileName) ->
#  ext = path.extname(fileName or '').split('.')
#  ext[ext.length - 1]

#getFileName = (fullFileName) ->
#  fullFileName.substring(fullFileName.lastIndexOf('/')+1)

isMp3 = (fileName) ->
  ext = path.extname(fileName)
  if ext.toLowerCase() is '.mp3'
    true

parseMetaData = (fullFileName, data) ->
  parser = new musicmetadata(fs.createReadStream(fullFileName))
  parser.on 'metadata', (result) ->
    #if result.artist
      #console.log data
      #console.log result
        
    db.save(data)

parseMp3File = (fullFileName) ->
  probe fullFileName, (err, result) ->
    parseMetaData(fullFileName, result)
    #console.log result

watchFolder = (dirPath) ->
  fs.watch dirPath, (event, fileName) ->
    console.log event, fileName
    if fs.exists(fileName)
      stats = fs.statSync(fileName)
      if stats.isFile() 
        if isMp3(fileName)
          parseMetaData(fileName)
      else
        traverseFileSystem(fileName)
    else
      #traverseFileSystem(dirPath)

traverseFileSystem = (currentPath) ->
  #watchFolder(currentPath)

  fs.readdirSync(currentPath).forEach (file) ->
    try
      currentFile = path.join(currentPath, file)
      stats = fs.statSync(currentFile)
      if stats.isFile()
        if isMp3(currentFile)
          parseMp3File(currentFile)
          
      else
        traverseFileSystem(currentFile)
    catch err
      console.log err + ' ' + currentFile

#beginPath = '/home/anibal/Descargas'
#traverseFileSystem beginPath

play = (fileFullName) ->
  #url = 'http://s14.togrool.com/mp3/b/brian-eno/instrumental/Brian%20Eno%20-%20An%20Index%20Of%20Metals%20Edit.mp3'
  #media = vlc.mediaFromUrl(url)
  
  media = vlc.mediaFromFile(fileFullName)

  media.parseSync()
  media.track_info.forEach (info) ->
    console.log info

  console.log media.artist, '--', media.album, '--', media.title
  player = vlc.mediaplayer
  player.media = media
  console.log 'Media duration:', media.duration
  player.play()
  POS = 0.5
  player.position = POS
  poller = setInterval(->
    
    #console.log('Poll:', player.position);
    return  if player.position < POS
    try
      player.video.take_snapshot 0, 'test.png', player.video.width, player.video.height  if player.video.track_count > 0
      #console.log 'Media Stats:', media.stats
    catch e
      console.log e
    finally
      return  if player.position < 0.7
      player.stop()
      media.release()
      vlc.release()
      clearInterval poller
  , 100)

exports.traverseFileSystem = traverseFileSystem
exports.play = traverseFileSystem