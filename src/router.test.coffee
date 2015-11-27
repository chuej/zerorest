Router = require './router'
assert = require 'assert'
Broker = require('pigato').Broker
Client = require('pigato').Client
describe 'socket router', ()->
  before ()->
    @before =[
      (req, res, next)=>
        @beforeHit = true
        return next null
    ]
    @after = [
      (err, req, res, next)=>
        @afterHit = true
        return next err
    ]
    @url = "tcp://127.0.0.1:5555"
    @workerPath = "/findById"
    @errorPath = "/error"
    @path = "/router"
    opts =
      before: @before
      after: @after
      url: @url
      path: @path
    @router = new Router opts
    @router.on "error", (err)->
      throw err
  context 'constructor', ()->
    it 'should set @before, @after, @url, and @path', ()->
      assert.deepEqual @router.before, @before
      assert.deepEqual @router.after, @after
      assert.equal @router.path, @path
      assert.equal @router.url, @url
  context 'methods', ()->
    before ()->
      @beforeFn = (req, res, next)->
        assert req.copts
        return next null
      @afterFn = (err, req, res, next)->
        return next err
      @router.use @beforeFn
      @cb = (req, res, next)->
        res.end req

      @router.route @workerPath, @cb
      @router.use @afterFn
    describe 'use', ()->

      it 'should push middleware function to @before', ()->
        assert.equal @beforeFn, @router.before[1]
      it 'should push middleware functions to @localAfter if fn takes error', ()->
        assert.equal @afterFn, @router.localAfter[0]
    describe 'worker', ()->
      it 'should push worker config to @workers', ()->
        assert.equal @router.routes.length, 1
        assert.equal @router.routes[0].path, @workerPath
        assert.equal @router.routes[0].cb, @cb
    describe 'worker returning error', ()->
      before ()->

        @cbError = (req, res, next)->
          return next new Error('ERROR!')
        @router.route @errorPath, @cbError
      it 'should push worker config to @workers', ()->
        assert.equal @router.routes.length, 2
        assert.equal @router.routes[1].path, @errorPath
        assert.equal @router.routes[1].cb, @cbError
    describe 'start', ()->
      before (done)->
        conf =
          onStart: ()=>
            @router.start()
        @broker = new Broker @url, conf
        @broker.start()
        @client = new Client @url
        @client.start()
        @client.on 'error', (err)->
          throw err
        @client.request "#{@path}#{@workerPath}", {args:'args'}, (->), (err, @data)=>
          return done null
      it 'should create workers from worker config that connect to broker', ()->
        assert @data
      it 'should run @before on request', ()->
        assert @beforeHit
      context 'request handler errrors', ()->
        before (done)->
          @client.request "#{@path}#{@errorPath}", {args:'args'}, (->), (err, @errData)=>
            @errData = JSON.parse(@errData)
            return done null
        it 'should run @after', ()->
          assert @afterHit
        it 'should run default err handler if res.error is not sent', ()->
          assert.equal @errData.error.message, "ERROR!"
