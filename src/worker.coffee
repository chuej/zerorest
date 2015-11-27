pigato = require 'pigato'
EventEmitter = require('events').EventEmitter

class Worker extends EventEmitter
  constructor: (opts)->
    piWorker = opts.Worker if opts.Worker
    @url = opts.url
    @path = opts.path
    conf =
      onConnect: ()=>
        @emit 'start'
      onDisconnect: ()=>
        @emit 'stop'
    @piWorker = new piWorker @url, @path, conf
    @
  start: ()->
    @piWorker.start()
    @worker.on 'request', (inp, rep)=>
      @emit 'request', inp, rep
    @piWorker.on 'error', (err)=>
      @emit 'error', err
module.exports = Worker
