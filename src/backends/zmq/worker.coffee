PiWorker = require('pigato').Worker
EventEmitter = require('events').EventEmitter
async = require 'async'

class Worker extends EventEmitter
  constructor: (opts)->
    console.log opts
    @url = opts.url
    @concurrency = opts.concurrency or 1
    @heartbeat = opts.heartbeat or 2500
    @socketConcurrency = opts.socketConcurrency or 100
    @reconnect = opts.reconnect or 1000
    @path = opts.path
    @num = 0
    i = @concurrency + 1
    @workers = while i -= 1
      conf =
        onConnect: ()=>
          @num += 1
          if @num is @concurrency
            @emit 'start'
        onDisconnect: ()=>
          @num -= 1
          if @num is 0
            @emit 'stop'
        concurrency: @socketConcurrency
        reconnect: @reconnect
        heartbeat: @heartbeat
      piWorker = new PiWorker @url, @path, conf
    @
  start: ()->
    async.each @workers, (worker, cb)=>
      worker.on 'request', (inp, rep, copts)=>
        @emit 'request', inp, rep, copts
      worker.on 'error', (err)=>
        @emit 'error', err
      worker.start()
      return cb null
  stop: ()->
    async.each @workers, (worker, cb)=>
      worker.stop()
      return cb null

module.exports = Worker
