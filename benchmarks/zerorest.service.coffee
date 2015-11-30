ZMS = require '../src'

host = "0.0.0.0"
port = 5101
zms = new ZMS("tcp://#{host}:#{port}")

users = zms.router("")
users.route "echo", (req, res, next)->
  setImmediate ->
    res.end req
zms.start()
zms.on 'error',(err)->
  console.error err
