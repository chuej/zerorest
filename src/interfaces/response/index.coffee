_ = require 'lodash'

module.exports = (req, res, opts)->
  status = 200
  headers = undefined
  res.json = (body)->
    rep =
      body: body
    rep.statusCode = status if status
    rep.headers = headers if headers
    rep = JSON.stringify(rep)
    res.end rep

  res.send = res.end
  res.setStatus = (newStatus)->
    status = newStatus
  res.setHeaders = (newHeaders)->
    headers = newHeaders
  res.error = (err)->
    rep =
      statusCode: 500
      error:
        stack: err.stack
        message: err.message
        name: err.name
    rep.headers = headers if headers?
    res.end JSON.stringify(rep)
