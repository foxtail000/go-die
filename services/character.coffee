config = require '../config.coffee'
characterModel = new BaseModel('character', 'sql')

module.exports =

  add:(params, callback) ->
    characterModel.add(params).done (error, rlt) ->
      if err?
        return callback err
      return callback null, rlt

  update:(params, callback) ->
    characterModel.where({id:params.id}).update(params).done (err, rlt) ->
      if err?
        return callback err
      return callback null, rlt


  get:(params, callback) ->
    characterModel.where(params).findAll().done (err, rlt)->
      if err?
        return callback err
      return callback null, rlt

  delete:(params, callback) ->
    characterModel.where(params).delete().done (err, rlt) ->
      if err?
        return callback err
      return callback null, rlt

