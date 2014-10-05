chai = require 'chai'
expect = chai.expect

Rectangle = require '../src/utils/rectangle.coffee'

describe 'Rectangle', ->
  equal = (r1, r2, expected=true) ->
    query = expect(r1)
    query = query.not unless expected
    query.to.deep.equal r2

  describe '#new', ->
    it 'creates a new empty Rectangle', ->
      r = Rectangle.new(1, 2, 3, 4)
      expect(r).to.deep.equal {x: 1, y: 2, width: 3, height: 4}

    it 'create a new square', ->
      r = Rectangle.new(4, 5, 6)
      expect(r).to.deep.equal {x: 4, y: 5, width: 6, height: 6}

    it 'no arguments creates a new empty Rectangle', ->
      expect(Rectangle.new()).to.deep.equal {x: 0, y: 0, width: 0, height: 0}

  describe '#clone', ->
    it 'creates a new rectangle with same values as argument', ->
      r1 = Rectangle.new(3, 4, 5, 6)
      r2 = Rectangle.clone(r1)
      expect(r1 is r2).to.be.false
      expect(r1).to.deep.equal r2

  describe '#centered', ->
    it 'creates a new rectangle about the given center', ->
      r = Rectangle.centered(10, 10, 20, 20)
      expect(r).to.deep.equal Rectangle.new(0, 0, 20, 20)

  describe '#equal', ->
    it 'determines equality for two rectangles', ->
      r = Rectangle.new(10, 20)
      expect(Rectangle.equal(r, Rectangle.new(10, 20))).to.be.true
      expect(Rectangle.equal(r, Rectangle.new(10, 20, 100))).to.be.false
      expect(Rectangle.equal(r, Rectangle.new(20, 20))).to.be.false

  describe '#area', ->
    it 'returns area of rectangle', ->
      expect(Rectangle.area Rectangle.new(10, 20, 30, 40)).to.equal 30 * 40
      expect(Rectangle.area Rectangle.new(0, 0, 20, 30)).to.equal 20 * 30

  describe '#overlaps', ->
    rLeft = rRight = rOuter = rGiant = null
    before ->
      rLeft = Rectangle.centered(10, 5, 20, 10)
      rRight = Rectangle.new(30, 5, 20, 10)
      rOuter = Rectangle.centered(10, 5, 24, 16)
      rGiant = Rectangle.new(10, -10, 30, 30)

    it 'should return false if rectangles do not overlap', ->
      expect(Rectangle.overlap(rLeft, rRight)).to.be.false

    it 'should return false if rectangles do not overlap in reverse order', ->
      expect(Rectangle.overlap(rRight, rLeft)).to.be.false

    it 'should return true if rectangles overlap', ->
      expect(Rectangle.overlap(rLeft, rGiant)).to.be.true
      expect(Rectangle.overlap(rRight, rGiant)).to.be.true

    it 'should return true if R1 fully contains R2', ->
      expect(Rectangle.overlap(rOuter, rLeft)).to.be.true

    it 'should return true if R1 is fully contained by R2', ->
      expect(Rectangle.overlap(rLeft, rOuter)).to.be.true
