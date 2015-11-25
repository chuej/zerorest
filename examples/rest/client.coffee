PIGATO = require('pigato')
client = new (PIGATO.Client)('tcp://service:55555')
client.start()
client.on 'error', (err) ->
  console.log 'CLIENT ERROR', err
  return
# Streaming implementation
res = client.request('/users/findById', {
  params: {id: '1234'}
}, timeout: 90000)
body = ''
res.on('data', (data) ->
  body += data
  return
).on 'end', ->
  console.log "body:::", JSON.stringify(body, null, 2)
  return
