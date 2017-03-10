crypto = require 'crypto'
fs = require 'fs'
_ = require 'lodash'
uuid = require 'node-uuid'
config = require '../config.coffee'
algorithm = 'aes-256-ctr'
password = 'd6F3Efeq'
async = require 'async'
process.env.NODE_TLS_REJECT_UNAUTHORIZED = '0';
SERVICE_CODE = {
  INDEX: '10000'
  API: '10001'
  APP: '10002'
  CHANNEL: '10003'
  ORGANIZATION: '10102'
  UPLOAD: '10103'
  USER: '10104'
  UNKNOW:'8080'
}
UNKONWN_SERVICE_CODE = '00000'

request = require 'request'
error = (service, code, msg, notice, others)->
  if not service
    errorcode = code
  else if SERVICE_CODE[service.toUpperCase()]
    errorcode = SERVICE_CODE[service.toUpperCase()] + code
  else
    errorcode = UNKONWN_SERVICE_CODE + code
  return {errcode: errorcode, message: msg, notice: notice, others: others}

resmessage = (payload,total,msg='成功',errorcode=0)->
  if (total?)
    return {errcode: errorcode, message: msg, payload:payload,total:total}
  else
    return {errcode: errorcode, message: msg, payload:payload}


common = {
  checkId: (id='')->
    err = null
    if id.length isnt 36
      err = error('COMMON', 1404, 'id is not found or id length is not 36.')
    return err
#校验函数参数方法；
#checkParamsArr:需要校验的参数名数组，例如：['param1','param2'...]
  CheckParams:(checkParamsArr,inPutParamsObj)->
    for item in checkParamsArr
      if _.isEmpty inPutParamsObj[item]
        return "Params [#{item}] is null."
    return null

  checkArr: (arr) ->
    n = []

    i = 0
    while i < arr.length
      if n.indexOf(arr[i]) == -1
        n.push arr[i]
      i++
    n
}

encrypt = {
  md5: (str) ->
    return crypto.createHash('md5').update(str).digest('hex')

  sha1: (str) ->
    return crypto.createHash('sha1').update(str,'utf-8').digest('hex')

  aes: (str) ->
    cipher = crypto.createCipher(algorithm, password)
    crypted = cipher.update(str,'utf8','hex')
    crypted += cipher.final('hex')
    return crypted

  randomStr: (range=30) ->
    return crypto.randomBytes(range).toString('hex')

  hmacsha1:(str,secret)->
    return crypto.createHmac('sha1', secret).update(str).digest().toString('base64');
}

decrypt = {
  aes: (str) ->
    decipher = crypto.createDecipher(algorithm, password)
    dec = decipher.update(str,'hex','utf8')
    dec += decipher.final('utf8')
    return dec
}

# console.log decrypt.aes('56d68dc8722062693c')

session = {
  init: (req, user,roles) ->
    if not req.session
      return
    userId = user.id || user._id
    userName = user.username
    name = user.name
    from = user.from || ''
    email = user.email
    phone = user.phone
    hid = user.hid
    req.session.userId = userId
    req.session.userName = userName
    req.session.name = name
    req.session.phone = phone
    req.session.email = email
    req.session.from = from
    req.session.hid = hid
    req.session["pfid"] = user.pfid
    #		req.session["pfid"] = user.pfid
    req.session.roles = roles or []
    req.session.toporgid = user.toporgid || null
    req.session.isnotice = user.isnotice #是否阅读了集团公告，ture：已读

  getRole: (rolename)->
    roles = (@getInfo req).roles or []
    if not rolename?
      return roles
    _roles = []
    for role in roles
      if role.rolekey is rolename
        _roles.push role
    return _roles
  getAdmin: (req)->
    info = @getInfo req
    if not info.userType
      return null
    if info.userType.indexOf('A') < 0
      return null
    return info
  getUserId: (req) ->
    if not req.session
      return
    return req.session.userId
  get: (req, key) ->
    if not req.session
      return
    return req.session[key]
  set: (req, key, value) ->
    if not req.session
      return
    return req.session[key] = value
  getInfo: (req)->
    if not req or not req.session
      return
    info = {
      userId: req.session.userId
      userName: req.session.userName
      name : req.session.name
      phone: req.session.phone
      email: req.session.email
      from: req.session.from
      hid:req.session.hid
      roles:req.session.roles
      toporgid :req.session.toporgid
      isnotice: req.session.isnotice
    }
    return info
  destory: (req)->
    if not req or not req.session
      return
    req.session.userId = null
    req.session.userName = null
    req.session.name = null
    req.session.phone = null
    req.session.email = null
    req.session.from = null
    req.session.hid = null
    req.session.roles = null
    req.session.toporgid = null
}

