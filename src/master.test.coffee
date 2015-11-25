Master = require './master'
assert = require 'assert'

describe 'task master', ()->
  before ()->
    @before =[
      ->
    ]
    @after = [
      ->
    ]
    @url = "tcp://127.0.0.1:5555"
    @path = "/master"
    opts =
      before: @before
      after: @after
      url: @url
      path: @path
    @master = new Master opts
  context 'constructor', ()->
    it 'should set @before, @after, @url, and @path', ()->
      assert.deepEqual @master.before, @before
      assert.deepEqual @master.after, @after
      assert.equal @master.path, @path
      assert.equal @master.url, @url
  context 'methods', ()->
    describe 'use', ()->
      before ()->
        @fn = ->
        @master.use @fn
      it 'should push middleware function to @before', ()->
        assert.equal @fn, @master.before[1]
    describe 'worker', ()->
      before ()->
        @cb = (req, res, next)->
        @workerPath = "/findById"
        @master.worker @workerPath, @cb
      it 'should push worker config to @workers', ()->
        assert.equal @master.workers.length, 1
        assert.equal @master.workers[0].path, @workerPath
        assert.equal @master.workers[0].cb, @cb
    describe 'start', ()->
      it 'should create workers from worker config'
      it 'should start workers'
