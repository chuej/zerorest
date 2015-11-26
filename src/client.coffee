PiClient = require('pigato').Client
EventEmitter = require('events').EventEmitter
CError = (name, message, stack) ->
  @name = name
  @message = message
  @stack = stack
  return

CError.prototype = Object.create(Error.prototype)
CError::constructor = CError

class Client extends EventEmitter
  constructor: (url)->
    @url = url
    conf =
      onConnect: ()=>
        @emit 'start'
    @client = new PiClient @url, conf
    @client.start()
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
          return next null, resBody unless resBody.error?
          resErr = resBody.error
          error = new CError resErr.name, resErr.message, resErr.stack
          return next error, resBody
        catch err
          if typeof(resBody) is 'string'
            return next null, resBody
          return next err
    return res

  stop: (next)->
    @client.stop next
module.exports = Client
