EventEmitter = require('events').EventEmitter
Router = require './router'
Broker = require './backends/zmq/broker'
async = require 'async'

class Service extends EventEmitter
  constructor: (url)->
    @url = url

    @broker = new Broker @url
    @broker.on 'start', ()=>
      @emit 'brokerStart'
      async.each @routers, (router, cb)->
        router.start cb
    @broker.on 'stop', ()=>
      @emit 'brokerStop'
      async.each @routers, (router, cb)->
        router.stop cb
    @before = []
    @after = []
    @routers = []
    @

  use: (fn)->
    if fn.length > 3
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
    @routers.push router
    return router
  start: ()->
    @broker.start()
  stop: ()->
    @broker.stop()
module.exports = Service
