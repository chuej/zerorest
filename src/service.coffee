EventEmitter = require('events').EventEmitter
Master = require './master'
Broker = require('pigato').Broker
async = require 'async'

class Service extends EventEmitter
  constructor: (url)->
    @url = url
    brokerConf =
      onStart: ()=>
        @emit 'brokerStart'
        async.each @masters, (master, cb)->
          master.start()
          return cb null
      onStop: ()=>
        @emit 'brokerStop'
        async.each @masters, (master, cb)->
          master.stop()
          return cb null
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
