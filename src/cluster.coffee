async = require "async"
debug = require("debug")("zerorest:Cluster")
cluster = require 'cluster'
module.exports = (conf)->
  fn = conf.fn
  numWorkers = conf.numWorkers or 1
  workerFork = (callback)->
    worker = cluster.fork().on "message", workerMessage

    debug "[#{conf.name}] Worker " + worker.id + " starting..."
    worker.once "online", ->
      debug "[#{conf.name}] Worker " + worker.id + " started"
      callback() if callback?
    return worker

  workerDisconnect = (worker, callback)->
    debug "[#{conf.name}] Worker " + worker.id + " shutting down..."
    worker.disconnect()
    worker.once "disconnect", ->
      debug "[#{conf.name}] Worker " + worker.id + " shut down"
      return callback() if callback?

  workerMessage = (message) ->
    if message is "RECYCLE"
      debug "[#{conf.name}] Workers recycling..."
      workers = Object.keys(cluster.workers)
      async.eachSeries workers
      , (workerId, callback)->
        # disconnect current worker
        workerDisconnect cluster.workers[workerId] unless cluster.workers[workerId]?.suicide
        # create a new worker
        newWorker = workerFork()
        newWorker.once "online", ->
          return callback()
      , (err)->
        if err
          debug  "[#{conf.name}] Error recycling workers", err

  clusterShutdown = (callback) ->
    workers = Object.keys(cluster.workers)
    async.each workers
    , (workerId, callback)->
      workerDisconnect cluster.workers[workerId], callback unless cluster.workers[workerId]?.suicide
    , (err)->
      if err
        debug "[#{conf.name}] Error disconnecting workers"
      debug "[#{conf.name}] Cluster shutting down..."
      cluster.disconnect()
      debug "[#{conf.name}] Cluster shut down"
      callback() if callback?

  obj =
    stop: (next)->
      workerDisconnect cluster.worker, next
    start: ->
      if cluster.isMaster
        debug "[#{conf.name}] Cluster preparing..."
        i=0
        while i<(numWorkers)
          workerFork()
          i++

        cluster.on "online", (worker)->
          debug "[#{conf.name}] Worker " + worker.id + " online"

        cluster.on "exit", (worker, code, signal)->
          debug "[#{conf.name}] Worker " + worker.id + " exited with signal " + (signal || code)
          # if the worker failed without killing itself, restart it
          unless worker.suicide
            workerFork()

        # enable recycling from bash (sudo kill -12 [PROCID])
        process.on "SIGUSR2", ()->
          workerMessage "RECYCLE"

        process.on "SIGINT", ()->
          debug "[#{conf.name}] Cluster received SIGINT"
          clusterShutdown ()->
            process.exit(0)

        process.on "SIGTERM", ()->
          debug "[#{conf.name}] Cluster received SIGTERM"
          clusterShutdown ()->
            process.exit(0)

        debug "[#{conf.name}] Cluster prepared"
      else
        process.on 'uncaughtException', (err)->
          debug
            err: err.stack
          , 'Uncaught Exception'
          process.exit 11
        return fn()
  return obj
