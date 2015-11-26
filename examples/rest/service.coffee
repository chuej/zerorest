ZMS = require '../../src'

startProvider = ()->
  zms = new ZMS("tcp://#{process.env.HOST}:#{process.env.PORT}")

  zms.use require "../../src/adapters/rest"
  zms.use (req, res, next)->
    #middleware
    return next null

  users = zms.master("/users")
  users.use (req, res, next)->
    return next null
    # /users specific middleware
  users.worker "/findById", (req, res, next)->
    id = req.params.id
    user =
      id: id
    res.json user: user
  users.worker "/update", (req, res, next)->
    id = req.params.id
    user =
      id: id
    res.setStatus 201
    res.json
      user: user
      req: req
  templates = zms.master("/templates")
  templates.worker "/html", (req, res, next)->
    res.send "<html></html>"
  zms.use (err, req, res, next)->
    res.send "ERROR"
    #error handler
    #calling next w/ err will trigger default res.error
  zms.start()
startProvider()
