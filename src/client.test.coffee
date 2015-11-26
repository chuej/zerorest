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
    @stream = @client.request '/users/update',  @opts
    @client.request '/users/update', @opts, (err, @resp)=>
      return done err if err
      @body = @resp.body
      @client.request '/users/html', @opts, (err, @htmlResp)=>
        return done err
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
        assert @resp.status
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
  after ()->
    @zms.stop()
    @client.stop()
startService = ->
  ZMS = require './service'

  startProvider = ()->
    zms = new ZMS(URL)
    zms.use require "./adapters/rest"
    users = zms.master("/users")

    users.worker "/update", (req, res, next)->
      id = req.params.id
      user =
        id: id
      res.setHeaders
        'hello': 'world'
      res.setStatus 201
      res.json
        user: user
        req: req
    users.worker "/html", (req, res, next)->
      res.sendRaw "<html></html>"
    zms.start()
    return zms
  return startProvider()
