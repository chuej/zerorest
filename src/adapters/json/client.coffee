PiClient = require('pigato').Client
EventEmitter = require('events').EventEmitter

class Client extends EventEmitter
  constructor: (url)->
    @url = url
    @client = new PiClient @url
    @client.start ()=>
      @emit 'start'

    @client.on 'error', (err)=>
      @emit 'error', err
    @
  request: (path, args, next)->
    client = @client
    copts = args.copts
    delete args.copts

    res = client.request path, args, copts
    if next?
      resBody = ''
      res.on 'data', (data)->
        resBody += data
        return
      .on 'end', ->
        try
          resBody = JSON.parse(resBody)
          return next null, resBody, resBody.body
        catch err
          return next err
    return res

  stop: (next)->
    @client.stop next
module.exports = Client
