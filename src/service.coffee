EventEmitter = require('events').EventEmitter
Router = require './router'
Broker = require('pigato').Broker
async = require 'async'

class Service extends EventEmitter
  constructor: (url)->
    @url = url
    brokerConf =
      onStart: ()=>
        @emit 'brokerStart'
        async.each @routers, (router, cb)->
          router.start cb
      onStop: ()=>
        @emit 'brokerStop'
        async.each @routers, (router, cb)->
          router.stop cb
    @broker = new Broker @url, brokerConf
    @before = []
    @after = []
    @routers = []
    @
  before: []
  after: []
  routers: []
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
