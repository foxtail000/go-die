Sequelize = require 'sequelize'

module.exports = {
  id: {type: Sequelize.STRING, primaryKey: true, defaultValue: Sequelize.UUIDV4}
  model: {type: Sequelize.STRING}
  modelkey: {type: Sequelize.STRING}
  state: {type: Sequelize.STRING}
  data: {type: Sequelize.TEXT}
}