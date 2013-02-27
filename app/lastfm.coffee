LastFmNode = require('lastfm').LastFmNode
lastfm = new LastFmNode
  api_key: '883e1f5aa33e5af53bae2f06ac0914ca' # sign-up for a key at http://www.last.fm/api
  secret: '5174fece842a0fa6b35fc705a6390f00'
  #useragent: 'appname/vX.X MyApp' # optional. defaults to lastfm-node.


#artist.getInfo

lastfm.request 'artist.getInfo', 'artist:tool'


