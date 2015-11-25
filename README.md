# Zeromicro : for building zeromq microservices

## Usage
```coffee
ZM = require 'zeromicro'

startProvider = ()->
  zm = ZM("tcp://localhost:55555")

  zm.use (req, res, next)->
    #middleware
    return next null

  users = zm.master("/users")
  users.use (req, res, next)->
    # /users specific middleware
  users.worker "/findById", (req, res, next)->
    id = req.params.id
    user =
      id: id
    res.send "FOUND", user: user

  zm.on 'WorkerError', (err, req, res, next)->
    #error handler
  zm.start()
```
