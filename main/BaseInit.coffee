path = require 'path'
config = require '../config.coffee'

Util = require './Util.coffee'

global.auth = (req, res)->
  userId = Util.session.getUserId(req)
  if userId
    return true
  false

global.getConfig = (str='')->
  arr = str.split '.'
  temp = config ? {}
  for key in arr
    temp = temp[key]
    if not temp
      return
  return temp

DownloadUrlMapping = config.DownloadUrl
global.getDownloadUrl = (server, bucket, isImage=true)->
  key = 'OTHERS'
  if isImage is true
    key = 'IMAGE'
  mapping = DownloadUrlMapping[key]
  serverMapping = mapping[server] ? {}
  urlArr = serverMapping[bucket]
  if not urlArr
    return
  len = urlArr.length
  idx = Math.min(Math.floor(Math.random() * len), len)
  return urlArr[idx]


global.loadService = (functionName)->
  service = require(path.join(config.base_path, 'services', functionName + config.script_ext))
  service.name = functionName.toUpperCase()
  return service

dbconfig = config.dbconfig
DEFAULTDB = config.defaultdb
global.DATABASE = DATABASE = {}
Sequelize = null
Mongoose = null
initMysql = (cfg)->
  if not Sequelize?
    Sequelize = require 'sequelize'
  pool = cfg.pool ? {
    maxConnections: 2
    minConnections: 1
    maxIdleTime: 60*60*1000
  }
  db = new Sequelize(cfg.database, cfg.username, cfg.password, {
    define: {
      underscored: false
      freezeTableName: true
      charset: 'utf8'
      collate: 'utf8_general_ci'
# timestamps: false
    }
    dialect: 'mysql'
    timezone: '+08:00'

    host: cfg.host
    maxConcurrentQueries: 120
    logging: cfg.logging ? false
    pool: pool
  })
  db.db_type = 'sql'
  return db

initMongo = (cfg)->
  if not Mongoose
    Mongoose = require 'mongoose'
  host = cfg.host
  database = cfg.database
  if not host or not database
    return
  port = cfg.port ? 27017
  dbStr = "mongodb://#{host}:#{port}/#{database}"
  Mongoose.connect(dbStr)
  db = Mongoose.connection
  db.db_type = 'mongo'

  return db

if dbconfig
  for key, cfg of dbconfig
    type = cfg.type ? 'mysql'
    db = null
    switch type
      when 'mysql'
        db = initMysql cfg
      when 'mongo'
        db = initMongo cfg
    if db?
      db.db_name = key
      DATABASE[key] = db
else
  throw new Error('db config not exist')

if DEFAULTDB
  DEFAULTDB = DATABASE[DEFAULTDB]
  if DEFAULTDB
    global.DEFAULTDB = DEFAULTDB

readonlydbs = config.readonlydbs
global.getDataBase = (db, readonly)->
  if not db and readonly and readonlydbs
    i = Math.floor(Math.random() * readonlydbs.length)
    db = readonlydbs[i]
  # console.log i, db
  if not db
    db = global.DEFAULTDB
  if typeof db is 'string'
    db = global.DATABASE[db]
  return db

global.loadModel = (modelName, db)->
  db = global.getDataBase db
  if not db
    throw new Error('db not exist')
    return
  if obj
    return obj
  options = {}
  model_config = require(path.join(config.base_path, 'models', modelName+config.script_ext))

  if model_config.options
    options = model_config.options
    delete model_config.options

  options.createdAt = 'createtime'
  options.updatedAt = 'updatetime'
  obj = db.define(modelName.replace(/\/|\\/g, '_'), model_config, options)
  obj.db_type = db.db_type
  return obj

global.BaseModel = require './BaseModel.coffee'
