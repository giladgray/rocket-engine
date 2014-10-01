chai = require 'chai'
expect = chai.expect

rectangle = (rect1...) ->
  overlaps: (rect2...) ->
    xOverlap = yOverlap = true
    if rect1[0] > rect2[0] + rect2[2] or rect1[0] + rect1[2] < rect2[0]
      xOverlap = false
    if rect1[1] > rect2[1] + rect2[3] or rect1[1] + rect1[3] < rect2[1]
      yOverlap = false
    return xOverlap and yOverlap

describe 'rectangleOverlap', ->
  it 'should return false if R1 left of R2', ->
    r1 = [0, 0, 10, 10]
    r2 = [20, 0, 10, 10]
    expect(rectangle(r1...).overlaps(r2...)).to.be.false

  it 'should return false if R1 right of R2', ->
    r1 = [20, 0, 10, 10]
    r2 = [0, 0, 10, 10]
    expect(rectangle(r1...).overlaps(r2...)).to.be.false

  it 'should return false if R1 above R2', ->
    r1 = [0, 0, 10, 20]
    r2 = [0, 100, 20, 40]
    expect(rectangle(r1...).overlaps(r2...)).to.be.false

  it 'should return false if R1 below R2', ->
    r1 = [0, 100, 20, 40]
    r2 = [0, 0, 10, 20]
    expect(rectangle(r1...).overlaps(r2...)).to.be.false

  it 'should return true if R1 overlaps R2', ->
    r1 = [0, 0, 20, 20]
    r2 = [10, 10, 20, 20]
    expect(rectangle(r1...).overlaps(r2...)).to.be.true

  it 'should return true if R2 overlaps R1', ->
    r1 = [10, 10, 20, 20]
    r2 = [0, 0, 20, 20]
    expect(rectangle(r1...).overlaps(r2...)).to.be.true

  it 'should return true if R1 inside R2', ->
    r1 = [10, 10, 10, 10]
    r2 = [0, 0, 30, 30]
    expect(rectangle(r1...).overlaps(r2...)).to.be.true
