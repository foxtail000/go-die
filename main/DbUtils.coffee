SqlCfg = require './SqlNo.coffee'
#Redis = require "./redis.coffee"
Memcached = require "./memcached.coffee"
# Memcached = {}
# Redis = require "./redis.coffee"

AUTO_REFRESH = {}

DbUtils =
# excute: (db, list, transaction, callback)->
# 	db = global.getDataBase db
# 	if not db
# 		return callback {message: 'db not exist'}
# 	result = []
# 	end = (error, data)->
# 		if error
# 			if not transaction
# 				return callback error, result
# 			transaction.rollback()
# 			return
# 		if not transaction
# 			return callback null, result
# 		transaction.commit()
# 	start = ()->
# 		if not list.length
# 			return end null, result
# 		item = result.slice(0, 1)[0]
# 		if not item or not item.model
# 			return end {message: 'item or model is not exist'}, result
# 		type = item.type
# 		if type is 'INS'
# 			doIns item
# 		else if type is 'UPD'
# 			doUpd item
# 		else if type is 'DEL'
# 			doDel item
# 		else
# 			return end {message: 'type is not support'}, result
# 	doIns = (item)->
# 		model = item.model
# 	doUpd = ()->
# 		model = item.model
# 	doDel = ()->
# 		model = item.model
# 	if transaction isnt false
# 		db.transaction (t)->
# 			transaction = t
# 			start()
# 		.then ()->
# 			callback null, result
# 		.catch (error)->
# 			callback error, result
# 	else
# 		start()
	queryOne: (opts, callback)->
		this.query opts, (error, list)->
			if error
				return callback error
			item = list[0]
			callback null, item
	query: (opts, callback)->#sqlNo, params, db, needCache, callback
		sqlNo = opts.sqlNo
		params = opts.params
		db = opts.db
		needCache = opts.needCache
		where = opts.where
		limit = opts.limit
		fieldsWhere = opts.fieldsWhere

		cfg = this.getQueryCfg sqlNo, where, params,fieldsWhere
		if opts.type? then cfg.type=opts.type else cfg.type="SELECT"
		# console.log cfg
		if not cfg?
			callback {message: 'sqlNo not exist: ' + sqlNo}
			return
		if cfg.cacheNo and needCache
			this.queryFromCache cfg, db, callback
		else
			this.queryFromDb cfg, db, callback, needCache
	getStr: (val)->
		pre = ''
		if val < 10
			pre = '0'
		return pre + val
	getQueryCfg: (sqlNo, where={}, params={},fieldsWhere, cacheTime)->
		sqlCfg = SqlCfg[sqlNo]
		if not sqlCfg?
			return null
		cfg = {}
		cache = sqlCfg.cache
		sqlParams = sqlCfg.params
		whereStr = ''
		op = null

		for key, value of where
			if not op
				op = 'AND'
			else if params.whereOpt
				op = params.whereOpt

			p = '='
			if not value
				continue
			if value.op and value.value
				p = value.op ? '='
				v = value.value
				if value.type is 'date'
					v = new Date(v)
					v = "#{v.getFullYear()}-#{@getStr(v.getMonth()+1)}-#{@getStr(v.getDate())} #{@getStr(v.getHours())}:#{@getStr(v.getMinutes())}:#{@getStr(v.getSeconds())}"
				value = v
			pk = key
			idx = pk.indexOf '.'
			if idx > -1
				pk = pk.substring idx+1
			if p is 'in' or p is 'IN'
				whereStr += " #{op} #{key} #{p} (:#{value})"
			else
				whereStr += " #{op} #{key} #{p} :#{pk}"
			params[pk] = value
		cacheNo = sqlNo
		args = {}
		#console.log sqlParams
		for p in sqlParams