DateUtil = {
  getStr: (val)->
    pre = ''
    if val < 10
      pre = '0'
    return pre + val
  format: (date, formatStr)->
    date = new Date date
    if formatStr is 'yyyy/mm/dd HH:MI:ss'
      return "#{date.getFullYear()}/#{@getStr(date.getMonth()+1)}/#{@getStr(date.getDate())} #{@getStr(date.getHours())}:#{@getStr(date.getMinutes())}:#{@getStr(date.getSeconds())}"
    if formatStr is 'yyyy/mm/dd'
      return "#{date.getFullYear()}/#{@getStr(date.getMonth()+1)}/#{@getStr(date.getDate())}"
    if formatStr is 'yyyy年mm月dd日'
      return "#{date.getFullYear()}年#{@getStr(date.getMonth()+1)}月#{@getStr(date.getDate())}日"
    if formatStr is 'yyyymmddHHMIss'
      return "#{date.getFullYear()}#{@getStr(date.getMonth()+1)}#{@getStr(date.getDate())}#{@getStr(date.getHours())}#{@getStr(date.getMinutes())}#{@getStr(date.getSeconds())}"
    if formatStr is 'yyyy-mm-dd'
      return "#{date.getFullYear()}-#{@getStr(date.getMonth()+1)}-#{@getStr(date.getDate())}"
    if formatStr is 'yymmddhhMIssSS'
      ms = @getStr(date.getMilliseconds())
      if ms.length is 1
        ms ='00'+ms
      if ms.length is 2
        ms = '0'+ms
      return "#{@getStr(date.getFullYear().toString().substring(2))}#{@getStr(date.getMonth()+1)}#{@getStr(date.getDate())}#{@getStr(date.getHours())}#{@getStr(date.getMinutes())}#{@getStr(date.getSeconds())}#{ms}"
  parse: ()->

}

admin = {
  check: (req)->
    admin = session.getAdmin req
    return admin?
}

#RenderFunc = {
#
#}
#TEMPLATE_MAPPING = {
#	app: 'mobile'
#}

#_.templateSettings = {
#	interpolate: /\{\{(.+?)\}\}/g
#};

#_.templateSettings = {
#	evaluate    : /(?:&lt;|<)%([\s\S]+?)%(?:&gt;|>)/g,
#	interpolate : /(?:&lt;|<)%=([\s\S]+?)%(?:&gt;|>)/g,
#	escape      : /(?:&lt;|<)%-([\s\S]+?)%(?:&gt;|>)/g
#};

#template = {
#	initRenderFunc: (name, path)->
#		template.readFile path, (content, renderFunc)->
#			RenderFunc[name] = renderFunc
#	readFile: (path, cb)->
#		fs.readFile path, (err, content)->
#			if err then content = ''
#			content = content.toString()
##			console.log path
#			renderFunc = _.template content
#			cb?(content, renderFunc)
#	getRenderFunc: (name)->
#		if config.productENV isnt true
#			return @getRenderFuncSync name
#		name = TEMPLATE_MAPPING[name] ? name
#		func = RenderFunc[name]
#		return func
#	getRenderFuncSync: (name)->
#		name = TEMPLATE_MAPPING[name] ? name
#		appConfig = config.app or {}
#		path = appConfig[name]
#		content = ''
#		if path
#			content = fs.readFileSync(appConfig[name]) ? ''
#			content = content.toString()
#		renderFunc = _.template content
#		return renderFunc
#	getRenderFuncAsync: (name, cb)->
#		name = TEMPLATE_MAPPING[name] ? name
#		appConfig = config.app or {}
#		template.readFile appConfig[name], (content, renderFunc)->
##			RenderFunc[name] = renderFunc
#			cb?(renderFunc)
#	refresh: ()->
#		appConfig = config.app or {}
#		for name, path of appConfig
#			name = TEMPLATE_MAPPING[name] ? name
#			template.initRenderFunc name, path
#}
#
#template.refresh()
#setInterval ()->
#	template.refresh()
#, 30000

