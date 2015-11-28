piBroker = require('pigato').Broker
EventEmitter = require('events').EventEmitter

class Broker extends EventEmitter
  constructor: (opts)->
    @url = opts.url
    @heartbeat = opts.heartbeat or 2500
    @lbmode = opts.lbmode or 'rr'
    @concurrency = opts.concurrency or 5
    conf =
      onStart: ()=>
        @emit 'start'
      onStop: ()=>
        @emit 'stop'
      heartbeat: @heartbeat
      dmode: if @lbmode is 'rr' then 'load' else 'rand'
    @piBroker = new piBroker @url, conf


    @
  start: ()->
    @piBroker.start()
  stop: ()->
    @piBroker.stop()

module.exports = Broker