#console.log p
			arg = params[p] ? null
			args[p] = arg
			cacheNo += '_' + p + '_' + arg
		cfg.args = args
		#		console.log '000000000000000------------'
		#		console.log sqlCfg.sql
		#		console.log cfg.cacheNo
		cfg.sql = sqlCfg.sql.replace /#{WHERE}/g, whereStr
		#console.log "【fieldsWhere】",fieldsWhere?,fieldsWhere
		if fieldsWhere?
			cfg.sql = sqlCfg.sql.replace /#{FIELDSWHERE}/g, fieldsWhere
		orderStr = ""
		orderObj = params.order
		orderArr = []
		for key, val of orderObj
			if val isnt "DESC"
				val = "ASC"
			orderArr.push "#{key} #{val}"
			cacheNo += "_#{key}_#{val}"
		if orderArr
			orderStr = "ORDER BY #{orderArr.join(',')}"
		if cache is true
			cfg.cacheNo = cacheNo
		cfg.sql = cfg.sql.replace /#{ORDER}/g, orderStr
		# start, ashertan  2015-07-01
		# if cfg.sql.indexOf('LIMIT') > 0
		# 	cfg.sql += " #{params.offset}, #{params.pagesize}"
		limitStr = ''
		if params.offset? and params.pagesize?
			limitStr = " LIMIT #{params.offset}, #{params.pagesize}"
		cfg.sql = cfg.sql.replace /#{LIMIT}/g, limitStr
		# end
		cfg.cacheTime = cacheTime ? sqlCfg.cacheTime
		cfg.autoRefresh = sqlCfg.autoRefresh
		return cfg
	queryFromCache: (cfg, db, callback)->
# console.log 'queryFromCache'
		me = this
		cacheNo = cfg.cacheNo
		if not cacheNo? or Memcached.isReady isnt true
# if not cacheNo? or Redis.isReady isnt true
			return this.queryFromDb cfg, db, callback
		Memcached.get cacheNo, (err, data)->
# Redis.get cacheNo, (err, data)->
			if err?
				console.log 'get ' + cacheNo + 'from cache error', err
				return me.queryFromDb cfg, db, callback
			else if data?
				try
					result = JSON.parse data
					#					console.log 'cache'
					#					console.log result
					callback null, result
				catch e
# console.log e
					return me.queryFromDb cfg, db, callback
			else
				return me.queryFromDb cfg, db, callback
	cacheQueryResult: (cacheNo, result, cacheTime)->
		if Memcached.isReady isnt true or not result.length
# if Redis.isReady isnt true or not result.length
			return
		if not result.length
			return
		if typeof result isnt 'string'
			result = JSON.stringify result
		# Memcached.replace cacheNo, result, (err, data)->
		# 	if not err?
		# 		return
		Memcached.set cacheNo, result, cacheTime, (err, data)->
			if err?
				console.log 'cache ' + cacheNo + 'error', err
				return
	removeCache: (sqlNo, params)->
		if Memcached.isReady isnt true
# if Redis.isReady isnt true
			return
		cfg = this.getQueryCfg sqlNo, null, params
		if not cfg?
			return
		# console.log cfg
		cacheNo = cfg.cacheNo
		if not cacheNo?
			return
		Memcached.delete cacheNo, (err) ->
# Redis.del cacheNo, (err)->
			if err?
# console.log 'delete cache ' + cacheNo + 'error', err
				return
	_queryFromDb: (cfg, db, callback, needCache=true,fieldsWhere)->
		me = this
		sql = cfg.sql
		args = cfg.args
		options = {type: cfg.type}
		db = global.getDataBase db, true
#		console.log "SQL:::::::::::::::::::::::", sql
#		console.log "options:::::::::::::::::::::::", options
#		console.log "args:::::::::::::::::::::::", args
		if not db
			callback {message: 'db not exist'}
			return
		if not sql?
			callback {message: 'sql is null'}
			return
		replacements = {}
		replacements.replacements = args
		if cfg.type
			replacements.type = cfg.type
		db.query(sql, options, replacements).then (list)->
			if not list?
				list = []
			#			else
			#				list = list[0]
			cacheNo = cfg.cacheNo

			listStr = []
			if list.length
				listStr = JSON.stringify list

			if cacheNo? and needCache is true
				cacheTime = cfg.cacheTime
				me.cacheQueryResult cacheNo, listStr, cacheTime
			callback null, list
	queryFromDb: (cfg, db, callback, needCache=true)->
		me = this

		cacheNo = cfg.cacheNo
		cacheTime = cfg.cacheTime
		@_queryFromDb cfg, db, callback, needCache
		if cacheNo? and cfg.autoRefresh and needCache is true
			time = cacheTime - 30
			if time < 60
				return
			if AUTO_REFRESH[cacheNo]
				clearInterval AUTO_REFRESH[cacheNo]
				AUTO_REFRESH[cacheNo] = null
			AUTO_REFRESH[cacheNo] = setInterval ()->
				cb = ()->
				me._queryFromDb cfg, db, cb, needCache
			, time*1000

module.exports = DbUtils
