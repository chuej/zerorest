URL = "tcp://0.0.0.0:5678"
assert = require 'assert'
Client = require './client'


describe 'zms client', ()->
  before (done)->
    @zms = startService()
    @client = new Client URL
    @opts =
      params:
        id: '1234'
      body:
        data: hello: "world"
      headers:
        method: 'PATCH'
      copts:
        timeout: 10000
    @zms.on 'start', ()=>
      @stream = @client.request '/users/update',  @opts
      @client.request '/users/update', @opts, (err, @resp)=>
        return done err if err
        @body = @resp.body
        @client.request '/users/html', @opts, (err, @htmlResp)=>
          return done err if err
          @client.request '/users/error', @opts, (@err, @errResp)=>
            return done err
    @client.start()
  context 'callback mode', ()->
    it 'should have resp', ()->
      assert @resp
    it 'should have a body', ()->
      assert @resp.body
    context 'resp body from service', ()->
      it 'should have params.id as user.id', ()->
        assert @body.user.id
      it 'should have req', ()->
        assert @body.req.params.id
    context 'resp from service', ()->
      it 'should have headers', ()->
        assert @resp.headers
      it 'should have status', ()->
        assert @resp.statusCode
  context 'streaming mode', ()->
    before (done)->
      @resp = ''
      @stream.on 'data', (data)=>
        @resp += data
      @stream.on 'end', ()->
        return done null
    it 'should be able to compose data into string result', ()->
      assert @resp.length > 0
  context 'html request', ()->
    it 'should respond with raw text', ()->
      assert.equal @htmlResp, "<html></html>"
  context 'error response', ()->
    it 'should return with error from route', ()->
      assert.equal @err.message, "Error from service: ERROR"
  after ()->
    @zms.stop()
    @client.stop()
startService = ->
  ZMS = require './service'

  startProvider = ()->
    zms = new ZMS
      url: URL
      noFork: true
    users = zms.router("/users")

    users.route "/update", (req, res, next)->
      id = req.params.id
      user =
        id: id
      res.setHeaders
        'hello': 'world'
      res.setStatus 201
      res.json
        user: user
        req: req
    users.route "/html", (req, res, next)->
      res.send "<html></html>"
    users.route "/error", (req, res, next)->
      res.error new Error 'ERROR'
    zms.start()
    return zms
  return startProvider()
