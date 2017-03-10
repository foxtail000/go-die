_ = require 'underscore'
http = require 'http'
path = require 'path'
bodyParser = require 'body-parser'
session = require 'express-session'
cookieParser = require 'cookie-parser'
MongoStore = require('connect-mongo')(session)
express = require 'express'
config = require '../config.coffee'
routes = require '../routes.coffee'
Util = require './Util.coffee'
intercept = require './intercept.coffee'

module.exports = (app)->

#  app.set 'port', config.run_port ? 8080
  app.set 'views', path.join(config.base_path, 'views')
  app.set 'view engine', 'jade'

  app.use(bodyParser.json())
  app.use(bodyParser.urlencoded({
    extended: true
    type: (req)->
      contentType = req.get('Content-Type')
      type = 'application/x-www-form-urlencoded'
      if not contentType
        return false
      if contentType.indexOf(type) > -1
        return type
      return false
  }))
  app.use(cookieParser())
  app.use session {
    resave: false
    saveUninitialized: false
    store: new MongoStore({
      host: config.session.host
      port: config.session.port
#      username: config.session.username
#      password: config.session.password
      db: config.session.db
      mongoOptions: {
        db: {authSource:'admin'}
      }
    })

    secret: config.session.secret
    cookie: {
      path: '/'
      httpOnly: true
      secure: false
      maxAge: 7 * 24 * 60 * 60 * 1000
    }
  }
  app.enable 'view cache'
  #暂时允许跨域
  app.use (req, res, next)->
#		req.headers['if-none-match'] = 'no-match-for-this'
    res.header("Access-Control-Allow-Origin", "*")
    res.header("Access-Control-Allow-Headers", "Content-Type,origin,Content-Length, Authorization, Accept,X-Requested-With")
    res.header("Access-Control-Allow-Methods","PUT,POST,GET,DELETE,OPTIONS")
    res.header("X-Powered-By", "3.2.2")
    next()
  #	app.use "/",(req,res,next)->
  #		console.log "【/】",req.path
  #		next()
  #静态页面访问拦截




  publicDir = path.join(__dirname, '../public')
  app.use('/', express.static(publicDir))

  app.use (req, res, next)->
    if req.query?
      if intercept.filterGet(req.query)
        return res.json {status:"error", msg:"get params invalid"}

    next()

  routes app

  app.use (err, req, res, next)->
    if err.data?
      res.jsonp Util.resmessage err.data,err.total
      return
    # EXCEPTION START
    console.log '===========error==========='
    console.log req.path
    console.log req.body
    console.log req.query
    console.log err
    isAjax = req.query.isAjax ? req.body.isAjax
    data = err.data # 存储重定向的信息
    page = 'error'
    status = 200
    if err.status?
      if err.status is 401
        status = 401
        #page = 'login'
        #401应该开个一个登录页
        #				path = req.originalUrl
        #				console.log path
        #				url = getConfig('host')+path
        #				console.log url
        #				return res.redirect(301, '/login.html?rd=' + encodeURIComponent(url));
        #?#{Util.getRandom(6)}
        return res.redirect(302,"/login.html");
#err = Util.error 'UNKNOW',1401,"PLEASE_LOGIN"
      else
        status = err.status
        err = Util.error (err.service or 'UNKNOW'),(1 + "#{status}"),(err.message or '')
    if not err.errcode?
      err = Util.error 'UNKNOW',1500,err
      status = 500
    res.status(status)
    if req.xhr is true
      res.jsonp err
      return
    res.render page,err
  # EXCEPTION END


  app.all '*',(req, res, next)->
    res.status(404)
    err = Util.error 'UNKNOW',1404,'not Found'
    if req.xhr is true
      return res.jsonp err
    res.render 'error', err

