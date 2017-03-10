index = require './controllers/index.coffee'
game = require './controllers/game.coffee'
admin = require './controllers/admin.coffee'

module.exports = (app) ->
  app.use '/', index
  app.use '/game',game
  app.use '/admin',admin