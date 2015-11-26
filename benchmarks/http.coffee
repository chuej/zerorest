
request = require 'request'
Benchmark = require 'benchmark'
console.log process.env.HOST

request.get "http://#{process.env.HOST}:#{process.env.PORT}", (err, resp, body)->
  console.log err, resp, body

bench = new Benchmark 'ZMS',
  defer: true
  async: true
  fn: (deferred)->
    request.get "http://#{process.env.HOST}:#{process.env.PORT}", (err, resp, body)->
      deferred.resolve()
bench.on 'cycle', (event)->
  console.log(String(event.target))
bench.on 'complete', ()->
  console.log @
bench.run()
