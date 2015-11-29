EventEmitter = require('events').EventEmitter
Router = require './router'
Broker = require './backends/zmq/broker'
async = require 'async'
debug = require('debug')("zerorest:Service")

class Service extends EventEmitter
  constructor: (opts)->
    @conf =
      broker:
        heartbeat: undefined
        concurrency: undefined
        lbmode: undefined
      router:
        heartbeat: undefined
        reconnect: undefined
        concurrency: undefined
        socketConcurrency: undefined

    if typeof(opts) is 'string'
      @url = opts
    else
      @url = opts.url
      @conf.broker.heartbeat = opts.broker?.heartbeat
      @conf.broker.lbmode = opts.broker?.lbmode
      @conf.broker.concurrency = opts.broker?.concurrency
      @conf.router.heartbeat = opts.router?.heartbeat
      @conf.router.reconnect = opts.router?.reconnect
      @conf.router.concurrency = opts.router?.concurrency
      @conf.router.socketConcurrency = opts.router?.socketConcurrency
    conf =
      url: @url
      heartbeat: @conf.broker.heartbeat
      lbmode: @conf.broker.lbmode
      concurrency: @conf.broker.concurrency
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
  router: (opts)->
    if typeof(opts) is 'string'
      path = opts
    opts =
      path: path
      url: @url
      before: @before.slice(0)  #allow for router-specific middleware
      after: @after
      concurrency: opts.concurrency or @conf.router.concurrency
      socketConcurrency: opts.socketConcurrency or @conf.router.socketConcurrency
      heartbeat: opts.heartbeat or @conf.router.heartbeat
      reconnect: opts.reconnect or @conf.router.reconnect
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
