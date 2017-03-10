SqlCfg = {}

regSql = (sqlNo, cfg)->
  if not cfg? or not cfg.sql?
    throw new Error('sql is not exist')
    return
  if not cfg.params?
    cfg.params = []
  #if not cfg.cache?
  #	cfg.cache = yes
  #if not cfg.cacheTime?
  #	cfg.cacheTime = 60*60
  cfg.sqlNo = sqlNo
  # if SqlCfg[sqlNo]
  # 	throw new Error('sqlNo is exist')
  # 	return
  SqlCfg[sqlNo] = cfg

SqlCfg.regSql = regSql



module.exports = SqlCfg

