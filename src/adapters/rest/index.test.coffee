Adapter = require './'
assert = require 'assert'

describe 'rest adapter', ()->
  before (done)->
    @req = {}
    @res = {}
    Adapter @req, @res, (err)->
      return done err
  context 'res.json', ()->
    it 'should call end with formatted body', (done)->
      @body = {'args': 'args'}
      @res.end = (args)=>
        args = JSON.parse(args)
        assert.deepEqual args.body, @body
        return done null
      @res.json @body
  context 'res.send', ()->
    it 'should call end with raw (non-json) data', (done)->
      @body = '<html></html>'
      @res.end = (args)=>
        assert.equal @body, args
        return done null
      @res.end @body
  context 'res.setStatus', ()->
    it 'should set status of response', (done)->
      @res.setStatus 200
      @res.end = (args)=>
        args = JSON.parse(args)
        assert.equal args.status, 200
        return done null
      @res.json {}
  context 'res.setHeaders', ()->
    it 'should set headers of response', (done)->
      @res.setHeaders
        'content-type': 'application/json'
      @res.end = (args)=>
        args = JSON.parse(args)
        assert.equal args.headers['content-type'], 'application/json'
        return done null
      @res.json {}
