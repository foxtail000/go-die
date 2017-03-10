characterServer = require './character.coffee'
progressServer = require './progress.coffee'
userServer = require './user.coffee'
ctrServer = require './ctr.coffee'
randomServer = require './random.coffee'
uuid = require 'uuid'


initCharacter= (id,cname,sex,callback) ->
  item = randomServer.randomCharacter()
  characterinfo =
    id: id
    cname: cname
    sex: sex
    power: item[0]
    speed: item[1]
    IQ: item[2]
    money: item[3]
    face: item[4]
    lucky: item[5]
    items: ""
  characterServer.add characterinfo, (err, rlt) ->
    if err
      console.log 3
      console.log err
      return callbck 'server error'
    return callback null, rlt



initUser= (name, cname, sex, callback) ->
  id = uuid.v4()
  userinfo =
    id: id
    name: name
    currentNode:randomServer.randomProgress(sex)
  userServer.add userinfo,(err,rlt) ->
    if err
      return callback 'server error'
    initCharacter id, cname, sex, callback

module.exports =

#检查User是否有过记录, 没有的话, 初始化user. 有记录的话,返回当前节点
  init: (params, callback) ->
    name = params.name
    cname = params.cname
    sex = params.sex
    userServer.get {name:name},(err, rlt) ->
      if err
        return callback 'server error'
      if rlt.length is 0
        initUser name, cname, sex, callback
      else
        ctrServer.getnode rlt[0].currentNode, callback












