assert = require 'assert'

Broker = require './broker'

describe 'broker', ()->
  before ()->
    @initUrl = "tcp://*:5555"
    @broker = new Broker @initUrl

  it 'should have a url property for workers to connect to', ()->
    assert.equal @broker.url, @initUrl

  describe 'on start', ()->
    before (done)->
      @broker.on 'start', ()=>
        @brokerStartEvent = true
        return done null
      @broker.start()
    it 'should fire start event', ()->
      assert @brokerStartEvent
  describe 'on stop', ()->
    before (done)->
      @broker.on 'stop', ()=>
        @brokerStopEvent = true
        return done null
      @broker.stop()
    it 'should fire start event', ()->
      assert @brokerStopEvent
