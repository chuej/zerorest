Adapter = require './'
assert = require 'assert'

describe 'rest adapter', ()->
  before ()->
    @req = {}
    @res =
      end: ->
    @opts = {}
    Adapter @req, @res, @opts
  context 'res.json', ()->
    it 'should call end with formatted body', ()->
      @body = {'args': 'args'}
      @res.end = (args)=>
        assert.equal args.body, @body
      @res.json @body
  context 'res.setStatus', ()->
    it 'should set status of response', ()->
      @res.setStatus 200
      @res.end = (args)=>
        assert.equal args.status, 200
      @res.json {}
  context 'res.setHeaders', ()->
    it 'should set headers of response', ()->
      @res.setHeaders
        'content-type': 'application/json'
      @res.end = (args)=>
        assert.equal args.headers['content-type'], 'application/json'
      @res.json {}
