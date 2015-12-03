EventEmitter = require('events').EventEmitter
Worker = require "./backends/zmq/worker"
async = require 'async'
RespInterface = require './interfaces/response'
debug = require('debug')('zerorest:Router')
_ = require 'lodash'

class Router extends EventEmitter
  constructor: (opts)->
    @before = opts.before or []
    @after = opts.after or []
    @localAfter = []
    @url = opts.url
    @path = opts.path
    @routes = []
    @socketConcurrency = opts.socketConcurrency
    @heartbeat = opts.heartbeat
    @reconnect = opts.reconnect
    @
  routes: []
  use: (fn)->
    if typeof(fn) is 'object'
      fn.forEach @use.bind(@)
    else if fn.length > 3
      @localAfter.push fn
    else
      @before.push fn
  route: ()->
    path = arguments[0]
    args = _.map arguments, (val)->
      return val
    fns = _.flatten args[1..]
    fullPath = @path + path
    opts =
      url: @url
      path: fullPath
      socketConcurrency: @socketConcurrency
      heartbeat: @heartbeat
      reconnect: @reconnect
    _worker = new Worker opts

    emitError = (err)=>
      @emit 'error', err
    _worker.on 'error', emitError
    _worker.on 'request', (req, res, opts)=>
      debug("Received request to #{fullPath}")
      if typeof(req) is 'string'
        formattedReq = {}
        formattedReq.body = req if req.length > 0
        req = formattedReq
      req.copts = opts
      req.path = _worker.fullPath
      @interfaces req, res
      runBefore = async.applyEachSeries @before
      runAfter = async.applyEachSeries @after
      runLocalAfter = async.applyEachSeries @localAfter
      fn = async.applyEachSeries fns
      handleError = (err)->
        runLocalAfter err, req, res, (err)->
          runAfter err, req, res, (err)->
            emitError err
            res.error err
      runBefore req, res, (err)->
        return handleError(err) if err
        fn req, res, (err)->
          return handleError(err) if err

    @routes.push
      fullPath: fullPath
      path: path
      cb: fns
      _worker: _worker
  start: (next)->
    debug("Starting...")
    async.each @routes, @startRoute, next
  interfaces: (req, res, opts)->
    RespInterface req, res, opts


  startRoute: (worker, cb)=>
    worker._worker.start cb
  stop: (next)->
    debug("Stopping...")
    async.each @routes, (worker, cb)->
      worker._worker.stop cb
    , next
module.exports = Router
