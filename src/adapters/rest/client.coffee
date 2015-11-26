Client = require('pigato').Client
module.exports = (url)->
  client = new Client url
  client.start()
  request = (path, args, next)->
    client.on 'error', next
    body =
      params: args.params
      headers: args.headers
      body: args.body

    res = client.request path, body, args.clientOpts
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
  request.request = request
  return request
