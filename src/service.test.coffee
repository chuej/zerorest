Service = require './service'
assert = require 'assert'

describe 'service provider', ()->
  context 'constructor', ()->
    it 'should set url'
    it 'should create broker'
  context 'methods', ()->
    describe 'use', ()->
      it 'should push fn to @before'
    describe 'master', ()->
      it 'should create new master with given path'
    describe 'start', ()->
      it 'should start broker'
      it 'should start masters'
