#!./node_modules/.bin/coffee
ZMS = require '../src'
URL = "tcp://#{process.env.HOST}:#{process.env.PORT}"
n = 3000
resp = ''
while n -= 1
  resp += 'Hello World! '
startProvider = ()->
  opts =
    broker:
      concurrency: 1
    worker:
      concurrency: 1
    url: URL
  zms = new ZMS opts
  users = zms.router("/hello")

  users.route "/world", (req, res, next)->
    res.end resp

  zms.start()
  return zms
zms = startProvider()
