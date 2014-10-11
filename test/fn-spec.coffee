chai = require 'chai'
expect = chai.expect

fn = require '../src/fn.coffee'

describe 'fn', ->
  describe '.uniqueId()', ->
    it 'should generate a string', ->
      expect(fn.uniqueId).to.be.a.string

    it 'should generate a new id each time', ->
      id1 = fn.uniqueId()
      id2 = fn.uniqueId()
      expect(id1).to.not.equal id2

    it 'should accept a prefix', ->
      expect(fn.uniqueId('key-')).to.match /^key-/

  describe '.is* type checks', ->
    types =
      isString: "foo"
      isNumber: 5
      isBoolean: true
      isObject: {dog: 'cat'}
      isArray: [1, 'a', 47, 'xy']
      isFunction: -> 6
    it 'should correctly detect all six basic types', ->
      for type, value of types
        for test of types
          expect(fn[test](value)).to.equal type is test, "expected #{value} to pass #{test}"

  describe '.flatten', ->
    it 'should return a single array unchanged', ->
      expect(fn.flatten [1,2,3]).to.deep.equal [1,2,3]

    it 'should return a one-element array for a single value', ->
      expect(fn.flatten 5).to.deep.equal [5]

    it 'should merge a series of arrays', ->
      expect(fn.flatten [1,2], [3,4], [5,6]).to.deep.equal [1,2,3,4,5,6]
      expect(fn.flatten [2,2], [1], [3,3,3]).to.deep.equal [2,2,1,3,3,3]

    it 'should merge mixed arrays and single values', ->
      expect(fn.flatten 1, [3, 5], 6, [7, 9, 10]).to.deep.equal [1,3,5,6,7,9,10]

    it 'should handle mixed types', ->
      func = -> 7
      expect(fn.flatten true, [{}, 'a'], 'foo', false, 7, func, [1, 2])
        .to.deep.equal [true, {}, 'a', 'foo', false, 7, func, 1, 2]

    it 'should merge nested arrays', ->
      expect(fn.flatten [1, [2, 3], 'x', [4, [5, 6]]]).to.deep.equal [1,2,3,'x',4,5,6]

  describe '.merge', ->
    it 'should produce one object with union of keys', ->
      expect(fn.merge {x:5}, {y:3}).to.deep.equal {x:5, y:3}

    it 'intersecting keys should assume last value', ->
      expect(fn.merge {x: 5, y: 3}, {y: 'z'}).to.deep.equal {x: 5, y: 'z'}

    it 'should modify destination object', ->
      obj = {x: 1}
      fn.merge obj, {x: 3}, {z: {cat: 'dog'}}, {x: 'foo'}
      expect(obj).to.deep.equal {x: 'foo', z: {cat: 'dog'}}

    it 'should recursively merge objects', ->
      names = character: {name: 'barney'}
      ages  = character: { age: 24      }
      merged = fn.merge names, ages
      expect(merged).to.deep.equal
        character: {name: 'barney', age: 24}

    # it 'should recursively merge objects', ->
    #   names = characters: [{name: 'barney'}, {name: 'fred'}]
    #   ages  = characters: [{ age: 24      }, { age: 40    }]
    #   merged = fn.merge names, ages
    #   expect(merged).to.deep.equal characters: [
    #     name: 'barney', age: 24
    #     name: 'fred', age: 40
    #   ]

  describe '.clone', ->
    it 'should create a new copy of the object with same properties', ->
      o1 = {x: 'hello'}
      o2 = fn.clone(o1)
      expect(o1).to.not.equal(o2)
      expect(o1).to.deep.equal(o2)

    it 'should clone sub-objects', ->
      o1 = {location: {city: 'SF', state: 'CA'}}
      o2 = fn.clone(o1)
      expect(o1).to.not.equal(o2)
      expect(o1).to.deep.equal(o2)
      expect(o1.location).to.not.equal(o2.location)
      expect(o1.location).to.deep.equal(o2.location)

  describe '.defaults', ->
    it 'should assign properties that are undefined in destination', ->
      expect(fn.defaults {x: 6}, {x: 10, y: 30, z: 'bar'}).to.deep.equal {x: 6, y: 30, z: 'bar'}

    it 'should stop assigning property once it is assigned', ->
      expect(fn.defaults {x: 1}, {x: 2, y: 'a'}, {x: 3, y: 'b', z: true})
        .to.deep.equal {x: 1, y: 'a', z: true}

    it 'should ignore undefined default values', ->
      expect(fn.defaults {x: 1}, {x: undefined, y: 'x'})
        .to.deep.equal {x: 1, y: 'x'}

  describe '.pluck', ->
    it 'should return property from each value in collection', ->
      expect(fn.pluck [{name: 'fred'}, {name: 'barney'}], 'name').to.deep.equal ['fred', 'barney']

    it 'should return undefined if the property is not defined for an element', ->
      expect(fn.pluck [{name: 'fred'}, {age: 24}], 'name').to.deep.equal ['fred', undefined]
