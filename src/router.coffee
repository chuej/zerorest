EventEmitter = require('events').EventEmitter
Worker = require "./backends/zmq/worker"
async = require 'async'
RespInterface = require './interfaces/response'

class Router extends EventEmitter
  constructor: (opts)->
    @before = opts.before or []
    @after = opts.after or []
    @localAfter = []
    @url = opts.url
    @path = opts.path
    @routes = []
    @concurreny = opts.concurrency or 5
    @socketConcurrency = opts.socketConcurrency or 100
    @
  routes: []
  use: (fn)->
    if typeof(fn) is 'object'
      fn.forEach @use.bind(@)
    else if fn.length > 3
      @localAfter.push fn
    else
      @before.push fn
  route: (path, fn)->
    @routes.push
      path: path
      cb: fn
  start: (next)->
    async.each @routes, @startRoute, next
  interfaces: (req, res, opts)->
    RespInterface req, res, opts


  startRoute: (worker, cb)=>
    worker.fullPath = @path + worker.path
    opts =
      url: @url
      path: worker.fullPath
      concurrency: @socketConcurrency
    _worker = new Worker opts
    worker._worker = _worker
    emitError = (err)=>
      @emit 'error', err
    _worker.on 'error', emitError
    _worker.on 'request', (req, res, opts)=>
      if typeof(req) is 'string'
        formattedReq = {}
        formattedReq.body = req if req.length > 0
        req = formattedBody
      req.copts = opts
      req.path = worker.fullPath
      @interfaces req, res
      runBefore = async.applyEachSeries @before
      runAfter = async.applyEachSeries @after
      runLocalAfter = async.applyEachSeries @localAfter

      handleError = (err)=>
        runLocalAfter err, req, res, (err)->
          runAfter err, req, res, (err)->
            emitError err
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
