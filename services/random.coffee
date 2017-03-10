config = require '../config.coffee'
module.exports =
  #随机角色属性
  randomCharacter: () ->
    rlt =[]
    sum = 120
    num = 6
    for i in [1,2,3,4,5]
      item = parseInt(sum/num)*2
      tmp = parseInt(Math.random()*item)
      sum = sum - tmp
      num = num - 1
      rlt.push tmp
    rlt.push sum
    return rlt

  #随机根节点
  randomProgress: (sex) ->
    switch sex
      when '0' then return @randomson(config.initprogress)
      when '1' then return @randomson(config.initprogress)
      when '2' then return @randomson(config.initprogress)


  #随机子节点
  randomson: (arr) ->
    len = arr.length
    return arr[parseInt(Math.random()*100)%len]

