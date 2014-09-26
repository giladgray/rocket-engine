chai = require 'chai'
expect = chai.expect

Pocket = require '../src/pocket.coffee'

describe 'Pocket', ->
  pocket = null
  posFn = (comp, options) -> comp.position = options.position

  beforeEach -> pocket = new Pocket()

  it 'should exist', ->
    expect(pocket).to.exist

  describe '#key', ->
    it 'should require an object', ->
      expect(pocket.key).to.throw

    it 'should auto-assign string ID', ->
      expect(pocket.key({})).to.be.a.string

    it 'should define labels for undefined components', ->
      pocket.key {label: 'foo', otherLabel: null}
      expect(pocket.labels).to.have.keys ['label', 'otherLabel']

    it 'should add component entry for defined components', ->
      position = {position: [1, 2]}
      pocket.component 'position', posFn
      key = pocket.key {position}

      expect(pocket.components.position[key]).to.exist
      expect(pocket.components.position[key]).to.deep.equal position

    it 'should use default values for defined components', ->
      posObj = {position: [0, 0]}
      pocket.component 'position', posObj
      key = pocket.key {position: null}
      expect(pocket.components.position[key]).to.deep.equal posObj

    it 'should use provided values for defined components', ->
      posObj = {position: [0, 0]}
      pocket.component 'position', posObj
      position = {position: [2, -1]}
      key = pocket.key {position}
      expect(pocket.components.position[key]).to.deep.equal position

  describe '#component', ->
    it 'should accept a function', ->
      pocket.component('position', posFn)
      expect(pocket.componentTypes.position).to.equal posFn

    it 'should convert an object to a function', ->
      posObj = {position: [0, 0]}
      pocket.component('position', posObj)
      expect(pocket.componentTypes.position).to.be.a.function

    it 'converted function should assign object defaults', ->
      posObj = {position: [0, 0]}
      pocket.component('position', posObj)
      expect(pocket.componentTypes.position({})).to.deep.equal posObj
      expect(pocket.componentTypes.position({position: [1, 2]})).to.deep.equal {position: [1, 2]}

  describe '#getData', ->
    it 'should return data associated with first key for component name', ->
      config = {foo: 'bar', baz: 'qux'}
      pocket.component 'config', config
      pocket.key {config: null}
      expect(pocket.getData 'config').to.deep.equal config
