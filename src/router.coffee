EventEmitter = require('events').EventEmitter
Worker = require('pigato').Worker
async = require 'async'
class Router extends EventEmitter
  constructor: (opts)->
    @before = opts.before or []
    @after = opts.after or []
    @localAfter = []
    @url = opts.url
    @path = opts.path
    @routes = []
    @concurrency = opts.concurrency or 250
    @
  routes: []
  use: (fn)->
    if fn.length > 3
      @localAfter.push fn
    else
      @before.push fn
  route: (path, fn)->
    @routes.push
      path: path
      cb: fn
  start: (next)->
    async.each @routes, @startRoute, next
  startRoute: (worker, cb)=>
    conf =
      concurrency: @concurrency
    worker.fullPath = @path + worker.path

    _worker = new Worker @url, worker.fullPath, conf
    worker._worker = _worker
    emitError = (err)=>
      @emit 'WorkerError', err
    _worker.on 'error', emitError
    _worker.on 'request', (req, res, opts)=>
      req.copts = opts
      req.path = worker.fullPath
      res.error = (err)->
        resp =
          error:
            stack: err?.stack
            message: err?.message
            name: err?.name
        res.end JSON.stringify(resp)
      runBefore = async.applyEachSeries @before
      runAfter = async.applyEachSeries @after
      runLocalAfter = async.applyEachSeries @localAfter

      handleError = (err)->
        runLocalAfter err, req, res, (err)->
          runAfter err, req, res, (err)->
            res.error err
      runBefore req, res, (err)->
        return handleError(err) if err
        worker.cb req, res, (err)->
          return handleError(err) if err

    _worker.start cb
  stop: (next)->
    async.each @routes, (worker, cb)->
      worker._worker.stop cb
    , next
module.exports = Router