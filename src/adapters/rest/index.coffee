module.exports = (req, res, opts)->
  status = null
  headers = null
  res.json = (body)->
    res.end
      headers: headers
      status: status
      body: body
  res.send = res.json
  res.setStatus = (newStatus)->
    status = newStatus
  res.setHeaders = (newHeaders)->
    headers = newHeaders
