PiWorker = require('pigato').Worker
EventEmitter = require('events').EventEmitter

class Worker extends EventEmitter
  constructor: (opts)->
    @url = opts.url
    @concurrency = opts.concurrency or 5
    @heartbeat = opts.heartbeat or 2500
    @socketConcurrency = opts.socketConcurrency or 100
    @reconect = opts.reconnect or 1000
    @path = opts.path
    conf =
      onConnect: ()=>
        @emit 'start'
      onDisconnect: ()=>
        @emit 'stop'
      concurrency: @socketConcurrency
      reconnect: @reconnect
      heartbeat: @heartbeat
    @piWorker = new PiWorker @url, @path, conf
    @
  start: ()->
    @piWorker.on 'request', (inp, rep, copts)=>
      @emit 'request', inp, rep, copts
    @piWorker.on 'error', (err)=>
      @emit 'error', err
    @piWorker.start()
  stop: ()->
    @piWorker.stop()

module.exports = Worker
