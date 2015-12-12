PiWorker = require('pigato').Worker
EventEmitter = require('events').EventEmitter
debug = require('debug')('zerorest:Worker')
async = require 'async'

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
    name = "[#{@url}/#{@path}]"
    debug "#{name} starting..."
    @worker.on 'request', (inp, rep, copts)=>
      @emit 'request', inp, rep, copts
      debug "#{name} received request"
    @worker.on 'error', (err)=>
      @emit 'error', err
      debug "#{name} ERROR: #{err.msg}\n #{err.stack}"
    @worker.start()
    return
  stop: (next)->
    @worker.stop()

module.exports = Worker
