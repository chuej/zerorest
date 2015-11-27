piBroker = require('pigato').Broker
EventEmitter = require('events').EventEmitter

class Broker extends EventEmitter
  constructor: (opts)->
    @url = opts.url
    piBroker = opts.Broker if opts.Broker

    @piBroker = piBroker @url
    @piBroker.onStart ()=>
      @status = 'started'
      @emit 'start'
    @piBroker.onStop ()=>
      @status = 'stopped'
      @emit 'stop'

    @
  start: (next)->
    @piBroker.start next
  stop: (next)->
    @piBroker.stop next

module.exports = Broker
