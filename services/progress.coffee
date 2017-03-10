express = require 'express'
router = express.Router()
config = require '../config.coffee'

progressModel = new BaseModel('progress', 'sql')

module.exports =

  add:(params, callback) ->
    progressModel.add(params).done (err, rlt) ->
      if err?
        return callback err
      return callback null, rlt

  update:(params, callback) ->
    progressModel.where({id:params.id}).update(params).done (err, rlt) ->
      if err?
        return callback err
      return callback null, rlt


  get:(params, callback) ->
    progressModel.where(params).findAll().done (err, rlt)->
      if err?
        return callback err
      return callback null, rlt

  delete:(params, callback) ->
    progressModel.where(params).delete().done (err, rlt) ->
      if err?
        return callback err
      return callback null, rlt

