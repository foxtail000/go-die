userServer = require './user.coffee'
characterServer = require './character.coffee'
progressServer = require './progress.coffee'
async = require 'async'
randomServer = require './random.coffee'

updatechr= (node, chrinfo, callback) ->
  arr = node.change.split(',')
  chrinfo.power = parseInt(chrinfo.power) + parseInt(arr[0])
  chrinfo.speed = parseInt(chrinfo.speed) + parseInt(arr[1])
  chrinfo.IQ = parseInt(chrinfo.IQ) + parseInt(arr[2])
  chrinfo.money = parseInt(chrinfo.money) + parseInt(arr[3])
  chrinfo.face = parseInt(chrinfo.face) + parseInt(arr[4])
  chrinfo.lucky = parseInt(chrinfo.lucky) + parseInt(arr[5])
  characterServer.update chrinfo,(err,rlt) ->
    if err
      return callback err
    return callback null, rlt

setnode= (user,node,chrinfo,callback) ->
  console.log user
  console.log node
  console.log chrinfo
  params =
    name :user.name
    currentNode:node.id
  #更新当前节点
  console.log '#######'
  console.log params
  userServer.update params,(err,rlt) ->
    if err
      return callback err
    updatechr node, chrinfo,callback


checkjudge= (chrinfo, control) ->
  if not control
    return null
  ctr = JSON.parse control
  nodeid = ""
  for i in ctr
    switch i.express
      when 'less'
        if parseInt(chrinfo[i.object])<parseInt(i.value)
          nodeid = i.result
      when 'equal'
        if parseInt(chrinfo[i.object]) is parseInt(i.value)
          nodeid = i.result
      when 'greater'
        if parseInt(chrinfo[i.object])>parseInt(i.value)
          nodeid = i.result
  if !nodeid
    return null
  progressServer.get {id:nodeid},(err,rlt) ->
    if err or rlt.length is 0
      return null
    return rlt[0]


getsonsmark = (sons,cb) ->
  selects = []
  console.log sons
  sons = sons.split(',')
  async.each sons,(item,callback) ->
    progressServer.get {id:item},(err,rlt) ->
      if err or rlt.length is 0
        callback()
      else
        temp=
          key:item
          value:rlt[0].mark
        selects.push temp
        callback()
  ,(err) ->
    console.log selects
    return cb null,selects



module.exports =
  checkctr : (id,selectnode,callback) ->
    userServer.get {name:id}, (err,userinfo) ->
      if err
        return callback err
      characterServer.get {id: userinfo[0].id} , (err, chrinfo) ->
        if err
          return callback err
        progressServer.get {id: userinfo[0].currentNode} , (err, fathernode) ->
          if err
            return callback err
          if fathernode[0].sons.indexOf(selectnode) is -1
            console.log 123

            return callback 'server error'
          progressServer.get {id: selectnode} , (err, sonnode) ->
            if err
              return callback err
            console.log sonnode
            rlt = checkjudge chrinfo,fathernode[0].leavecontrol
            if rlt
              setnode userinfo[0],rlt,chrinfo[0],(err, zero) ->
                if err
                  return callback err
                return callback null, zero
            rlt = checkjudge chrinfo,sonnode[0].entercontrol
            if rlt
              setnode userinfo[0],rlt,chrinfo[0],(err,zero) ->
                if err
                  return callback err
                return callback null, zero
            setnode userinfo[0],sonnode[0],chrinfo[0],(err,zero) ->
              if err
                return callback err
              return callback null, zero







  #获得节点
  getnode : (id, callback) ->
    userServer.get {name:id}, (err,userinfo) ->
      if err
        return callback err
      if userinfo.length is 0
        return callback 'the user not in database!'
      characterServer.get {id: userinfo[0].id} , (err, chrinfo) ->
        if err
          return callback err
        progressServer.get {id:userinfo[0].currentNode}, (err,nodeinfo) ->
          if err
            return callback err
          data ={}
          delete nodeinfo[0].entercontrol
          delete nodeinfo[0].leavecontrol
          data.chrinfo = chrinfo[0]
          data.nodeinfo = nodeinfo[0]
          getsonsmark nodeinfo[0].sons,(err,rlt) ->
            if err
              return callback err
            data.selects = rlt
            return callback null,data


  restart : (id, callback) ->
    console.log 'restart'
    params =
      name:id
      currentNode: randomServer.randomProgress('1')
    userServer.update params,(err, rlt) ->
      if err
        return callback err
      return callback null, rlt













