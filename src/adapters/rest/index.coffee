module.exports = (req, res, next)->
  status = null
  headers = null
  res.json = (body)->
    rep =
      headers: headers
      status: status
      body: body
    rep = JSON.stringify(rep)
    res.end rep

  res.send = res.end
  res.setStatus = (newStatus)->
    status = newStatus
  res.setHeaders = (newHeaders)->
    headers = newHeaders
  res.error = (err)->
    rep =
      status: 500
      body:
        stack: err.stack
        message: err.message
        name: err.name
    res.end JSON.stringify(rep)
  return next null
