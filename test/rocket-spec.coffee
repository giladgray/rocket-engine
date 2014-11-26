chai = require 'chai'
expect = chai.expect

Rocket = require '../src/rocket.coffee'

describe 'Rocket', ->
  rocket = null
  posFn  = (comp, options) -> comp.position = options.position
  posObj = {position: [0, 0]}

  beforeEach -> rocket = new Rocket

  it 'should exist', ->
    expect(rocket).to.exist

  describe '#key', ->
    it 'should require an object', ->
      expect(rocket.key).to.throw

    it 'should create a new key ID', ->
      rocket.key({})
      expect(rocket.getKeys()).to.have.length 1

    it 'should auto-assign string ID', ->
      expect(rocket.key({})).to.be.a.string

    it 'should define labels for undefined components', ->
      rocket.key {label: 'foo', otherLabel: null}
      # TODO: not convinced this test is important
      expect(rocket._labels).to.have.keys ['label', 'otherLabel']

    it 'should add component entry for defined components', ->
      position = {position: [1, 2]}
      rocket.component 'position', posFn
      key = rocket.key {position}

      posComp = rocket.getComponent('position')
      expect(posComp[key]).to.exist
      expect(posComp[key]).to.deep.equal position

    it 'should use default values for defined components', ->
      rocket.component 'position', posObj
      key = rocket.key {position: null}
      expect(rocket.getComponent('position')[key]).to.deep.equal posObj

    it 'should use provided values for defined components', ->
      rocket.component 'position', posObj
      position = {position: [2, -1]}
      key = rocket.key {position}
      expect(rocket.getComponent('position')[key]).to.deep.equal position

  describe '#keys', ->
    it 'should create multiple keys', ->
      rocket.component 'position', {x: 0, y: 0}
      expect(rocket.keys [{position: null}, {position: null}, {ship: null}]).to.have.length 3
      expect(rocket.getKeys()).to.have.length 3

  describe '#component', ->
    it 'should accept a function', ->
      rocket.component('position', posFn)
      # TODO: don't like inspecting internals
      expect(rocket._componentTypes.position).to.equal posFn

    it 'should convert an object to a function', ->
      rocket.component('position', posObj)
      expect(rocket._componentTypes.position).to.be.a.function

    it 'converted function should assign object defaults', ->
      rocket.component('position', posObj)
      expect(rocket._componentTypes.position({})).to.deep.equal posObj
      expect(rocket._componentTypes.position({position: [1, 2]})).to.deep.equal {position: [1, 2]}

  describe '#components', ->
    it 'should create multiple components', ->
      rocket.components
        position: {x: 0, y: 0}
        velocity: {x: 0, y: 0}
      expect(rocket.getComponent('position')).to.exist
      expect(rocket.getComponent('velocity')).to.exist

  describe '#getData', ->
    it 'should return data associated with first key for component name', ->
      config = {foo: 'bar', baz: 'qux'}
      rocket.component 'config', config
      rocket.key {config: null}
      expect(rocket.getData 'config').to.deep.equal config

  describe '#dataFor', ->
    it 'should return component value associated with key when it exists', ->
      rocket.component 'position', {x: 10}
      key = rocket.key {position: null}
      expect(rocket.dataFor key, 'position').to.deep.equal {x: 10}

    it 'should return undefined when value does not exist', ->
      expect(rocket.dataFor 'key', 'position').to.be.undefined
      expect(rocket.dataFor 'key').to.be.undefined

  describe '#filterKeys', ->
    beforeEach ->
      rocket.components
        position : {x: 0, y: 0}
        velocity : {x: 0, y: 0}
        mass     : {mass: 10}
        density  : {density: 1.0}
        amoeba   : {}

      rocket.keys [
        {position: null, velocity: null, mass: null, density: null}
        {position: null, velocity: null, mass: null}
        {position: null, velocity: null, density: null}
        {position: null, velocity: null}
        {position: null, density: null}
        {position: null, mass: null}
      ]

    it 'should return all keys that contain all listed properties', ->
      expect(rocket.filterKeys ['position', 'velocity', 'density']).to.have.length 2
      expect(rocket.filterKeys ['position', 'mass']).to.have.length 3
      expect(rocket.filterKeys ['density']).to.have.length 3

    it 'should accept splat of names instead of array', ->
      expect(rocket.filterKeys 'position', 'velocity', ['density']).to.have.length 2
      expect(rocket.filterKeys 'density').to.have.length 3

    it 'should return empty array if no keys match', ->
      expect(rocket.filterKeys 'amoeba').to.be.empty

  describe '#system', ->
    movement = (pkt, keys, position, velocity) ->
      for key in keys
        position[key].x += velocity[key].x
        position[key].y += velocity[key].y

    it 'should register a new system', ->
      rocket.system('movement', ['position', 'velocity'], movement)
      expect(rocket.getSystems()).to.have.members ['movement']

    it 'should accept instance of System', ->
      sys = new Rocket.System('test', [], ->)
      rocket.system sys
      expect(rocket.getSystems()).to.have.members ['test']

    describe 'component interference', ->
      key1 = key2 = key3 = null
      beforeEach ->
        rocket.component 'square', {size: 10, color: 'red'}
        key1 = rocket.key {one: null, square: null}
        key2 = rocket.key {two: null, square: null}
        key3 = rocket.key {three: null, square: {size: 10, color: 'blue'}}

      it 'changing component value in system should not affect other instances', ->
        rocket.systemForEach 'one', ['square', 'one'], (p, k, square) ->
          square.color = 'green'
        rocket.tick()
        expect(rocket.dataFor(key1, 'square').color).to.equal 'green'
        expect(rocket.dataFor(key2, 'square').color).to.equal 'red'
        expect(rocket.dataFor(key3, 'square').color).to.equal 'blue'

  describe '#systemForEach', ->
    movementEach = (pkt, key, pos, vel) ->
      pos.x += vel.x
      pos.y += vel.y

    it 'should register a new system', ->
      rocket.systemForEach 'movement', ['position', 'velocity'], movementEach
      expect(rocket.getSystems()).to.have.members ['movement']
