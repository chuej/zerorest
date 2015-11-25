EventEmitter = require('events').EventEmitter
Master = require './master'
Broker = require('pigato').Broker

class Service extends EventEmitter
  constructor: (url)->
    @url = url
    brokerConf =
      onStart: ()=>
        @emit 'brokerStart'
        @masters.forEach (master)->
          master.start()
      onStop: ()=>
        @emit 'brokerStop'
        @masters.forEach (master)->
          master.stop()
    @broker = new Broker @url, brokerConf

    @
  before: []
  after: []
  masters: []
  use: (fn)->
    @before.push fn
  master: (path)->
    opts =
      path: path
      url: @url
      before: @before
      after: @after
    master = new Master opts
    @masters.push master
    return master
  start: ()->
    @broker.start()
  stop: ()->
    @broker.stop()
module.exports = Service
