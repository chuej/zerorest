assert = require 'assert'
pigato = require 'pigato'

Worker = require './worker'

describe 'worker', ()->
  before ()->
    @initUrl = "tcp://*:5555"
    @broker =
      on: (@callOnBrokerStart)->

    opts =
      url: @initUrl
      path: '/worker/create'
      broker: @broker
    @worker = new Worker opts
    @workers.on 'starting', ()=>
      @brokerStatusOnWorkerConnect = @broker.status
    @wokers.on 'start', ()=>
      @workersConnected = true
  it 'should only connect after broker starts', ()->
    assert.equal @brokerStatusOnWorkerConnect, 'started'
  it 'should all connect', ()->
    assert @workersConnected
