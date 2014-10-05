chai = require 'chai'
expect = chai.expect

KeyboardState = require '../src/utils/keyboard-state.coffee'

describe 'KeyboardState', ->
  describe 'convertKeymap', ->
    it 'should convert single-character key names to their corresponding key codes', ->
      map = KeyboardState.convertKeymap
        W: 'UP'
        S: 'DOWN'
      expect(map).to.deep.equal
        87: 'UP'
        83: 'DOWN'

    it 'should leave key codes unchanged', ->
      map = KeyboardState.convertKeymap
        W: 'JUMP'
        32: 'SLIDE'
      expect(map).to.deep.equal
        87: 'JUMP'
        32: 'SLIDE'

    it 'should handle special word names', ->
      map = KeyboardState.convertKeymap
        Enter: 'ENTER'
        Space: 'SPACE'
        Esc: 'JUMP'
        Tab: 'SWISH'
        Bksp: 'LOSE'
        Down: 'CRASH'
      expect(map).to.deep.equal
        8: 'LOSE'
        9: 'SWISH'
        13: 'ENTER'
        32: 'SPACE'
        27: 'JUMP'
        40: 'CRASH'
