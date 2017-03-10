#Math = require 'Math'
random1 = (sum,num) ->
  rlt =[]
  for i in [1,2,3,4]
    item = parseInt(sum/num)*2
    tmp = parseInt(Math.random()*item)
    sum = sum - tmp
    num = num - 1
    rlt.push tmp
  rlt.push sum
  return rlt



console.log random1(100,5)

a = []
if a.length is 0
  console.log 1
else
  console.log 2