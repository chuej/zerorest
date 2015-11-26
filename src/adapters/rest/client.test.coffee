URL = "tcp://0.0.0.0:5678"
assert = require 'assert'
Client = require './client'


describe 'zms client', ()->
  before (done)->
    @zms = startService()
    client = new Client URL
    opts =
      params:
        id: '1234'
      body:
        data: hello: "world"
      headers:
        method: 'PATCH'
      clientOpts:
        timeout: 10000
    client.request '/users/update', opts, (err, @resp, @body)=>
      return done err
      #resp should be entire response obj
      #body should resp.body
  it 'should have resp', ()->
    console.log @resp
    assert @resp
  after ()->
    @zms.stop()
    delete @zms
startService = ->
  ZMS = require '../../service'

  startProvider = ()->
    zms = new ZMS(URL)

    users = zms.master("/users")

    users.worker "/update", (req, res, next)->
      id = req.params.id
      user =
        id: id
      res.json
        user: user
        req: req

    zms.start()
    return zms
  return startProvider()
