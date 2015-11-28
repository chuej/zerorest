Benchmark = require 'benchmark'
ZMS = require '../src'
Client = require('../src').Client
URL = "tcp://#{process.env.HOST}:#{process.env.PORT}"
client = new Client URL

startProvider = ()->
  zms = new ZMS(URL)
  users = zms.router("/hello")

  users.route "/world", (req, res, next)->
    res.end "Hello World!"

  zms.start()
  return zms
startProvider()


client.on 'start', ()->
  opts =
    copts:
      timeout: 10000

  bench = new Benchmark 'ZMS',
    defer: true
    async: true
    initCount: 10
    minSamples: 100
    fn: (deferred)->
      client.request '/hello/world', opts, (err, resp)->
        deferred.resolve()
  bench.on 'cycle', (event)->
    console.log(String(event.target))
  bench.on 'complete', ()->
    console.log @
  bench.run()
