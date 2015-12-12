PiBroker = require('pigato').Broker
EventEmitter = require('events').EventEmitter
async = require 'async'

debug = require('debug')('zerorest:Broker')
class Broker extends EventEmitter
  constructor: (opts)->
    @url = opts.url
    @heartbeat = opts.heartbeat or 2500
    @lbmode = opts.lbmode or 'rr'

    @num = 0
    conf =
      onStart: ()=>
        @emit 'start'
        debug("[#{@url}] started.")
      onStop: ()=>
        @emit 'stop'
        debug("[#{@url}] stopped.")
      heartbeat: @heartbeat
      dmode: if @lbmode is 'rr' then 'load' else 'rand'
    @broker = new PiBroker @url, conf
    @
  start: ()->
    @broker.on 'error', (err)=>
      @emit 'error', err
      debug("[#{@url}] ERROR: #{err.message}\n #{err.stack}")
    @broker.start()
  stop: ()->
    @broker.stop()

module.exports = Broker
