chai = require 'chai'
expect = chai.expect

V2 = require '../src/utils/vector.coffee'

describe 'Vector2', ->
  equal = (v1, v2, expected=true) ->
    expect(V2.equal(v1, v2)).to.equal expected

  describe '#new', ->
    it 'creates a new Vector', ->
      v = V2.new(1, 2)
      expect(v).to.deep.equal {x: 1, y: 2}

    it 'no arguments creates a new empty Vector', ->
      expect(V2.new()).to.deep.equal {x: 0, y: 0}

  describe '#clone', ->
    it 'creates a new vector with same values as argument', ->
      v1 = V2.new(3, 4)
      v2 = V2.clone(v1)
      expect(v1 is v2).to.be.false
      expect(v1).to.deep.equal v2

  describe '#equal', ->
    it 'determines equality for two vectors', ->
      v = V2.new(10, 20)
      expect(V2.equal(v, V2.new(10, 20))).to.be.true
      expect(V2.equal(v, V2.new(20, 20))).to.be.false

  describe '#add', ->
    it 'adds two vectors', ->
      equal V2.add(V2.new(10, 20), V2.new(30, 40)), V2.new(40, 60)

    it 'updates first vector components in place', ->
      v1 = V2.new(20, 20)
      v2 = V2.add(v1, V2.new(1, 2))
      expect(v1 is v2).to.be.true
      expect(v1.x).to.equal 21
      expect(v1.y).to.equal 22

  describe '#sub', ->
    it 'subs two vectors', ->
      equal V2.sub(V2.new(10, 20), V2.new(10, 10)), V2.new(0, 10)

  describe '#scale', ->
    it 'multiplies both components', ->
      v = V2.new(10, 20)
      equal V2.scale(v,  2), V2.new( 20,  40)
      equal V2.scale(v, -2), V2.new(-40, -80)

  describe '#invert', ->
    it 'scales by -1', ->
      v = V2.new(20, 5)
      equal V2.invert(v), V2.new(-20, -5)

  describe '#angle', ->
    it 'computes angle of vector in radians', ->
      expect(V2.angle(V2.new(1, 0))).to.equal 0
      expect(V2.angle(V2.new(0, 1))).to.equal Math.PI / 2
      expect(V2.angle(V2.new(1, 1))).to.equal Math.PI / 4

    it 'handles obtuse angles too', ->
      expect(V2.angle(V2.new(-1, 0))).to.equal Math.PI
      expect(V2.angle(V2.new(-1, -1))).to.equal -Math.PI * 3 / 4

  describe '#length', ->
    it 'returns positive length of vector', ->
      v = V2.new(10, 0)
      expect(V2.length v).to.equal 10
      v = V2.new(0, -10)
      expect(V2.length v).to.equal 10
      v = V2.new(-1, 1)
      expect(V2.length v).to.equal Math.sqrt(2)

  describe 'clone=true', ->
    v1 = v2 = null
    beforeEach ->
      v1 = V2.new(30, 40)
      v2 = V2.new(20, 80)

    describe '#add', ->
      it 'adds vector components', ->
        v = V2.add v1, v2, true
        equal v, V2.new(50, 120)

      it 'returns a new Vector, leaves originals unchanged', ->
        v = V2.add v1, v2, true
        expect(v is v1).to.be.false
        expect(v1.x).to.equal 30

    describe '#sub', ->
      it 'subs vector components', ->
        v = V2.sub v1, v2, true
        equal v, V2.new(10, -40)

      it 'returns a new Vector, leaves originals unchanged', ->
        v = V2.sub v1, v2, true
        expect(v is v1).to.be.false
        expect(v1.x).to.equal 30

    describe '#scale', ->
      it 'scale vector components', ->
        v = V2.scale v1, 2, true
        equal v, V2.new(60, 80)

      it 'returns a new Vector, leaves originals unchanged', ->
        v = V2.scale v1, 3, true
        expect(v is v1).to.be.false
        expect(v1.x).to.equal 30
