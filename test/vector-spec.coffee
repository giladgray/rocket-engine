chai = require 'chai'
expect = chai.expect

Vector = require '../src/utils/vector.coffee'

describe 'Vector', ->
  equal = (v1, v2, expected=true) ->
    query = expect(v1)
    query = query.not unless expected
    query.to.deep.equal v2

  describe '#new', ->
    it 'creates a new Vector', ->
      v = Vector.new(1, 2)
      expect(v).to.deep.equal {x: 1, y: 2}

    it 'no arguments creates a new empty Vector', ->
      expect(Vector.new()).to.deep.equal {x: 0, y: 0}

  describe '#clone', ->
    it 'creates a new vector with same values as argument', ->
      v1 = Vector.new(3, 4)
      v2 = Vector.clone(v1)
      expect(v1 is v2).to.be.false
      expect(v1).to.deep.equal v2

  describe '#fromPolar', ->
    it 'creates a new vector with (x,y) describing (r,θ)', ->
      equal Vector.fromPolar(10, 0), Vector.new(10, 0)
      equal Vector.fromPolar(10, Math.PI / 2), Vector.new(0, 10)
      equal Vector.fromPolar(10, Math.PI), Vector.new(-10, 0)

  describe '#equal', ->
    it 'determines equality for two vectors', ->
      v = Vector.new(10, 20)
      expect(Vector.equal(v, Vector.new(10, 20))).to.be.true
      expect(Vector.equal(v, Vector.new(20, 20))).to.be.false

  describe '#add', ->
    it 'adds two vectors', ->
      equal Vector.add(Vector.new(10, 20), Vector.new(30, 40)), Vector.new(40, 60)

    it 'updates first vector components in place', ->
      v1 = Vector.new(20, 20)
      v2 = Vector.add(v1, Vector.new(1, 2))
      expect(v1 is v2).to.be.true
      expect(v1.x).to.equal 21
      expect(v1.y).to.equal 22

  describe '#sub', ->
    it 'subs two vectors', ->
      equal Vector.sub(Vector.new(10, 20), Vector.new(10, 10)), Vector.new(0, 10)

  describe '#scale', ->
    it 'multiplies both components', ->
      v = Vector.new(10, 20)
      equal Vector.scale(v,  2), Vector.new( 20,  40)
      equal Vector.scale(v, -2), Vector.new(-40, -80)

  describe '#invert', ->
    it 'scales by -1', ->
      v = Vector.new(20, 5)
      equal Vector.invert(v), Vector.new(-20, -5)

  describe '#angle', ->
    it 'computes angle of vector in radians', ->
      expect(Vector.angle(Vector.new(1, 0))).to.equal 0
      expect(Vector.angle(Vector.new(0, 1))).to.equal Math.PI / 2
      expect(Vector.angle(Vector.new(1, 1))).to.equal Math.PI / 4

    it 'handles obtuse angles too', ->
      expect(Vector.angle(Vector.new(-1, 0))).to.equal Math.PI
      expect(Vector.angle(Vector.new(-1, -1))).to.equal -Math.PI * 3 / 4

  describe '#dist', ->
    it 'returns positive distance of vector', ->
      v = Vector.new(10, 0)
      expect(Vector.dist v).to.equal 10
      v = Vector.new(0, -10)
      expect(Vector.dist v).to.equal 10
      v = Vector.new(-1, 1)
      expect(Vector.dist v).to.equal Math.sqrt(2)

  describe 'clone=true', ->
    v1 = v2 = null
    beforeEach ->
      v1 = Vector.new(30, 40)
      v2 = Vector.new(20, 80)

    describe '#add', ->
      it 'adds vector components', ->
        v = Vector.add v1, v2, true
        equal v, Vector.new(50, 120)

      it 'returns a new Vector, leaves originals unchanged', ->
        v = Vector.add v1, v2, true
        expect(v is v1).to.be.false
        expect(v1.x).to.equal 30

    describe '#sub', ->
      it 'subs vector components', ->
        v = Vector.sub v1, v2, true
        equal v, Vector.new(10, -40)

      it 'returns a new Vector, leaves originals unchanged', ->
        v = Vector.sub v1, v2, true
        expect(v is v1).to.be.false
        expect(v1.x).to.equal 30

    describe '#scale', ->
      it 'scale vector components', ->
        v = Vector.scale v1, 2, true
        equal v, Vector.new(60, 80)

      it 'returns a new Vector, leaves originals unchanged', ->
        v = Vector.scale v1, 3, true
        expect(v is v1).to.be.false
        expect(v1.x).to.equal 30
