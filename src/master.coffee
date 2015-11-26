EventEmitter = require('events').EventEmitter
Worker = require('pigato').Worker
async = require 'async'
class Master extends EventEmitter
  constructor: (opts)->
    @before = opts.before or []
    @after = opts.after or []
    @localAfter = []
    @url = opts.url
    @path = opts.path
    @adapter = opts.adapter or 'rest'
    @workers = []
    @
  workers: []
  use: (fn)->
    if @workers.length < 1
      @before.push fn
    else
      @localAfter.push fn
  worker: (path, fn)->
    @workers.push
      path: path
      cb: fn
  start: (next)->
    async.each @workers, @startWork, next
  startWork: (worker, cb)=>
    worker.fullPath = @path + worker.path

    _worker = new Worker @url, worker.fullPath
    worker._worker = _worker
    emitError = (err)=>
      @emit 'WorkerError', err
    _worker.on 'error', emitError
    _worker.on 'request', (inp, rep, opts)=>
      require("./adapters/#{@adapter}") inp, rep, opts
      runBefore = async.applyEachSeries @before
      runAfter = async.applyEachSeries @after
      runLocalAfter = async.applyEachSeries @localAfter

      handleError = (err)->
        runLocalAfter err, inp, rep, (err)->
          runAfter err, inp, rep, (err)->
            emitError err
      runBefore inp, rep, (err)->
        return handleError(err) if err
        worker.cb inp, rep, (err)->
          return handleError(err) if err

    _worker.start cb
  stop: (next)->
    async.each @workers, (worker, cb)->
      worker._worker.stop cb
    , next
module.exports = Master