app = {
  calViewCount: (appCreatetime, appcount={})->
# console.log appCreatetime, appcount
    if not appCreatetime or (new Date(appCreatetime)).getTime() < (new Date(config.caculateAppTime)).getTime()
      viewCount = appcount.viewcount
      POW_NUM = 599 / 500
      POW_LINE = 500
      LINE_NUM = parseInt(Math.pow(1000000, 1 / POW_NUM))
      if viewCount > LINE_NUM
        viewCount = parseInt(viewCount - LINE_NUM) + parseInt(Math.pow(LINE_NUM, POW_NUM))
      else if viewCount > POW_LINE
        viewCount = parseInt(Math.pow(viewCount, POW_NUM))
    else
      viewCount = appcount.displayviewcount
    return viewCount
  getUrl: (app)->
    src = "#{config.base_url}/app/render/#{app.id}"
    if app.shorturl
      src = "#{config.base_url}/m/#{app.shorturl}"
    return src

  getRatio: (countgap, secondGap, timestamp)->
    hour = (new Date(timestamp)).getHours()
    ratio = Math.ceil(countgap/secondGap)
    if hour > 0 and hour <= 5
      if ratio > 1
        ratio = 1
    else if hour > 5 and hour <= 19
      if ratio > 5
        ratio = 5
    else if hour > 19 and hour <= 23
      if ratio > 8
        ratio = 8
    else
      if ratio > 5
        ratio = 5
    return ratio
}

getFormData = (data)->
  params = {}
  cols = JSON.parse data.cols
  if cols
    for col in cols
      params[col] = data[col]
  return params

# 需要更新的字段
# optsArr = ['type', 'name', 'desc', 'imgurl', 'order', 'sort']
getFilteField = (fieldArr=[], params)->
  opts = {}
  if not fieldArr
    return opts

  for key, value of params
    if key in fieldArr
      if value
        opts[key] = value

  return opts

getRandom = (len=1)->
  div = Math.pow 10, len
  str = (Math.ceil(Math.random()*div)).toString()
  strSize = str.length
  for i in [strSize...len]
    str = '0' + str
  return str

getDateString = (date)->
  year = (date.getFullYear()).toString()
  month = date.getMonth() + 1
  day = date.getDate()
  hours = date.getHours()
  minute = date.getMinutes()
  if month < 10
    month = '0'+ month
  if day < 10
    day = '0' + day
  if hours < 10
    hours = '0'+hours
  if minute < 10
    minute = '0'+minute
  return year+month+day+hours+minute

ShortUrlChars = [
  "a","b","c","d","e","f","g","h",
  "i","j","k","l","m","n","o","p",
  "q","r","s","t","u","v","w","x",
  "y","z","0","1","2","3","4","5",
  "6","7","8","9","A","B","C","D",
  "E","F","G","H","I","J","K","L",
  "M","N","O","P","Q","R","S","T",
  "U","V","W","X","Y","Z"
]

getShortUrl = (oriurl)->
  md5Key = 'rabbitpre'
  hex = crypto.createHash('md5').update(md5Key+oriurl).digest('hex')

  subHexLen = hex.length / 8
  shortUrl = []
  for i in [0...subHexLen]
    outChars = ''
    j = i + 1
    subHex = hex.substring(i*8, j*8)
    idx = parseInt('3FFFFFFF',16) & parseInt(subHex,16)
    for k in [0...6]
      index = parseInt('0000003D',16) & idx
      outChars += ShortUrlChars[index]
      idx = idx >> 5

    shortUrl[i] = outChars
  random = parseInt(Math.random()*4)
  return shortUrl[random] ? shortUrl[0]

