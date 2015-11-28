piBroker = require('pigato').Broker
EventEmitter = require('events').EventEmitter

class Broker extends EventEmitter
  constructor: (url)->
    @url = url
    conf =
      onStart: ()=>
        @emit 'start'
      onStop: ()=>
        @emit 'stop'
      heartbeat: 20000
    @piBroker = new piBroker @url, conf


    @
  start: ()->
    @piBroker.start()
  stop: ()->
    @piBroker.stop()

module.exports = Broker
