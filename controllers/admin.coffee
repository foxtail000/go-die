express = require('express')
router = express.Router()
Util = require '../main/Util.coffee'
crypto = require 'crypto'
ctrServer = require '../services/ctr.coffee'
progressServer = require '../services/progress.coffee'

router.post '/setnode', (req, res, next) ->
  params = req.body
#  err = Util.common.CheckParams ['sons','mark','content','image','time','place','entercontrol','leavecontrol','change'],params
#  if err
#    return next err
  progressServer.add params, (err,rlt) ->
    if err
      return next err
    console.log rlt
    return next {data:rlt}





module.exports = router