getShortUrlV2 = (oriurl, ranLen=8)->
  if ranLen is 8
    calLen = 3
  else
    calLen = 5
  md5Key = 'rabbitpre'
  hex = crypto.createHash('md5').update(md5Key+oriurl).digest('hex')

  subHexLen = hex.length / 8
  shortUrl = []
  for i in [0...subHexLen]
    outChars = ''
    j = i + 1
    subHex = hex.substring(i*8, j*8)
    idx = parseInt('3FFFFFFF',16) & parseInt(subHex,16)
    for k in [0...ranLen]
      index = parseInt('0000003D',16) & idx
      outChars += ShortUrlChars[index]
      idx = idx >> calLen

    shortUrl[i] = outChars
  random = parseInt(Math.random()*4)
  url = shortUrl[random] ? shortUrl[0]
  url = url + ShortUrlChars[parseInt(Math.random()*ShortUrlChars.length)]
  return url

createInviteCode = (data, key) ->
  cipheriv = (en, code, data) ->
    buf1 = en.update(data, code)
    buf2 = en.final()
    r = new Buffer(buf1.length + buf2.length)
    buf1.copy r
    buf2.copy r, buf1.length
    return r
  return cipheriv(crypto.createCipher('des', key), "UTF8", data).toString "base64"


getUniqueValue = (ranLen=8)->
  if ranLen is 8
    calLen = 3
  else
    calLen = 5
  md5Key = 'killerwhale'
  oriurl = uuid.v4()
  hex = crypto.createHash('md5').update(md5Key+oriurl).digest('hex')

  subHexLen = hex.length / 8
  shortUrl = []
  for i in [0...subHexLen]
    outChars = ''
    j = i + 1
    subHex = hex.substring(i*8, j*8)
    idx = parseInt('3FFFFFFF',16) & parseInt(subHex,16)
    for k in [0...ranLen]
      index = parseInt('0000003D',16) & idx
      outChars += ShortUrlChars[index]
      idx = idx >> calLen

    shortUrl[i] = outChars
  random = parseInt(Math.random()*4)
  url = shortUrl[random] ? shortUrl[0]
  url = url + ShortUrlChars[parseInt(Math.random()*ShortUrlChars.length)]
  return url

client =
  getIp: (req)->
    headers = req.headers ? {}
    ip = headers['x-forwarded-for']
    if ip
      return ip

    connection = req.connection ? {}
    ip = connection.remoteAddress
    if ip
      return ip

    socket = req.socket ? {}
    ip = socket.remoteAddress
    if ip
      return ip

    connection = req.connection ? {}
    socket = connection.socket ? {}
    ip = socket.remoteAddress
    return ip
  isMobile: (req)->
    headers = req.headers ? {}
    return /mobile|nokia|.*iPhone.*|android|samsung|htc|blackberry|windows phone|LG|SonyEricsson|MOT|opera mini|j2me|mqqbrowser|lenovo|uc( )?web|symbian/i.test(headers['user-agent'] or '')
  useMobile: (req)->
    return req.query.mobile or @isMobile(req)
wrapUrl = (url, cnl_suffix)->
  if url.indexOf('?') is -1
    return "#{url}?#{cnl_suffix}"
  else
    return "#{url}&#{cnl_suffix}"

#字典升序排序
raw = (args)->
  keys = Object.keys(args)
  keys = keys.sort()
  newArgs = {}
  for key in keys
    newArgs[key] = args[key]
  string = ''
  for k, value of newArgs
    string += '&' + k + '=' + value
  string = string.substr(1)
  return string

module.exports = {
  encrypt: encrypt
  decrypt: decrypt
  session: session
  admin: admin
  error: error
  resmessage: resmessage
  app: app
#template: template
  common: common
  getFormData: getFormData
  getDateString: getDateString
  getFilteField: getFilteField
  getShortUrl: getShortUrl
  getShortUrlV2: getShortUrlV2
  createInviteCode: createInviteCode
  getRandom: getRandom
  getUniqueValue: getUniqueValue
  client: client
  date: DateUtil
  wrapUrl:wrapUrl
  DateUtil:DateUtil
  raw:raw
}