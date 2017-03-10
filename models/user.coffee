# 玩家信息表
Sequelize = require 'sequelize'

module.exports = {
  id: {type: Sequelize.STRING, primaryKey: true} #用户ID,系统标识
  name: {type: Sequelize.STRING} #唯一性的一个id,给用户自己标识.
  currentNode: {type: Sequelize.STRING} #当前节点
}