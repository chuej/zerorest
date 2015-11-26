PiClient = require('pigato').Client

class Client
  constructor: (url)->
    @url = url
    @client = new PiClient @url
    @client.start()

    @
  request: (path, args, next)->
    client = @client
    client.on 'error', next
    body =
      params: args.params
      headers: args.headers
      body: args.body

    res = client.request path, body, args.copts
    if next?
      resBody = ''
      res.on 'data', (data)->
        resBody += data
        return
      .on 'end', ->
        try
          resBody = JSON.parse(resBody)
          client.removeListener 'error', next
          return next null, resBody, resBody.body
        catch err
          client.removeListener 'error', next
          return next err
    return res

  stop: (next)->
    @client.stop next
module.exports = Client
