Benchmark = require 'benchmark'
ZMS = require '../src'
Client = require('../src').Client
URL = "tcp://#{process.env.HOST}:#{process.env.PORT}"
client = new Client URL

startProvider = ()->
  zms = new ZMS(URL)
  zms.use ZMS.restAdapter
  users = zms.master("/hello")

  users.worker "/world", (req, res, next)->
    res.opts.cache = 1000
    res.send "Hello World!"
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
    fn: (deferred)->
      client.request '/hello/world', opts, (err, resp)->
        deferred.resolve()
  bench.on 'cycle', (event)->
    console.log(String(event.target))
  bench.on 'complete', ()->
    console.log @
  bench.run()