# ZeroMS : for building zeromq microservices

## Usage
```coffee
ZM = require 'zeromicro'

startService = ()->
  zms = new ZMS("tcp://0.0.0.0:5555")

  zms.use require "../../src/adapters/rest"
  zms.use (req, res, next)->
    #middleware
    return next null

  users = zms.master("/users")
  users.use (req, res, next)->
    return next null
    # /users specific middleware
  users.use (err, req, res, next)->
    return next err
    # /users specific error handler
    # calling next w/ error will continue on to service error handlers
  users.worker "/findById", (req, res, next)->
    res.json user: id: req.params.id
  users.worker "/update", (req, res, next)->
    res.setStatus 201
    res.json
      user: id: req.params.id


  templates = zms.master("/templates")
  templates.worker "/html", (req, res, next)->
    res.send "<html></html>"

  zms.use (err, req, res, next)->
    res.send "ERROR"
    #error handler
    #calling next w/ err will trigger default res.error
  zms.start()
startService()

```
```coffee
Client = require('zeromicro').Client
client = new Client "tcp://0.0.0.0:5555"
client.on 'start', ()->
  opts =
    params:
      id: '1234'
    body:
      data: hello: "world"
    headers:
      method: 'PATCH'
    copts:
      timeout: 100000
  client.request '/users/update', opts, (err, resp)->
    # resp is json
    console.log resp

  opts =
    params:
      id: '4321'
  client.request '/templates/html', opts, (err,resp)->
    # resp is html
    console.log resp

  resp = ''
  stream = client.request '/users/findById', opts
  stream.on 'data', (data)->
    resp += data
  stream.on 'end', ()->
    #resp is stringified json
    console.log resp
```
