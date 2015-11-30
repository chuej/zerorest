EventEmitter = require('events').EventEmitter
Router = require './router'
Broker = require './backends/zmq/broker'
async = require 'async'
debug = require('debug')("zerorest:Service")
_ = require 'lodash'

Cluster = require './cluster'

class Service extends EventEmitter
  constructor: (opts)->
    @conf =
      broker:
        heartbeat: undefined
        lbmode: undefined
        noFork: undefined
      worker:
        heartbeat: undefined
        reconnect: undefined
        socketConcurrency: undefined
      noFork: opts?.noFork

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

    @broker = new Broker @conf.broker
    @broker.on 'start', ()=>
      debug("Broker started.")
      @emit 'start'
    @broker.on 'stop', ()=>
      debug "Broker stopped."
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
    unless @noFork
      @broker.on 'start', ()=>
        async.each @routers, (router, cb)=>
          router.start()
          return cb null
      @broker.start()

    else
      @routerCluster = []
      @brokerCluster = Cluster name: "Broker", numWorkers: @conf.broker.concurrency, fn: @broker.start.bind(@broker)
      @brokerCluster.start()
      async.each @routers, (router, cb)=>
        router.routes.forEach (route)=>
          cluster = Cluster name: route.fullPath, numWorkers: @conf.worker.concurrency, fn: route._worker.start.bind(route._worker)
          cluster.start()
          @routerCluster.push cluster
        # cluster = Cluster name: router.path, numWorkers: @conf.worker.concurrency, fn: router.start.bind(router)
        # @routerCluster.push cluster
        # cluster.start()
        return cb null
  stop: ()->
    debug "Stopping..."
    unless @noFork
      @broker.stop()
    else
      @brokerCluster.stop()
      async.each @routerCluster, (router, cb)->
        router.stop()
        return cb null
module.exports = Service
