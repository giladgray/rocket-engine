###
A component that stores mouse cursor and buttons state. Also sets a flag if the mouse leaves
the window.

Button state is stored as boolean values in `cmp.buttons.{left|middle|right}`. A `true` value
means the button is currently pressed.

Mouse cursor is stored as a {Vector} in `cmp.cursor` with `x` and `y` properties. If an `origin`
Vector option is provided then the mouse cursor will be stored relative to that point.

The boolean flag `cmp.isWindow` is true when the mouse cursor is inside the window and `false`
when it leaves. This can be used to implement a simple pause feature.

@param  {Object} cmp    component entry
@param {String} target CSS selector for element to bind listeners to (default: document.body)
@param {Vector} origin Vector that cursor will be stored relative to (default: `{x:0, y:0}`)
###
MouseState = (cmp, {target, origin}) ->
  # point to which mouse coordinates are relative
  origin ?= {}
  cmp.origin = {x: origin.x ? 0, y: origin.y ? 0}
  # remember the target
  cmp.target = if typeof target is 'string' then document.querySelector(target) else document.body
  # current button state, by name
  cmp.buttons =
    left   : false
    middle : false
    right  : false
  # current cursor position
  cmp.cursor =
    x: null
    y: null
  # whether mouse is currently in the window
  cmp.inWindow = true

  # and now the listeners...
  cmp.target.addEventListener 'mousemove', (e) ->
    # update mouse cursor relative to origin
    cmp.cursor.x = e.clientX - cmp.origin.x
    cmp.cursor.y = e.clientY - cmp.origin.x
  cmp.target.addEventListener 'mousedown', (e) ->
    # marked button as pressed if it caused this event
    cmp.buttons.left   = true if e.which is 1
    cmp.buttons.middle = true if e.which is 2
    cmp.buttons.right  = true if e.which is 3
  cmp.target.addEventListener 'mouseup', (e) ->
    # unmark pressed button if it caused this event
    cmp.buttons.left   = false if e.which is 1
    cmp.buttons.middle = false if e.which is 2
    cmp.buttons.right  = false if e.which is 3
  # update mouse in window state?
  cmp.target.addEventListener 'mouseenter', (e) -> cmp.inWindow = true
  cmp.target.addEventListener 'mouseleave', (e) -> cmp.inWindow = false

module.exports = MouseState
