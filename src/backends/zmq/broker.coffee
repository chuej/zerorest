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
    @piBroker = new piBroker @url, conf


    @
  start: ()->
    @piBroker.start()
  stop: (next)->
    @piBroker.stop()

module.exports = Broker
