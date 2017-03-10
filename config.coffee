path = require "path"
fs = require "fs"
_ENV_ = require('./namespace.coffee')('ZEROICE')
port = 7003
host = "http://localhost:#{port}"
base_url = _ENV_('HOST') or host


#mongo库配置
SESSION_HOST = _ENV_('SESSION_HOST') or '192.168.99.100'
SESSION_PORT = _ENV_('SESSION_PORT') or '27017'
SESSION_USER = _ENV_('SESSION_USER') or ''
SESSION_PASS = _ENV_('SESSION_PASS') or ''




config = {
  host: host
  run_port: port
  base_url: base_url
  base_path: __dirname
  script_ext: '.coffee'
  isdev: base_url.indexOf("localhost") isnt -1
  session: {
    host: SESSION_HOST
    port: SESSION_PORT
#    username: SESSION_USER
#    password: SESSION_PASS
    db: 'audience'
    secret: '12345678'
  }


  rainbow: {
    controllers: '/controllers/'
    filters: '/filters/'
    template: '/views/'
  }
  defaultdb: 'godieDB'   #主库
#readonlydbs: ['kafkaDB', 'kafkaDB1', 'kafkaDB2']
  readonlydbs: ['godieDB']
  dbconfig: {
    godieDB: {
      host: _ENV_('DB_SERVER_W') or '192.168.99.100'
      database: _ENV_('DB_NAME_W') or 'godiedb'#_test
      username: _ENV_('DB_USER_W') or 'root'
      password: _ENV_('DB_PWORD_W') or 'zeroiice'
      type: 'mysql'
      logging: false
    }

  }

  #根节点数组
  initprogress: ['1000','1001']

}




module.exports = config