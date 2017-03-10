require './main/BaseInit.coffee'
express = require 'express'

module.exports = app = express()
ExpressInit = require './main/ExpressInit.coffee'
ExpressInit(app)