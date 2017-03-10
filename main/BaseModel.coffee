_ = require 'underscore'
TrashModel = null

class BaseModel
  constructor: (modelName, modelType, db)->
    @modelType = modelType ? 'sql'
    if @modelType is 'sql'
      @Model = loadModel(modelName ,db)
      @Model && @Model.sync()
    # else
    # 	@Model = loadMongoModel(modelName)

    @params = {}
    @params.where = null
    @params.limit = 0
    @params.offset = 0
    @params.fields = null
    @params.order = ''
    #先改为true，方便调试
    @params.raw = true
    @params.transaction = null

    @result = null
    @action = null

  getModel: () ->
    return @Model

  findAll: () ->
    self = @
    @action = null
    @action = (callback) ->
      if self.Model.db_type is 'sql'
        return self.Model.findAll {
          where: self.params.where
          limit: self.params.limit
          offset: self.params.offset
          attributes: self.params.fields
          order: self.params.order
          raw: self.params.raw
        }
        .then (datas)->
          callback(null, datas)
        .catch (e)->
          callback(e)
      else
        console.log 'mongodb'
    return @

  find: () ->
    self = @
    @action = null
    @action = (callback) ->
      if self.Model.db_type is 'sql'
        return self.Model.find {
          where: self.params.where
          attributes: self.params.fields
          order: self.params.order
          raw: self.params.raw
        }
        .then (data) ->
          callback(null, data)
        .catch (e) ->
          callback(e)
    return @

  findById: (id) ->
    self = @
    @action = null
    @action = (callback) ->
      if self.Model.db_type is 'sql'
        self.params.where = self.params.where ? {}
        self.params.where.id = id
        return self.Model.find {
          where: self.params.where
          attributes: self.params.fields
          order: self.params.order
          raw: self.params.raw
        }
        .then (data) ->
          self.result = data
          callback(null, data)
        .catch (e) ->
          callback(e)
    return @

  findByField: (field, value) ->
    self = @
    @action = null
    @action = (callback) ->
      if self.Model.db_type is 'sql'
        self.params.where = self.params.where || {}
        self.params.where[field] = value
        return self.Model.find {
          where: self.params.where
          attributes: self.params.fields
          order: self.params.order
          raw: self.params.raw
        }
        .then (data) ->
          self.result = data
          callback(null, data)
        .catch (e) ->
          callback(e)
    return @

  findCountByField: (field, vlue) ->
    self = @
    @action = null
    @action = (callback) ->
      if self.Model.db_type is 'sql'
        return self.Model.count {
          where: self.params.where
        }
        .then (count) ->
          callback null, count
        .catch (e) ->
          callback(e)
    return @

  add: (kv)->
    self = @
    @action = null
    @action = (callback) ->
      if self.Model.db_type is 'sql'
        return self.Model.create(kv, {transaction: self.params.transaction})
        .then (instance)->
          callback null, instance
          return @
        .catch (error) ->
          callback error
          return @
    return @

  bulkAdd: (list)->
    self = @
    @action = null
    @action = (callback) ->
      if self.Model.db_type is 'sql'
        return self.Model.bulkCreate(list, {transaction: self.params.transaction})
        .then (instances)->
          callback null, instances
          return @
        .catch (error) ->
          callback error
          return @
    return @


  update: (kv) ->
    self = @
    @action = null
    @action = (callback) ->
      if self.Model.db_type is 'sql'
# self.Model.update(kv, {where: self.params.where, transaction: self.params.transaction})
        return self.Model.update(kv, {where: self.params.where})
        .then (instance)->
          callback null, instance
          return @
        .catch (error) ->
          callback error
          return @
    return @
  delete: () ->
    self = @
    @action = null
    @action = (callback) ->
      if self.Model.db_type is 'sql'
# loadModel('trash').create(kv)
        transaction = self.params.transaction
        where = self.params.where
        deleteRecords = []
        delEntry = ()->
# callback null
          self.Model.destroy {
            where: where
            transaction: transaction
# individualHooks: true
          }
          .then (affectRows)->
            callback null, affectRows, deleteRecords
            return @
          .catch (error)->
            callback error
            return @

        return self.Model.findAll {
          where: where
          transaction: transaction
        }
        .then (instances)->
          data = JSON.stringify(instances)
          # console.log instances
          # deleteRecords = instances.toJSON()
          if not instances.length
            return delEntry()
          keys = []
          modelName = self.Model.getTableName()
          for instance in instances
            key = instance.shorturl ? instance["#{modelName}_id"] ? instance.id ? instance.no
            if not key
              continue
            keys.push key
          return TrashModel.transaction(transaction).add({
            data: data
            model: modelName
            modelkey: keys.join(';')
          }).done((error, instance)->).then (instance)->
            delEntry()
        .catch (error)->
          delEntry()
    return @
  count: ()->
    self = @
    @action = null
    @action = (callback) ->
      if self.Model.db_type is 'sql'
        return self.Model.count {
          where: self.params.where
        }
        .then (data) ->
          callback(null, data)
        .catch (e) ->
          callback(e)
    return @


_.extend BaseModel.prototype, {
  where: (param) ->
    @params.where = param
    return @
  limit: (limit) ->
    @params.limit = limit
    return @
  offset: (offset) ->
    @params.offset = offset
    return @
  fields: (fields) ->
    @params.fields = fields
    return @
  order: (order) ->
    if @Model.db_type is 'sql'
      order_arr = []
      for key, val of order
        if not val
          continue
        order_arr.push key + ' ' + val
      order_str = order_arr.join ', '
      if order_str
        @params.order = order_str
    else
      @params.order = order
    return @
  raw: (raw) ->
    @params.raw = raw
    return @
  transaction: (transaction) ->
    @params.transaction = transaction
    return @
}

_.extend BaseModel.prototype, {
  done: (callback) ->
# console.log @action
    if @action
      p = @action(callback)
      @params.where = null
      @params.limit = 0
      @params.offset = 0
      @params.fields = null
      @params.order = ''
      @params.raw = true
      @params.transaction = null
      @result = null
      @action = null
      return p
    else
      callback new Error('没有指定动作')
}

TrashModel = new BaseModel('trash')

module.exports = BaseModel