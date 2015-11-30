EventEmitter = require('events').EventEmitter
Router = require './router'
Broker = require './backends/zmq/broker'
async = require 'async'
debug = require('debug')("zerorest:Service")
_ = require 'lodash'

class Service extends EventEmitter
  constructor: (opts)->
    @conf =
      broker:
        heartbeat: undefined
        concurrency: undefined
        lbmode: undefined
        noFork: undefined
      worker:
        heartbeat: undefined
        reconnect: undefined
        concurrency: undefined
        socketConcurrency: undefined
        noFork: undefined
      noFork: undefined
      url: undefined
    if typeof(opts) is 'string'
      @conf.url = opts
    else
      @conf.url = opts.url
      @conf.noFork = opts.noFork
      @conf.broker = _.defaults @conf.broker, opts.broker
      @conf.worker = _.defaults @conf.worker, opts.worker
    @conf.broker.url = @conf.url
    @conf.worker.url = @conf.url
    @conf.broker.noFork = @conf.noFork if @conf.noFork
    @conf.worker.noFork = @conf.noFork if @conf.noFork
    @broker = new Broker @conf.broker
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
      , (err)=>
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
    opts = _.defaults opts, @conf.worker
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
