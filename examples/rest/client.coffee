Client = require('../../src').Client
host = process.env.HOST or "0.0.0.0"
port = process.env.PORT or "5000"
client = new Client "tcp://#{host}:#{port}"
client.start()
client.on 'start', ()->
  opts =
    params:
      id: '1234'
    body:
      data: hello: "world"
    headers:
      method: 'PATCH'
    copts:
      timeout: 100000
  client.request '/users/update', opts, (err, resp)->
    # resp is json
    console.log resp

  opts =
    params:
      id: '4321'
  client.request '/templates/html', opts, (err,resp)->
    # resp is html
    console.log resp

  resp = ''
  stream = client.request '/users/findById', opts
  stream.on 'data', (data)->
    resp += data
  stream.on 'end', ()->
    console.log resp
