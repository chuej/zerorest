EventEmitter = require('events').EventEmitter
Worker = require('pigato').Worker

class Master extends EventEmitter
  constructor: (opts)->
    @before = opts.before
    @after = opts.after
    @url = opts.url
    @path = opts.path
    @
  workers: []
  use: (fn)->
    @before.push fn
  worker: (path, fn)->
    @workers.push
      path: path
      cb: fn
  start: ()->
    @workers.forEach @startWork
  startWork: (worker)=>
    worker.fullPath = @path + worker.path
    console.log "creating worker"
    console.log "path: #{worker.fullPath}"
    console.log "url: #{@url}"
    _worker = new Worker @url, worker.fullPath
    worker._worker = _worker

    _worker.on 'error', (err)=>
      @emit 'WorkerError', err
    _worker.on 'request', (inp, rep, opts)->
      console.log inq, rep, opts
      console.log "request!!!!!!!!"
      #compose before, worker.cb, and after
      #call adapter w/ fns
      rep.end inp
    _worker.start()
module.exports = Master
