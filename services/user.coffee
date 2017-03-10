express = require 'express'
router = express.Router()
config = require '../config.coffee'

UserModel = new BaseModel('user', 'sql')

module.exports =

  add:(params, callback) ->
    UserModel.add(params).done (error, rlt) ->
      if err?
        return callback err
      return callback null, rlt

  update:(params, callback) ->
    UserModel.where({name:params.name}).update(params).done (err, rlt) ->
      if err?
        return callback err
      return callback null, rlt


  get:(params, callback) ->
    UserModel.where(params).findAll().done (err, rlt)->
      if err?
        return callback err
      return callback null, rlt

  delete:(params, callback) ->
    UserModel.where(params).delete().done (err, rlt) ->
      if err?
        return callback err
      return callback null, rlt

