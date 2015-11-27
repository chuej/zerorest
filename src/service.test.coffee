Service = require './service'
assert = require 'assert'

describe 'service provider', ()->
  before ()->
    @url = "tcp://127.0.0.1:5555"
    @service = new Service @url
  context 'constructor', ()->
    it 'should set url', ()->
      assert.equal @url, @service.url
    it 'should create broker', ()->
      assert @service.broker?
  context 'methods', ()->
    before ()->
      @beforeFn = (req, res, next)->
      @service.use @beforeFn
      @path = "/router"
      @router = @service.router @path
      @afterFn = (err, req, res, next)->
      @service.use @afterFn
    describe 'use', ()->

      it 'should push fn to @before', ()->
        assert.equal @service.before[0], @beforeFn
      it 'should push fn to @after if fn takes error', ()->
        assert.equal @service.after[0], @afterFn
    describe 'router', ()->
      it 'should create new router with given path', ()->
        assert.equal @router.path, @path
      it 'should create new router with @url, @before, and @after', ()->
        assert.equal @router.before.length, @service.before.length
        assert.equal @router.after.length, @service.after.length
        assert.equal @router.url, @service.url
      it 'should push router to @routers', ()->
        assert.equal @service.routers[0], @router
      context 'error', ()->
        before (done)->
          @service.on 'RouterError', (@err)=>
            @routerErrEmitted = true
            return done null
          @router.emit 'error', new Error("error")
        it 'should trigger RouerError', ()->
          assert @err
          assert @routerErrEmitted
    describe 'start', ()->
      before (done)->
        @service.routers[0].start = ()=>
          @routerStarted = true
        @service.on 'BrokerStart', ()=>
          @brokerStarted = true
          return done null
        @service.start()
      it 'should start broker', ()->
        assert @brokerStarted
      it 'should start routers', ()->
        assert @routerStarted
    describe 'stop', ()->
      before (done)->
        @service.routers[0].stop = ()=>
          @routerStopped = true
        @service.on 'BrokerStop', ()=>
          @brokerStopped = true
          return done null
        @service.stop()
      it 'should start broker', ()->
        assert @brokerStopped
      it 'should start routers', ()->
        assert @routerStopped
