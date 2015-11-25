ZMS = require '../../src/service'

startProvider = ()->
  zms = new ZMS("tcp://0.0.0.0:55555")

  zms.use (req, res, next)->
    #middleware
    return next null

  users = zms.master("/users")
  users.use (req, res, next)->
    # /users specific middleware
  users.worker "/findById", (req, res, next)->
    id = req.params.id
    user =
      id: id
    res.send user: user

  zms.use (err, req, res, next)->
    #error handler
  zms.start()
startProvider()
