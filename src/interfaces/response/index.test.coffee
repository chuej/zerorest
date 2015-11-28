Adapter = require './'
assert = require 'assert'

describe 'rest adapter', ()->
  before ()->
    @req = {}
    @res = {}
    Adapter @req, @res
  context 'res.json', ()->
    it 'should call end with formatted body', (done)->
      @body = {'args': 'args'}
      @res.end = (args)=>
        args = JSON.parse(args)
        assert.deepEqual args.body, @body
        return done null
      @res.json @body
  context 'res.send', ()->
    it 'should call end with raw (non-json) data', ()->
      @body = '<html></html>'
      assert @res.end, @res.send
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
  context 'res.error', ()->
    before (done)->
      @res.end = (args)=>
        @args = JSON.parse(args)
        return done null
      @res.error new Error("error!")
    it 'should have error message', ()->
      assert @args.error.message
    it 'should have stack', ()->
      assert @args.error.stack
    it 'should have name', ()->
      assert @args.error.name
