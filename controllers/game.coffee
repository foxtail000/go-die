express = require('express')
router = express.Router()
Util = require '../main/Util.coffee'
crypto = require 'crypto'
ctrServer = require '../services/ctr.coffee'


router.get '/:id', (req, res, next)->
  id = req.params.id
  console.log id
  ctrServer.getnode id ,(err,rlt) ->
    if err
      console.log err
      return Util.error 'game',4002,err
    return next {data: rlt}


router.post '/:id', (req, res, next) ->
  id = req.params.id
  console.log req.body
  if req.body.restart
    ctrServer.restart id,(err, rlt) ->
      if err
        return Util.error 'game',4003,err
      return next {data: rlt}
  node = req.body.node
  ctrServer.checkctr id, node, (err,rlt) ->
    if err
      console.log err
      return Util.error 'game',4003,err
    return next {data: rlt}


module.exports = router

