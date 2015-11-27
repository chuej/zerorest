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
  start: (next)->
    @piBroker.start next
  stop: (next)->
    @piBroker.stop next

module.exports = Broker
