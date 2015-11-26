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
      @path = "/master"
      @master = @service.master @path
      @afterFn = (err, req, res, next)->
      @service.use @afterFn
    describe 'use', ()->

      it 'should push fn to @before', ()->
        assert.equal @service.before[0], @beforeFn
      it 'should push fn to @after if fn takes error', ()->
        assert.equal @service.after[0], @afterFn
    describe 'master', ()->
      it 'should create new master with given path', ()->
        assert.equal @master.path, @path
      it 'should create new master with @url, @before, and @after', ()->
        assert.equal @master.before.length, @service.before.length
        assert.equal @master.after.length, @service.after.length
        assert.equal @master.url, @service.url
      it 'should push master to @masters', ()->
        assert.equal @service.masters[0], @master
    describe 'start', ()->
      before (done)->
        @service.masters[0].start = ()=>
          @masterStarted = true
        @service.on 'brokerStart', ()=>
          @brokerStarted = true
          return done null
        @service.start()
      it 'should start broker', ()->
        assert @brokerStarted
      it 'should start masters', ()->
        assert @masterStarted
    describe 'stop', ()->
      before (done)->
        @service.masters[0].stop = ()=>
          @masterStopped = true
        @service.on 'brokerStop', ()=>
          @brokerStopped = true
          return done null
        @service.stop()
      it 'should start broker', ()->
        assert @brokerStopped
      it 'should start masters', ()->
        assert @masterStopped
