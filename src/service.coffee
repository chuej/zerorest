EventEmitter = require('events').EventEmitter
Router = require './router'
Broker = require './backends/zmq/broker'
async = require 'async'
debug = require('debug')("zerorest:Service")

class Service extends EventEmitter
  constructor: (opts)->
    if typeof(opts) is 'string'
      @url = opts
      @heartbeat = undefined
      @lbmode = undefined
      @concurrency = undefined
    else
      @url = opts.url
      @heartbeat = opts.heartbeat
      @lbmode = opts.lbmode
      @concurrency = opts.concurrency

    conf =
      url: @url
      heartbeat: @heartbeat
      lbmode: @lbmode
      concurrency: @concurrency
    @broker = new Broker conf
    @broker.on 'start', ()=>
      debug("Broker started.")
      @emit 'BrokerStart'
      async.each @routers, (router, cb)->
        router.start cb
      , (err)->
        if err
          @emit 'error', err
        @emit 'start'
    @broker.on 'stop', ()=>
      debug "Broker stopped."
      @emit 'BrokerStop'
      async.each @routers, (router, cb)->
        router.stop cb
      , (err)->
        if err
          @emit 'error', err
        @emit 'stop'
    @broker.on 'error', (err)=>
      @emit 'error', err
    @before = []
    @after = []
    @routers = []
    @

  use: (fn)->
    if typeof(fn) is 'object'
      fn.forEach @use.bind(@)
    else if fn.length > 3
      @after.push fn
    else
      @before.push fn
  router: (path)->
    opts =
      path: path
      url: @url
      before: @before.slice(0)  #allow for router-specific middleware
      after: @after
    router = new Router opts
    router.on 'error', (err)=>
      @emit 'error', err
    @routers.push router
    return router
  start: ()->
    debug "Starting..."
    @broker.start()
  stop: ()->
    debug "Stopping..."
    @broker.stop()
module.exports = Service
