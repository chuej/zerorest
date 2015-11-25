EventEmitter = require('events').EventEmitter
Worker = require('pigato').Worker
async = require 'async'
class Master extends EventEmitter
  constructor: (opts)->
    @before = opts.before
    @after = opts.after
    @url = opts.url
    @path = opts.path
    @
  workers: []
  use: (fn)->
    if @workers.length < 1
      @before.push fn
    else
      @after.push fn
  worker: (path, fn)->
    @workers.push
      path: path
      cb: fn
  start: ()->
    async.forEach @workers, @startWork
  startWork: (worker, cb)=>
    worker.fullPath = @path + worker.path

    _worker = new Worker @url, worker.fullPath
    worker._worker = _worker

    _worker.on 'error', (err)=>
      @emit 'WorkerError', err
    _worker.on 'request', (inp, rep, opts)=>
      runBefore = async.applyEachSeries @before
      runAfter = async.applyEachSeries @after
      handleError = (err)=>
        runAfter err, inp, rep, (err)=>
          @emit 'WorkerError', err
      runBefore inp, rep, (err)=>
        return handleError(err) if err
        worker.cb inp, rep, (err)=>
          return handleError(err) if err
          async.applyEachSeries @after, err, inp, rep, (err)=>
            @emit 'WorkerError', err if err

    _worker.start()
    return cb null
module.exports = Master
