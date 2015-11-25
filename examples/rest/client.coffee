PIGATO = require('pigato')
client = new (PIGATO.Client)('tcp://service:55555')
client.start()
client.on 'error', (err) ->
  console.log 'CLIENT ERROR', err
  return
# Streaming implementation
res = client.request('/users/findById', {
  ticker: 'AAPL'
  startDay: '1'
  startMonth: '6'
  startYear: '2013'
  endDay: '1'
  endMonth: '6'
  endYear: '2014'
  freq: 'd'
}, timeout: 90000)
body = ''
res.on('data', (data) ->
  body += data
  return
).on 'end', ->
  console.log "body:::", body
  return
