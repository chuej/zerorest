PiClient = require('pigato').Client
EventEmitter = require('events').EventEmitter
debug = require('debug')("zerorest:Client")

class Client extends EventEmitter
  constructor: (url)->
    @url = url
    conf =
      onConnect: ()=>
        @emit 'start'
        debug "[#{@url}] Client started"
      onDisconnect: ()=>
        @emit 'stop'
        debug "[#{@url}] Client stopped"
    @client = new PiClient @url, conf

    @client.on 'error', (err)=>
      @emit 'error', err
      debug "[#{@url}] ERROR: #{err.message}\n #{err.stack}"
    @
  start: ()->
    @client.start()
  request: (path, args, next)->
    client = @client
    copts = args.copts
    delete args.copts

    res = client.request path, args, copts
    debug "[#{@url}/#{path}] making request..."
    if next?
      resBody = ''
      res.on 'error', (err)->
        next err
        debug "[#{@url}/#{path}] ERROR: #{err.message}\n #{err.stack}"
      res.on 'data', (data)->
        resBody += data
        return
        debug "[#{@url}/#{path}] Received partial data..."
      .on 'end', ->
        try
          resBody = JSON.parse(resBody)
          return next null, resBody unless resBody.error?
          resErr = resBody.error
          error = new Error()
          error.message = "Error from service: #{resErr.message}" if resErr.message?
          error.stack = resErr.stack if resErr.stack?
          error.name = resErr.name if resErr.name?
          next error, resBody
          debug "[#{@url}/#{path}] Successful request."
        catch err
          if typeof(resBody) is 'string'
            return next null, resBody
          return next err
    return res

  stop: (next)->
    @client.stop next
module.exports = Client
