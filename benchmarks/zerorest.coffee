Benchmark = require 'benchmark'
ZMS = require '../src'
Client = require('../src').Client
URL = "tcp://#{process.env.HOST}:#{process.env.PORT}"

async = require 'async'
startProvider = ()->
  zms = new ZMS(URL)
  users = zms.router("/hello")

  users.route "/world", (req, res, next)->
    res.end "Hello World!"

  zms.start()
  return zms
startProvider()

num = 6
cnum = 0
clients = while num -= 1
  client = new Client URL
async.each clients, (client, cb)->
  client.on 'start', ()->
    return cb null
, (err)->
  opts =
    copts:
      timeout: 10000
  i = 0
  bench = new Benchmark 'ZMS',
    defer: true
    async: true
    initCount: 10
    minSamples: 100
    fn: (deferred)->
      if i > 4
        i = 0
      clients[i].request '/hello/world', opts, (err, resp)->
        deferred.resolve()
      i++
  bench.on 'cycle', (event)->
    console.log(String(event.target))
  bench.on 'complete', ()->
    console.log @
  bench.run()
