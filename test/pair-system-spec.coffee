chai = require 'chai'
expect = chai.expect

Rocket = require '../src/rocket.coffee'
PairSystem = require '../src/utils/pair-system.coffee'

describe 'PairSystem', ->
  rocket = null
  beforeEach ->
    rocket = new Rocket

  fillRocket = (a, b) ->
    a ?= 'abc'.split('')
    b ?= '123'.split('')
    rocket.component 'letter', {index: '0'}
    rocket.component 'number', {index: 0}
    for l in a
      rocket.key
        letter: {index: l}
    for n in b
      rocket.key
        number: {index: n}
    return [a, b]

  it 'should require name', ->
    expect(-> new PairSystem).to.throw /name/

  it 'should require one reqs array', ->
    expect(-> new PairSystem 'bad').to.throw /required/

  it 'should require two reqs arrays', ->
    expect(-> new PairSystem 'bad', ['reqs']).to.throw /two/

  it 'reqs must be arrays', ->
    expect(-> new PairSystem 'bad', 'times', 'abound').to.throw /array/i

  it 'should require action', ->
    expect(-> new PairSystem 'bad', ['reqsA'], ['reqsB']).to.throw /action/

  it 'action must be function', ->
    expect(-> new PairSystem 'bad', ['reqsA'], ['reqsB'], 'action').to.throw /function/i

  it 'system.action should not be the same as actionFn', ->
    actionFn = ->
    sys = new PairSystem 'bad', ['reqsA'], ['reqsB'], actionFn
    expect(sys.action).to.not.equal actionFn

  describe '#action', ->
    it 'should run as a system in a Rocket', ->
      fillRocket('a', '1')
      sys = new PairSystem 'a1-all', ['letter'], ['number'], (p, [a, l], [b, n]) ->
        @result = l[a[0]].index + n[b[0]].index
      rocket.system sys
      rocket._runSystems()
      expect(sys.result).to.equal 'a1'

    it 'should be invoked in PairSystem context', ->
      fillRocket('a', '1')
      sys = new PairSystem 'empty', ['letter'], ['number'], -> sys.context = @
      sys.action(rocket)
      expect(sys.context).to.deep.equal sys

  describe '.forEach', ->
    it 'should return an instance of PairSystem', ->
      expect(PairSystem.forEach('name', ['reqsA'], ['reqsB'], ->)).to.be.instanceof PairSystem

    it 'should create an action function that calls the given function for each key', ->
      [keysA, keysB] = fillRocket()
      expected = []
      for a in keysA
        for b in keysB
          expected.push a + b
      fnKeys = []
      rocket.system PairSystem.forEach 'a1...', ['letter'], ['number'],
        (rocket, [a, letter], [b, number]) -> fnKeys.push letter.index + number.index
      rocket._runSystems()
      expect(fnKeys).to.deep.equal expected
