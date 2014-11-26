chai = require 'chai'
expect = chai.expect

System = require '../src/system.coffee'

describe 'System', ->
  it 'should require name', ->
    expect(-> new System).to.throw /name/

  it 'should require reqs array', ->
    expect(-> new System 'bad').to.throw /required/

  it 'should require action', ->
    expect(-> new System 'bad', ['reqs']).to.throw /action/

  describe '#action', ->
    it 'should be invoked in System context', ->
      sys = new System 'name', ['reqs'], -> @
      expect(sys.action()).to.deep.equal sys

  describe '.forEach', ->
    it 'should return an instance of System', ->
      expect(System.forEach('name', ['reqs'], ->)).to.be.instanceof System

    it 'should create an action function that calls the given function for each key', ->
      keys = ['one', 'two', 'three']
      fnKeys = []
      sys = System.forEach 'name', [], (rocket, key) -> fnKeys.push key
      sys.action null, keys
      expect(fnKeys).to.deep.equal keys
