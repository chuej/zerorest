http = require('http')
request = require 'request'
resp = 'Hello World!'
cluster = require('cluster')
async = require('async')
_ = require('lodash')
cmd = require('commander')
host = "127.0.0.1"
port = "7777"


fork = (ID) ->
  if !cmd['nofork'] and ID
    return cluster.fork()
  setImmediate ->
    processID = ID or cluster.worker.processID or cluster.worker.id

    done = ->
      d2 = new Date
      hmany = d2.getTime() - d1.getTime()
      console.log hmany + " milliseconds for #{tp} requests. " + (tp / (hmany / 1000)).toFixed(2) + ' requests/sec.'
      console.log "Milliseconds per request: " + (hmany/tp)
      setTimeout (->
        cluster.worker.kill() if cluster.worker
        return
      ), 1000
      return

    send = ->

      prcnt = 0
      sn++
      console.log 'C/' + processID + ': WAVE=' + sn
      k = 0


      while k < cmd.p
        request.get "http://#{host}:#{port}", (err, resp, body)->
          throw err if err
          rcnt++
          prcnt++
          if prcnt == cmd.p and sn < cmd.s
            send()
            return
          if rcnt < tp
            return
          done()
          return
        k++
      return

    if processID <= cmd.bn
      # broker = new (require("../src/backends/zmq/broker"))(url: "tcp://0.0.0.0:5101", cache: ! !cmd.m)
      # broker.on 'error', (err) ->
      #   console.log 'broker', err
      #   return
      # broker.start ->
      #   console.log 'BROKER ' + processID
      #   return
      return
    else if processID <= cmd.bn + cmd.bn * cmd.wn
      http.createServer((req, res) ->
        setImmediate ->
          res.writeHead 200, 'Content-Type': 'text/plain'
          res.end chunk
        return
      ).listen port, host
      return
    else
      sn = 0
      tp = cmd.p * cmd.s

      d1 = undefined
      rcnt = 0
      setTimeout (->
        d1 = new Date
        send()
        return
      ), 2000
      return
  return

cmd.option('--bn <val>', 'Num of Brokers', 1)
.option('--wn <val>', 'Num of Workers (for each Broker)', 1)
.option('--cn <val>', 'Num of Clients (for each Broker)', 1)
.option('--pn <val>', 'Num of Parallel Requests (for each Client)', 5000)
.option('--p <val>', 'Num of messages (for each Client)', 10000)
.option('--m <val>', 'Use memory cache (1=enabled|0=disabled) (default=0)', 0)
.option('--s <val>', 'Num of waves (default=1)', 1)
.option('--e <val>', 'Num of waves (default=tcp://127.0.0.1:7777)', 'tcp://127.0.0.1:777')
.option '-N, --nofork', 'Don\'t use fork'
cmd.on '--help', ->
  console.log 'Examples:'
  console.log '\nnode ' + cmd.name() + ' --bn 2 --wn 2 --cn 2 --p 50000'
  return
cmd.parse process.argv
_.each [
  'bn'
  'wn'
  'cn'
  'p'
  'm'
  's'
], (k) ->
  cmd[k] = +cmd[k]
  return
chunk = 'foo'
if cluster.isMaster
  console.log 'RUNNING CONF'
  console.log '\n', [
    cmd.bn + ' brokers'
    cmd.wn + ' workers'
    cmd.cn + ' clients'
    'cache ' + (if cmd.m then 'on' else 'off')
    cmd.p + ' requests'
  ].join(', ')
  i = 0
  while i < cmd.bn + cmd.bn * cmd.wn + cmd.bn * cmd.cn
    fork i + 1
    i++
  kills = 0
  cluster.on 'exit', (worker, code, signal) ->
    kills++
    if kills == cmd.cn * cmd.bn
      process.exit 0
    return
else
  fork()

# ---
# generated by js2coffee 2.1.0

# express = require('express')
# app = express()
# app.get '/', (req, res) ->
#   res.send 'Hello World!'
#   return
# server = app.listen process.env.PORT, ->
#   host = server.address().address
#   port = server.address().port

# request = require 'request'
# Benchmark = require 'benchmark'
# console.log process.env.HOST
#
# request.get "http://#{process.env.HOST}:#{process.env.PORT}", (err, resp, body)->
#   console.log body
#
# bench = new Benchmark 'ZMS',
#   defer: true
#   async: true
#   initCount: 1000
#   minSamples: 5
#   delay: 0.00001
#   fn: (deferred)->
#     request.get "http://#{process.env.HOST}:#{process.env.PORT}", (err, resp, body)->
#       deferred.resolve()
# bench.on 'cycle', (event)->
#   console.log(String(event.target))
# bench.on 'complete', ()->
#   console.log @
#   console.log @stats.mean
# bench.run()
