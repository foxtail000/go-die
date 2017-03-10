module.exports = (nameSpace)->
  return (key)->
    key = nameSpace + '_' + key
    process.env[key]