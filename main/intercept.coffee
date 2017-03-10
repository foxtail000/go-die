

intercept =

# 拼接参数值的字符串
  str: ""

# 获取数组的value的字符串
  getArrVal: (params) ->
    if params instanceof Array
      for k, v of params
        if v instanceof Array
          this.getArrVal(v)
        else
          this.str = this.str + v
      return this.str
    else
      return params

# 检测参数是否存在攻击
  checkAttack: (params, pattern) ->
    ret = false
    if params?
      filter = new RegExp(pattern)
      for k, v of params
        if(filter.test(v))
          ret = true
        if(filter.test(k))
          ret = true
    return ret


# 过滤post 数据
  filterPost: (params) ->
    ret = null
    if  params?
      postPattern = "/^\\+\/v(8|9)|\\b(and|or)\\b.{1,6}?(=|>|<|\\bin\\b|\\blike\\b)|\\/\\*.+?\\*\\/|<\\s*script\\b|<\\s*img\\b|\\bEXEC\\b|UNION.+?SELECT|UPDATE.+?SET|INSERT\\s+INTO.+?VALUES|(SELECT|DELETE).+?FROM|(CREATE|ALTER|DROP|TRUNCATE)\\s+(TABLE|DATABASE)/is"
      ret = this.checkAttack(params, postPattern)
    return ret


# 过滤get 数据
  filterGet: (params) ->
    ret = null
    if params?
      getPattern = "/'|\b(alert|confirm|prompt)\b|<[^>]*?>|^\\+\/v(8|9)|\\b(and|or)\\b.+?(>|<|=|\\bin\\b|\\blike\\b)|\\/\\*.+?\\*\\/|<\\s*script\\b|\\bEXEC\\b|UNION.+?SELECT|UPDATE.+?SET|INSERT\\s+INTO.+?VALUES|(SELECT|DELETE).+?FROM|(CREATE|ALTER|DROP|TRUNCATE)\\s+(TABLE|DATABASE)/is";
      ret = this.checkAttack(params, getPattern)
    return ret

# 过滤cookie 数据
  fileterCookie: (params) ->
    ret = null
    if params?
      cookiePattern = "/\\b(and|or)\\b.{1,6}?(=|>|<|\\bin\\b|\\blike\\b)|\\/\\*.+?\\*\\/|<\\s*script\\b|\\bEXEC\\b|UNION.+?SELECT|UPDATE.+?SET|INSERT\\s+INTO.+?VALUES|(SELECT|DELETE).+?FROM|(CREATE|ALTER|DROP|TRUNCATE)\\s+(TABLE|DATABASE)/is";
      ret = this.checkAttack(params, cookiePattern)
    return ret


module.exports = intercept