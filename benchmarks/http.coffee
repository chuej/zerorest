http = require('http')

http.createServer((req, res) ->
  res.writeHead 200, 'Content-Type': 'text/plain'
  res.end 'Hello World!\n'
  return
).listen process.env.PORT, process.env.HOST

# express = require('express')
# app = express()
# app.get '/', (req, res) ->
#   res.send 'Hello World!'
#   return
# server = app.listen process.env.PORT, ->
#   host = server.address().address
#   port = server.address().port

request = require 'request'
Benchmark = require 'benchmark'
console.log process.env.HOST

request.get "http://#{process.env.HOST}:#{process.env.PORT}", (err, resp, body)->
  console.log err, resp, body

bench = new Benchmark 'ZMS',
  defer: true
  async: true
  initCount: 10
  minSamples: 100
  fn: (deferred)->
    request.get "http://#{process.env.HOST}:#{process.env.PORT}", (err, resp, body)->
      deferred.resolve()
bench.on 'cycle', (event)->
  console.log(String(event.target))
bench.on 'complete', ()->
  console.log @
bench.run()
