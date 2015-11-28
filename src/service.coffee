EventEmitter = require('events').EventEmitter
Router = require './router'
Broker = require './backends/zmq/broker'
async = require 'async'

class Service extends EventEmitter
  constructor: (url)->
    @url = url

    @broker = new Broker @url
    @broker.on 'start', ()=>
      @emit 'BrokerStart'
      async.each @routers, (router, cb)->
        router.start cb
      , (err)->
        if err
          @emit 'error', err
        @emit 'start'
    @broker.on 'stop', ()=>
      @emit 'BrokerStop'
      async.each @routers, (router, cb)->
        router.stop cb
      , (err)->
        if err
          @emit 'error', err
        @emit 'stop'
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
    @broker.start()
  stop: ()->
    @broker.stop()
module.exports = Service
