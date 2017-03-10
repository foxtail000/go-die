express = require('express')
router = express.Router()
Util = require '../main/Util.coffee'
crypto = require 'crypto'
loginServer = require '../services/login.coffee'


router.get '/', (req, res, next)->
  return next {data: '你好, 冒险者 !'}


router.post '/', (req, res, next) ->
  if req.body.old is false
    err = Util.common.CheckParams ['name', 'cname', 'sex'],req.body
    if err
      return next err
  else
    err = Util.common.CheckParams ['name'],req.body
    if err
      return next err
  loginServer.init req.body, (err,rlt) ->
    if err
      console.log err
      return Util.error 'login','4001',err
    return next {data: rlt}


module.exports = router

