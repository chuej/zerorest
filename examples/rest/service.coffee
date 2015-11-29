ZMS = require '../../src'
host = process.env.HOST or "0.0.0.0"
port = process.env.PORT or "5000"

startProvider = ()->
  zms = new ZMS("tcp://#{host}:#{port}")

  zms.use (req, res, next)->
    #middleware
    return next null

  users = zms.router("/users")
  users.use (req, res, next)->
    return next null
    # /users specific middleware
  users.route "/findById", (req, res, next)->
    id = req.params.id
    user =
      id: id
    res.json user: user
  users.route "/update", (req, res, next)->
    id = req.params.id
    user =
      id: id
    res.setStatus 201
    res.json
      user: user
      req: req
  templates = zms.router("/templates")
  templates.route "/html", (req, res, next)->
    res.send "<html></html>"
  zms.use (err, req, res, next)->
    err.stack = null # hide stack
    res.error err
    #error handler
    #calling next w/ err will trigger default res.error
  zms.start()
startProvider()
