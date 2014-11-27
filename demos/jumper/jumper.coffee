fn = require '../../src/fn.coffee'
Vector = require '../../src/utils/vector.coffee'
Rectangle = require '../../src/utils/rectangle.coffee'
Keeper = require '../../src/utils/score-keeper.coffee'

rocket = new Rocket

# track the score
rocket.score = new Keeper
scoreEl = document.querySelector '.scores .current'
highscoreEl = document.querySelector '.scores .best'
rocket.score.on 'score',     (points) -> scoreEl.textContent = points
rocket.score.on 'highscore', (points) -> highscoreEl.textContent = points

# the Canvas-2D data object
rocket.component 'canvas', require '../../src/utils/canvas-2d.coffee'
rocket.key canvas:
  width: 'auto'
  height: 'auto'
ctx = rocket.getData 'canvas'
ctx.center = Vector.new(ctx.width / 2, ctx.height / 2)

# the keyboard-state data object
rocket.component 'keyboard', require '../../src/utils/keyboard-state.coffee'
rocket.key keyboard:
  keymap:
    37: 'LEFT'
    39: 'RIGHT'
keyboard = rocket.getData 'keyboard'

# constants
GRAVITY = Vector.new(0, -0.4)
BARRIER_DISTANCE = ctx.height * 3 / 4
BARRIER_WIDTH = 200

# game components
rocket.component 'position', Vector.new()
rocket.component 'velocity', Vector.new()
rocket.component 'square',   {size: 30, color: 'cornflowerblue', angle: 0}
rocket.component 'barrier',  {color: 'cornflowerblue'}

rocket.player = rocket.key
  amazing: true
  square: {color: 'black', angle: Math.PI / 4, size: 20}
  position: Vector.new(ctx.center.x, ctx.center.y + ctx.height / 4)
  velocity: null

level = -1
lastGapLeft = ctx.center.x
addLevel = ->
  barrier = Rectangle.centered ctx.center.x + fn.random(-150, 150), 100 - BARRIER_DISTANCE * level++, BARRIER_WIDTH, 50
  squareX = (barrier.left + lastGapLeft + BARRIER_WIDTH) / 2
  rocket.key {evil: true, barrier}
  rocket.key
    evil: true
    square: null
    position:
      x: squareX + fn.random(-BARRIER_WIDTH / 2, BARRIER_WIDTH / 2)
      y: barrier.top - BARRIER_DISTANCE * 2 / 3
  rocket.key
    evil: true
    square: null
    position:
      x: squareX + fn.random(-BARRIER_WIDTH / 2, BARRIER_WIDTH / 2)
      y: barrier.top - BARRIER_DISTANCE / 3
  lastGapLeft = barrier.left
addLevel() for i in [1..3]

rocket.system 'level-barrier', ['barrier', 'evil'], (rocket, keys, barriers) ->
  pPos = rocket.dataFor rocket.player, 'position'
  pSq  = rocket.dataFor rocket.player, 'square'
  playerRect = Rectangle.new(pPos.x, pPos.y + ctx.width / 3, pSq.size, pSq.size)
  for key in keys
    barrier = barriers[key]
    continue if barrier.marked?
    if Rectangle.overlap playerRect, Rectangle.new(0, barrier.top, ctx.width, barrier.height)
      barrier.color = 'red'
      barrier.marked = false
    if Rectangle.overlap playerRect, barrier
      barrier.color = 'green'
      barrier.marked = true
      rocket.score.addPoints 1
    if barrier.marked is false then rocket.score.reset()

rocket.system 'square-smash', ['position', 'square', 'evil'], (rocket, keys, positions, squares) ->
  pPos = rocket.dataFor rocket.player, 'position'
  pSq  = rocket.dataFor rocket.player, 'square'
  playerRect = Rectangle.new(pPos.x, pPos.y + ctx.width / 3, pSq.size, pSq.size)
  for key in keys
    position = positions[key]
    square   = squares[key]
    continue if square.marked
    if Rectangle.overlap playerRect, Rectangle.new(position.x, position.y, square.size, square.size)
      square.color = 'red'
      square.marked = true
      rocket.score.reset()

# keyboard commands
MOVE = Vector.new(2, 12)
rocket.systemForEach 'input-brick', ['velocity', 'amazing'], (rocket, key, velocity) ->
  jump = 0
  if keyboard.isNewPress 'LEFT'
    jump = -MOVE.x
  if keyboard.isNewPress 'RIGHT'
    jump = MOVE.x
  if jump
    velocity.x = jump
    velocity.y = MOVE.y

# apply gravity
rocket.systemForEach 'gravity', ['velocity'], (rocket, key, vel) ->
  Vector.add vel, GRAVITY

# move each ball
rocket.systemForEach 'move', ['position', 'velocity'], (rocket, key, pos, vel) ->
  pos.x += vel.x
  pos.y -= vel.y
  ctx.center.y = Math.min(ctx.center.y, pos.y)

# move barriers and evil squares ahead once you pass them so they'll get reused
rocket.systemForEach 'destroy-barrier', ['barrier', 'evil'], (rocket, key, barrier) ->
  if barrier.top - BARRIER_DISTANCE * 2 > ctx.center.y
    rocket.destroyKey key
    addLevel()
rocket.systemForEach 'destroy-square', ['position', 'evil'], (rocket, key, pos) ->
  if pos.y - BARRIER_DISTANCE * 2 > ctx.center.y
    rocket.destroyKey key

# clear the canvas each frame
rocket.system 'clear-canvas', [], (rocket) ->
  ctx.g2d.clearRect 0, 0, ctx.width, ctx.height

# draw each square
rocket.systemForEach 'draw-square', ['position', 'square'], (rocket, key, pos, square) ->
  isAmazing = rocket.dataFor(key, 'amazing')
  {g2d, center, width} = ctx
  g2d.save()
  g2d.beginPath()
  g2d.translate pos.x, pos.y - center.y + if isAmazing then width / 3 else 0
  g2d.rotate(square.angle)
  g2d.fillStyle = square.color
  g2d.rect 0, 0, square.size, square.size
  g2d.closePath()
  g2d.fill()
  g2d.restore()

rocket.systemForEach 'draw-barrier', ['barrier'], (rocket, key, barrier) ->
  {g2d, width, center} = ctx
  g2d.save()
  g2d.beginPath()
  g2d.translate 0, barrier.top - center.y
  g2d.fillStyle = barrier.color
  g2d.rect 0, 0, barrier.left, barrier.height
  g2d.rect barrier.left + barrier.width, 0, width - barrier.width, barrier.height
  g2d.fill()
  g2d.closePath()
  g2d.restore()

# render loop
start = (time) ->
  rocket.tick(time)
  window.requestAnimationFrame start

document.addEventListener 'DOMContentLoaded', -> start()
