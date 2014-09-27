chai = require 'chai'
expect = chai.expect

Pocket = require '../src/pocket.coffee'

describe 'Pocket', ->
  pocket = null
  posFn  = (comp, options) -> comp.position = options.position
  posObj = {position: [0, 0]}

  beforeEach -> pocket = new Pocket()

  it 'should exist', ->
    expect(pocket).to.exist

  describe '#key', ->
    it 'should require an object', ->
      expect(pocket.key).to.throw

    it 'should create a new key ID', ->
      pocket.key({})
      expect(pocket.getKeys()).to.have.length 1

    it 'should auto-assign string ID', ->
      expect(pocket.key({})).to.be.a.string

    it 'should define labels for undefined components', ->
      pocket.key {label: 'foo', otherLabel: null}
      # TODO: not convinced this test is important
      expect(pocket._labels).to.have.keys ['label', 'otherLabel']

    it 'should add component entry for defined components', ->
      position = {position: [1, 2]}
      pocket.component 'position', posFn
      key = pocket.key {position}

      posComp = pocket.getComponent('position')
      expect(posComp[key]).to.exist
      expect(posComp[key]).to.deep.equal position

    it 'should use default values for defined components', ->
      pocket.component 'position', posObj
      key = pocket.key {position: null}
      expect(pocket.getComponent('position')[key]).to.deep.equal posObj

    it 'should use provided values for defined components', ->
      pocket.component 'position', posObj
      position = {position: [2, -1]}
      key = pocket.key {position}
      expect(pocket.getComponent('position')[key]).to.deep.equal position

  describe '#keys', ->
    it 'should create multiple keys', ->
      pocket.component 'position', {x: 0, y: 0}
      expect(pocket.keys [{position: null}, {position: null}, {ship: null}]).to.have.length 3
      expect(pocket.getKeys()).to.have.length 3

  describe '#component', ->
    it 'should accept a function', ->
      pocket.component('position', posFn)
      # TODO: don't like inspecting internals
      expect(pocket._componentTypes.position).to.equal posFn

    it 'should convert an object to a function', ->
      pocket.component('position', posObj)
      expect(pocket._componentTypes.position).to.be.a.function

    it 'converted function should assign object defaults', ->
      pocket.component('position', posObj)
      expect(pocket._componentTypes.position({})).to.deep.equal posObj
      expect(pocket._componentTypes.position({position: [1, 2]})).to.deep.equal {position: [1, 2]}

  describe '#components', ->
    it 'should create multiple components', ->
      pocket.components
        position: {x: 0, y: 0}
        velocity: {x: 0, y: 0}
      expect(pocket.getComponent('position')).to.exist
      expect(pocket.getComponent('velocity')).to.exist

  describe '#getData', ->
    it 'should return data associated with first key for component name', ->
      config = {foo: 'bar', baz: 'qux'}
      pocket.component 'config', config
      pocket.key {config: null}
      expect(pocket.getData 'config').to.deep.equal config

  describe '#filterKeys', ->
    beforeEach ->
      pocket.components
        position : {x: 0, y: 0}
        velocity : {x: 0, y: 0}
        mass     : {mass: 10}
        density  : {density: 1.0}
        amoeba   : {}

      pocket.keys [
        {position: null, velocity: null, mass: null, density: null}
        {position: null, velocity: null, mass: null}
        {position: null, velocity: null, density: null}
        {position: null, velocity: null}
        {position: null, density: null}
        {position: null, mass: null}
      ]

    it 'should return all keys that contain all listed properties', ->
      expect(pocket.filterKeys ['position', 'velocity', 'density']).to.have.length 2
      expect(pocket.filterKeys ['position', 'mass']).to.have.length 3
      expect(pocket.filterKeys ['density']).to.have.length 3

    it 'should return empty array if no keys match', ->
      expect(pocket.filterKeys ['amoeba']).to.be.empty
