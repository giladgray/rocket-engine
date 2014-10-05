###*
 * A component that stores keyboard state and supports a map of keys to action names. Keyboard
 * state is stored in the `down` field. When a key is pressed, its keyCode is set to true and
 * its action name, if present in the `keymap, is set to the time at which it was pressed.
 *
 * To check if a given key is pressed, either look up its keyCode (`event.which`) or its name
 * in the keymap via `cmp.down[keyCode]` or `cmp.down[keyName] isnt 0`.
 *
 * The `keymap` is a map of keyCodes or key names to string names, allowing for dynamic
 * and descriptive bindings, such as `{32: 'SHOOT'}` to name the spacebar 'SHOOT'. When
 * the spacebar is pressed, `cmp.down.SHOOT` will contain the time at which it was pressed. The
 * keymap also supports single-character key names such as `{W: 'UP', S: 'DOWN'}` and a number of
 * whole-word key names, which will be converted to their corresponding keyCodes.
 *
 * Supported whole-word key names (case sensitive): Alt, Bksp, Backspace, Caps, CapsLock, Ctrl,
 * Enter, Esc, Escape, Shift, Space, Tab, Up, Left, Down, Right.
 *
 * The component provides a function `isNewPress(keyName, recency=10)` that returns true if the
 * `keyName` was pressed at least `recency` milliseconds ago. Only the first call to `isNewPress`
 * after a key is pressed will return true because the keypress is no longer new. You can still
 * check that the key is pressed `if cmp.down[keyName] isnt 0`.
 *
 * @example
 *   # register the keyboard-state component
 * 	 pocket.component 'keyboard-state', require('pocket/utils/keyboard-state.coffee')
 * 	 # define a key with keymap for your game
 * 	 pocket.key {
 * 	 	'keyboard-state':
 * 	 		keymap:
 * 	 		  27: 'MENU'  # esc
 * 	 		  32: 'SHOOT' # space
 * 	 		  37: 'LEFT'  # left arrow
 * 	 		  39: 'RIGHT' # right arrow
 * 	 }
 *   # call pocket.getData in a system to use the keyboard
 * 	 pocket.systemForEach 'name', ['player'], (pocket, key, player) ->
 * 	   keyboard = pocket.getData 'keyboard-state'
 * 	   player.shoot()  if keyboard.isNewPress 'SHOOT'
 * 	   player.move(-1) if keyboard.down.LEFT
 * 	   player.move(1)  if keyboard.down.RIGHT
 *
 * @param  {Object} cmp    component entry
 * @option {String} target CSS selector of target element for keypress events,
 *         								 or omit to bind to `document`
 * @option {Object} keymap map of keyCodes to string names
###
KeyboardState = (cmp, {target, keymap}) ->
  keymap = KeyboardState.convertKeymap(keymap)
  cmp.target = if typeof target is 'string' then document.querySelector(target) else document.body
  cmp.down = {}
  # returns true if the named key was pressed in the last X milliseconds
  cmp.isNewPress = (keyName, recency = 10) ->
    downTime = cmp.down[keyName]
    delta = Date.now() - downTime
    if downTime > 0 and delta > recency
      cmp.down[keyName] = -1
      return true
    return false

  cmp.target.addEventListener 'keydown', (e) ->
    keyName = keymap[e.which]
    cmp.down[e.which] = true
    if keyName and cmp.down[keyName] is 0
      # record time it was pressed
      cmp.down[keyName] = Date.now()

  cmp.target.addEventListener 'keyup', (e) ->
    keyName = keymap[e.which]
    cmp.down[e.which] = false
    if keyName
      cmp.down[keyName] = 0

# mapping of friendly key names to keyCodes
KeyboardState.SpecialKeys =
  Alt    : 18
  Bksp   : 8
  Caps   : 20
  Ctrl   : 17
  Enter  : 13
  Esc    : 27
  Escape : 27
  Shift  : 16
  Space  : 32
  Tab    : 9
  Backspace : 8
  CapsLock  : 20
  Up    : 38
  Left  : 37
  Down  : 40
  Right : 39

# convert a keymap with a mix of keyCodes and keyNames
KeyboardState.convertKeymap = (keymap = {}) ->
  for key, name of keymap when not +key
    delete keymap[key]
    if key.length is 1
      keymap[key.charCodeAt(0)] = name
    else if code = KeyboardState.SpecialKeys[key]
      keymap[code] = name
    else
      throw new Error("KeyboardState: unknown key name '#{key}'")
  return keymap

module.exports = KeyboardState
