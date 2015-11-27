assert = require 'assert'

Worker = require './worker'
Broker = require './broker'

describe 'worker', ()->
  before (done)->
    @initUrl = "tcp://0.0.0.0:5555"
    @broker = new Broker @initUrl
    @broker.on 'start', ()=>
      opts =
        url: @initUrl
        path: '/worker/create'
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
