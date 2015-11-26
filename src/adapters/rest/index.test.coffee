Adapter = require './'
assert = require 'assert'

describe 'rest adapter', ()->
  before ()->
    @req = {}
    @res = {}
    @opts = {"opts":"opts"}
    Adapter @req, @res, @opts
  it 'should copy opts to res.opts', ()->
    assert.deeqEqual @opts, @req.opts
  context 'res.json', ()->
    it 'should call end with formatted body', ()->
      @body = {'args': 'args'}
      @res.end = (args)=>
        args = JSON.parse(args)
        assert.deepEqual args.body, @body
      @res.json @body
  context 'res.setStatus', ()->
    it 'should set status of response', ()->
      @res.setStatus 200
      @res.end = (args)=>
        args = JSON.parse(args)
        assert.equal args.status, 200
      @res.json {}
  context 'res.setHeaders', ()->
    it 'should set headers of response', ()->
      @res.setHeaders
        'content-type': 'application/json'
      @res.end = (args)=>
        args = JSON.parse(args)
        assert.equal args.headers['content-type'], 'application/json'
      @res.json {}
