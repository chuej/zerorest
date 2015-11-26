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

  res.send = res.json
  res.sendRaw = res.end
  res.setStatus = (newStatus)->
    status = newStatus
  res.setHeaders = (newHeaders)->
    headers = newHeaders
  return next null
