assert = require 'assert'

Broker = require './broker'

describe 'broker', ()->
  before ()->
    @initUrl = "tcp://*:5555"
    @heartbeat = 5000
    @lbmode = 'rand'
    @concurrency = 2
    opts =
      url: @initUrl
      heartbeat: @heartbeat
      lbmode: @lbmode
      concurrency: @concurrency
    @broker = new Broker opts

  it 'should have a url property for workers to connect to', ()->
    assert.equal @broker.url, @initUrl
    assert.equal @broker.heartbeat, @heartbeat
    assert.equal @broker.lbmode, @lbmode
    assert.equal @broker.concurrency, @concurrency
  describe 'on start', ()->
    before (done)->
      @broker.on 'start', ()=>
        @brokerStartEvent = true
        return done null
      @broker.start()
    it 'should fire start event', ()->
      assert @brokerStartEvent
    it 'should have num brokers equal to concurrency', ()->
      assert.equal @broker.num, @concurrency
  describe 'on stop', ()->
    before (done)->
      @broker.on 'stop', ()=>
        @brokerStopEvent = true
        return done null
      @broker.stop()
    it 'should fire start event', ()->
      assert @brokerStopEvent
