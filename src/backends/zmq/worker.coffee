PiWorker = require('pigato').Worker
EventEmitter = require('events').EventEmitter

class Worker extends EventEmitter
  constructor: (opts)->
    @url = opts.url
    @path = opts.path
    conf =
      onConnect: ()=>
        @emit 'start'
      onDisconnect: ()=>
        @emit 'stop'
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
