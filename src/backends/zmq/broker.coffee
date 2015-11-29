PiBroker = require('pigato').Broker
EventEmitter = require('events').EventEmitter
async = require 'async'

class Broker extends EventEmitter
  constructor: (opts)->
    @url = opts.url
    @heartbeat = opts.heartbeat or 2500
    @lbmode = opts.lbmode or 'rr'
    @concurrency = opts.concurrency or 1
    @num = 0
    i = @concurrency + 1
    @brokers = while i -= 1
      conf =
        onStart: ()=>
          @num += 1
          if @num is @concurrency
            @emit 'start'
        onStop: ()=>
          @num -= 1
          if @num is 0
            @emit 'stop'
        heartbeat: @heartbeat
        dmode: if @lbmode is 'rr' then 'load' else 'rand'
      piBroker = new PiBroker @url, conf
    @
  start: ()->
    async.each @brokers, (broker, cb)=>
      broker.on 'error', (err)=>
        @emit 'error', err
      broker.start()
      return cb null
  stop: ()->
    async.each @brokers, (broker, cb)=>
      broker.stop()
      return cb null

module.exports = Broker
