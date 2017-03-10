# 进度节点表
Sequelize = require 'sequelize'

module.exports = {
  id: {type: Sequelize.STRING, primaryKey: true} #当前节点ID
  sons: {type: Sequelize.STRING} #子节点, sons为空时, 意味着失败.
  mark: {type: Sequelize.STRING} #在父节点下的标识,即为在父节点显示的选项
  content: {type: Sequelize.STRING} #节点主体
  image: {type: Sequelize.STRING} #节点背景图片
  time: {type: Sequelize.STRING}  #节点所在时间点
  place: {type: Sequelize.STRING} #节点所在地点
  entercontrol: {type: Sequelize.JSON}
  leavecontrol: {type: Sequelize.JSON}#条件控制, 实现非常重要,游戏保证多样性手段之一,根据条件, 去往指定的节点,当回到过去已经过的节点,便形成时间迷宫,条件判断发生在去往下个节点之前, 条件控制优先级大于已选子节点
  change: {type: Sequelize.STRING}  #属性变化,角色属性常作为控制的判断条件, 属性的不同,可能到达不同的节点,属性改变在达到此节点之前.
}


# 1,0,-1,2,-2,1    change 属性变化示例. 和为正,意味着选项的合理性

#control:{
#  leave:[
#    {
#      object:'IQ'
#      express:'less' or 'greater', 'equal'
#      value:30
#      result: '[nodeid]'
#    }
#  ]
#  enter:[
#    {
#      object:'IQ'
#      express:'less' or 'greater', 'equal'
#      value:30
#      result: '[nodeid]'
#    }
#  ]
#}
#
# 当数组内多组判断成立, 排前的优先
