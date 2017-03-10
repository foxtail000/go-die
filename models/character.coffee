# 角色表
Sequelize = require 'sequelize'

module.exports = {
  id: {type: Sequelize.STRING, primaryKey: true} # user 表的ID
  sex: {type: Sequelize.STRING} #性别, 0: 男 1:女 2:未知
  cname: {type: Sequelize.STRING} #角色名
  age: {type: Sequelize.STRING} #年龄
  power: {type: Sequelize.INTEGER} #战斗力系数
  speed: {type: Sequelize.INTEGER} #速度系数
  IQ: {type: Sequelize.INTEGER} #智商系数
  money: {type: Sequelize.INTEGER} #黄金律系数
  face: {type: Sequelize.INTEGER} #颜值系数
  lucky: {type: Sequelize.INTEGER} #幸运系数
  items: {type: Sequelize.STRING} #装备   以后扩展
}