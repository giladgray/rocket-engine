chai = require 'chai'
expect = chai.expect

Pocket = require '../src/pocket.coffee'

describe 'Pocket', ->
  it 'should exist', ->
    new Pocket()
