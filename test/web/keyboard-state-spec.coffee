chai = require 'chai'
expect = chai.expect

# THIS TEST ONLY WORKS IN THE BROWSER
return unless document?

Pocket = require '../../src/pocket.coffee'
Keyboard = require '../../src/utils/keyboard-state.coffee'

describe 'KeyboardState', ->
  pocket = null
  keyboard = null

  makeKeyboard = (options = null) ->
    pocket = new Pocket
    pocket.component 'keyboard-state', Keyboard
    pocket.key {'keyboard-state': options}
    keyboard = pocket.getData 'keyboard-state'
    return keyboard

  triggerKeyEvent = (type, key) ->
    # evt = document.createEvent("KeyboardEvents");
    # (evt.initKeyEvent || evt.initKeyboardEvent)("keypress",
    #   true, true, window, key.charCodeAt(0), 0, false, false, false, false, false) #0, 0, 0, 0, key.charCodeAt(0))
    evt = new KeyboardEvent type,
      bubbles    : true
      cancelable : true
      which      : key.charCodeAt(0)
      keyCode    : key.charCodeAt(0)
      # char       : key.charCodeAt(0)
      # key        : key.charCodeAt(0)
    keyboard.target.dispatchEvent evt

  beforeEach ->
    makeKeyboard()

  it 'can be created', ->
    expect(keyboard).to.exist

  it 'has a target element and down object', ->
    expect(keyboard.target).to.be.instanceof HTMLElement
    expect(keyboard.down).to.be.an.object
    expect(keyboard.down).to.be.empty

  describe 'target option', ->
    it 'can target a different element', ->
      makeKeyboard
        target: '#mocha'
      expect(keyboard.target).to.have.property 'id', 'mocha'

  describe 'keymap option', ->

  describe 'key events', ->
    it 'should track keydown', ->
      triggerKeyEvent 'keydown', 'q', 81
      expect(keyboard.down[81]).to.be.true
