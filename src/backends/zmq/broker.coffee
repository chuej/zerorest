PiBroker = require('pigato').Broker
EventEmitter = require('events').EventEmitter
async = require 'async'
Cluster = require '../../cluster'
class Broker extends EventEmitter
  constructor: (opts)->
    @url = opts.url
    @heartbeat = opts.heartbeat or 2500
    @lbmode = opts.lbmode or 'rr'

    @num = 0
    conf =
      onStart: ()=>
        @emit 'start'
      onStop: ()=>
        @emit 'stop'
      heartbeat: @heartbeat
      dmode: if @lbmode is 'rr' then 'load' else 'rand'
    @broker = new PiBroker @url, conf
    @
  start: ()->
    @broker.on 'error', (err)=>
      @emit 'error', err
    @broker.start()
  stop: ()->
    @broker.stop()

module.exports = Broker
