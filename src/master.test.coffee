Master = require './master'
assert = require 'assert'
Broker = require('pigato').Broker
Client = require('pigato').Client
describe 'task master', ()->
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
    @path = "/master"
    opts =
      before: @before
      after: @after
      url: @url
      path: @path
    @master = new Master opts
    @master.on "WorkerError", (err)->
      throw err
  context 'constructor', ()->
    it 'should set @before, @after, @url, and @path', ()->
      assert.deepEqual @master.before, @before
      assert.deepEqual @master.after, @after
      assert.equal @master.path, @path
      assert.equal @master.url, @url
  context 'methods', ()->
    before ()->
      @beforeFn = (req, res, next)->
        assert res.copts
        return next null
      @afterFn = (err, req, res, next)->
        return next err
      @master.use @beforeFn
      @cb = (req, res, next)->
        res.end req

      @master.worker @workerPath, @cb
      @master.use @afterFn
    describe 'use', ()->

      it 'should push middleware function to @before', ()->
        assert.equal @beforeFn, @master.before[1]
      it 'should push middleware functions to @localAfter if fn takes error', ()->
        assert.equal @afterFn, @master.localAfter[0]
    describe 'worker', ()->
      it 'should push worker config to @workers', ()->
        assert.equal @master.workers.length, 1
        assert.equal @master.workers[0].path, @workerPath
        assert.equal @master.workers[0].cb, @cb
    describe 'worker returning error', ()->
      before ()->

        @cbError = (req, res, next)->
          return next new Error('ERROR!')
        @master.worker @errorPath, @cbError
      it 'should push worker config to @workers', ()->
        assert.equal @master.workers.length, 2
        assert.equal @master.workers[1].path, @errorPath
        assert.equal @master.workers[1].cb, @cbError
    describe 'start', ()->
      before (done)->
        conf =
          onStart: ()=>
            @master.start()
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
        it 'should run default err handler if res is not sent', ()->
          assert.equal @errData.message, "ERROR!"
