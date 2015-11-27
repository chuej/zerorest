assert = require 'assert'

Broker = require './broker'

describe 'broker', ()->
  before ()->
    @initUrl = "tcp://*:5555"
    @mockBroker = (@url)=>
      return @mockBroker
    @mockBroker.start = (next)=>
      @startCalled = true
      @callOnStart()
      return next null
    @mockBroker.stop = (next)=>
      @stopCalled = true
      @callOnStop()
      return next null
    @mockBroker.onStart = (@callOnStart)=>
      return
    @mockBroker.onStop = (@callOnStop)=>
      return
    opts =
      url: @initUrl
      broker: @mockBroker
    @broker = Broker(opts)

  it 'should create a new pigato broker w/ url', ()->
    assert.equal @url, @initUrl
  it 'should have a url property for workers to connect to', ()->
    assert.equal @broker._url, @initUrl

  describe 'on start', ()->
    before (done)->
      @broker.on 'start', ()=>
        @brokerStartEvent = true
      @broker.start done
    it 'should have the status "started"', ()->
      assert @broker.status is 'started'
    it 'should start pigato broker', ()->
      assert @startCalled
    it 'should fire start event', ()->
      assert @brokerStartEvent
  describe 'on stop', ()->
    before (done)->
      @broker.on 'stop', ()=>
        @brokerStopEvent = true
      @broker.stop done

    it 'should have the status "stopped"', ()->
      assert @broker.status is 'stopped'
    it 'should stop pigato broker', ()->
      assert @stopCalled
    it 'should fire start event', ()->
      assert @brokerStopEvent
