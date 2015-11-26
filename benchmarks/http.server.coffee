http = require('http')
console.log process.env.HOST
http.createServer((req, res) ->
  res.writeHead 200, 'Content-Type': 'text/plain'
  res.end 'Hello World!\n'
  return
).listen process.env.PORT, process.env.HOST
