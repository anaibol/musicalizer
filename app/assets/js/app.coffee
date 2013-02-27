window.Music = class Music extends Batman.App
  @root 'app#index'
  query: ''

  @set 'mission', 'fight crime'

  #@controller 'app'
  #Batman.ViewStore.prefix = 'assets/views'

  @route '/search', 'app#search'

Music.run()