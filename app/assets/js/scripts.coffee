log = (param) ->
  console.log(param)

resizeTables = () ->
  $('.results').height $(window).height() - $('header').height() - $('footer').height()
  $('.tbody').height $('.results').height() - $('.thead').height()


moveColumn = (table, from, to) ->
  rows = $(table).find("tr")

  rows.each ->
    cols = $(this).children("th, td")
    cols.eq(from).detach().insertBefore cols.eq(to)

makeTablesSortable = () ->
  thead = $('.results > .thead > thead > tr > th').not('.number')
  tbody = $('.results > .tbody > tbody')  

  thead.each ->
    th = $(this)
    thIndex = th.index()
    inverse = false
    th.click ->
      tbody.find("td").filter(->
        $(this).index() is thIndex
      ).sortElements ((a, b) ->
        (if $.text([a]) > $.text([b]) then (if inverse then -1 else 1) else (if inverse then 1 else -1))
      ), ->
        # parentNode is the element we want to move
        @parentNode

      if !inverse
        thead.children('span').remove()
        $(this).append('<span class="icon-sort-down"></span>')
      else
        thead.children('span').remove()
        $(this).append('<span class="icon-sort-up"></span>')

      inverse = not inverse

makeTablesSelectable = () ->
  $('.table tbody tr').live('click', (e) ->
    if $(this).not 'selected'
      if e.ctrlKey
        $(this).toggleClass 'selected'
      else
        $('.selected').removeClass 'selected'
        $(this).addClass 'selected'
  )

$(window).resize ->
  resizeTables()

###
Player = Backbone.Model.extend(
  defaults:
    playing: true
    volume: 100

  initialize: ->
    self = this
    @on 'change:volume', ->
      soundManager.setVolume 'aSound', self.get('volume')

    @on 'change:playing', ->
      soundManager[(if self.get('playing') then 'play' else 'pause')] 'aSound'
)

PlayerView = Backbone.View.extend(
  events:
    'click .volume': 'setVolume'
    'click .play-pause': 'togglePlayState'

  togglePlayState: (e) ->
    e.preventDefault()
    $(e.currentTarget).toggleClass 'playing'
    @model.set playing: $(e.currentTarget).hasClass('playing')

  setVolume: (e) ->
    @model.set volume: $(e.currentTarget).data('value')
)
###

$ ->
  # disable mousewheel zoom (work on ff, doesn't work on chrome)
  #$(window).mousewheel (e) ->
  #  if e.ctrlKey
  #    e.preventDefault()

  # disable keyboard zoom
  $(document).keydown (e) ->
    keyAdd = 107
    keySubstract = 109
    if e.ctrlKey and (e.keyCode is keyAdd or e.keyCode is keySubstract)
      return false

  #$(document).jkey 'a+s', ->
  #  $('header .search').focus()

  $('.playlist .table').tableDnD()

  $('.results').colResizable()

  #$('.results .tbody').jScrollPane()

  resizeTables()
  makeTablesSelectable()
  makeTablesSortable()

  $("th").dragdrop
    canDrag: (src, event) ->
      src

    canDrop: (dst) ->
      true

    didDrop: (src, dst) ->
      col = $(src).index()
      col2 = $(dst).index()

      if col isnt col2
        tbl = $(".results table")
        console.log col
        console.log col2
        moveColumn tbl, col, col2
        $('.results').colResizable()   



# Make myElement drag-and-drop enabled
#DragDrop.bind $()


###        

  $.get '/rest/song/50ae4b1cd06ad63012000005', (data) ->
    #console.log data.payload[0]
    song = new Song()
    form = new Backbone.Form(model: song).render()

    $('body').append form.el

  player = new Player()
  playerView = new PlayerView(
    model: player
    el: $('.player')
  )

soundManager.setup
  url: 'swf'
  flashVersion: 9 # optional: shiny features (default = 8)
  debugMode: true
  useFlashBlock: false # optionally, enable when you're ready to dive in/**
  onready: ->
    # Ready to use; soundManager.createSound() etc. can now be called.
    mySound = soundManager.createSound(
      id: 'aSound'
      url: '/Rollup (Baauer Remix).mp3'
      onplay: ->
        console.log 'foo'

      onid3: ->
        console.log 'here'
    )
    mySound.play()

#utilityBelt = new Batman.UtilityBelt(Music)
#utilityBelt.displayRoutes()

$('input').autocomplete(
  #minChars: 3
  #autoFill: true
  source: 'search'
  minLength: 2
  select: (event, ui) ->
    console.log ui
    soundManager.createSound
      id: 'mySound'
      url: 'mp3/' + ui.item.fileName
      autoLoad: true
      autoPlay: true
      onload: ->
        
      volume: 50

).data('autocomplete')._renderItem = (ul, ui) ->
  $('<li></li>')
  .data('item.autocomplete', ui)
  .append('<a><span style='color:red'>' + ui.artist + '</span> - <span style='color: blue'>' + ui.title + '</span></a>')
  .appendTo ul
###


###

# Array of files you'd like played
playAudio = (playlistId) ->

  # Default playlistId to 0 if not supplied 
  playlistId = (if playlistId then playlistId else 0)
  
  # If SoundManager object exists, get rid of it...
  if audio.nowPlaying
    audio.nowPlaying.destruct()
    
    # ...and reset array key if end reached
    playlistId = 0  if playlistId is audio.playlist.length
  
  # Standard Sound Manager play sound function...
  soundManager.onready ->
    audio.nowPlaying = soundManager.createSound(
      id: 'sk4Audio'
      url: audio.playlist[playlistId]
      autoLoad: true
      autoPlay: true
      volume: 50
      
      # ...with a recursive callback when play completes
      onfinish: ->
        playlistId++
        playAudio playlistId
    )

audio = []
audio.playlist = [
    '/canvas/audio/Marissa_Car_Chase.mp3',
    '/canvas/audio/Vortex_Battl_Thru_Danger.mp3',
    '/canvas/audio/Gadgets_Activated.mp3',
    '/canvas/audio/Kids_Run_Into_Agents.mp3',
    '/canvas/audio/Jet_Luge_Chase.mp3'
]
  
# Start
playAudio[0]

###