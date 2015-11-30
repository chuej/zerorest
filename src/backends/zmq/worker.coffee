PiWorker = require('pigato').Worker
EventEmitter = require('events').EventEmitter
async = require 'async'
Cluster = require '../../cluster'

class Worker extends EventEmitter
  constructor: (opts)->
    @url = opts.url
    @heartbeat = opts.heartbeat or 2500
    @socketConcurrency = opts.socketConcurrency or 100
    @reconnect = opts.reconnect or 1000
    @path = opts.path
    conf =
      onConnect: ()=>
        @emit 'start'
      onDisconnect: ()=>

        @emit 'stop'
      concurrency: @socketConcurrency
      reconnect: @reconnect
      heartbeat: @heartbeat
    @worker = new PiWorker @url, @path, conf
    @

  start: ()->
    @worker.on 'request', (inp, rep, copts)=>
      @emit 'request', inp, rep, copts
    @worker.on 'error', (err)=>
      @emit 'error', err
    @worker.start()
    return
  stop: (next)->
    @worker.stop()

module.exports = Worker
