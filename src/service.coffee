EventEmitter = require('events').EventEmitter
Router = require './router'
Broker = require './backends/zmq/broker'
async = require 'async'
debug = require('debug')("zerorest:Service")
_ = require 'lodash'
cluster = require 'cluster'

class Service extends EventEmitter
  constructor: (opts)->
    @conf =
      broker:
        heartbeat: undefined
        lbmode: undefined
        noFork: undefined
        url: undefined
        concurrency: 1
      worker:
        heartbeat: undefined
        reconnect: undefined
        socketConcurrency: undefined
        concurrency: 1
      noFork: opts?.noFork
      maxProcs: 8
      url: undefined
    if typeof(opts) is 'string'
      @conf.url = opts
    else
      @conf = _.defaults @conf, opts
      # @conf.broker = _.defaults @conf.broker, opts.broker
      # @conf.worker = _.defaults @conf.worker, opts.worker
    @conf.broker.url = @conf.broker.url or @conf.url
    @conf.worker.url = @conf.worker.url or @conf.url

    @broker = new Broker @conf.broker
    @broker.on 'start', ()=>
      @emit 'start'
    @broker.on 'stop', ()=>
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

  use: ()->
    args = _.map arguments, (val)->
      return val
    fns = _.flatten args
    fns.forEach (fn)=>
      if fn.length > 3
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

  execArray: ()->
    arr = []
    i = @conf.broker.concurrency
    while i -= 1
      arr.push @broker.start.bind(@)
    max = @conf.maxProcs - 1

    @routers.forEach (router)->
      router.routes.forEach (route)->
        arr.push route._worker.start.bind(route._worker)
    return arr if @conf.noFork
    return arr if max >= arr.length

    remainder = arr.length % max
    numPer = arr.length / 2
    distArr = []
    fns = []
    i = 1

    arr[...(arr.length-remainder)].forEach (worker)->
      fns.push worker
      if i++ is (numPer)
        distArr.push fns
        fns = []
        i = 1
      arr.shift()
    distArr.push arr unless arr.length is 0

    return distArr

  start: ()->
    debug "Starting..."
    if @conf.noFork
      @broker.start()
      execArray = @execArray()
      execArray.forEach (exec)->
        exec()
    else
      if cluster.isMaster
        debug "Starting cluster......."
        @broker.start()
        execArray = @execArray()
        execArray.forEach (exec)->
          cluster.fork()
        @cleanup()
      else
        execArray = @execArray()
        id = cluster.worker.id - 1
        worker = execArray[id]
        console.log "worker::::::::", worker
        async.parallel worker
  cleanup: ()->
    delete @routers
    delete @before
    delete @after

  stop: ()->
    debug "Stopping..."
    if @conf.noFork
      @broker.stop()
    else
      @brokerCluster.stop()
      async.each @routerCluster, (router, cb)->
        router.stop()
        return cb null
module.exports = Service
