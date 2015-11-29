assert = require 'assert'

Worker = require './worker'
Broker = require './broker'

describe 'worker', ()->
  before (done)->
    @initUrl = "tcp://0.0.0.0:5555"
    @broker = new Broker url: @initUrl
    @broker.on 'start', ()=>
      @concurrency = 2
      @heartbeat = 500
      @reconnect = 500
      @socketConcurrency = 500
      opts =
        url: @initUrl
        path: '/worker/create'
        concurrency: @concurrency
        socketConcurrency: @socketConcurrency
        heartbeat: @heartbeat
        reconnect: @reconnect
      @worker = new Worker opts
      @worker.on 'start', ()=>
        @startEmitted = true
        return done null
      @worker.start()
    @broker.start()
  after ()->
    @worker.stop()
    @broker.stop()
  it 'should emit start event when connected', ()->
    assert @startEmitted
  it 'should set options', ()->
    assert.equal @worker.concurrency, @concurrency
    assert.equal @worker.heartbeat, @heartbeat
    assert.equal @worker.reconnect, @reconnect
    assert.equal @worker.socketConcurrency, @socketConcurrency
  it 'should have num workers equal to concurrency', ()->
    assert.equal @worker.num, @concurrency
