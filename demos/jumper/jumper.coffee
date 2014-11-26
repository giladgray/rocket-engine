random = (min, max) ->
  unless max?
    max = min
    min = 0
  return Math.floor(Math.random() * (max - min)) + min

rectangle = (rect1...) ->
  overlaps: (rect2...) ->
    xOverlap = yOverlap = true
    if rect1[0] > rect2[0] + rect2[2] or rect1[0] + rect1[2] < rect2[0]
      xOverlap = false
    if rect1[1] > rect2[1] + rect2[3] or rect1[1] + rect1[3] < rect2[1]
      yOverlap = false
    return xOverlap and yOverlap

rocket = new Rocket

# context-2d component for storing CanvasRenderingContext2D and other canvas info
rocket.component 'context-2d', (cmp, {canvas}) ->
  cmp.canvas = document.querySelector canvas or '#canvas'
  cmp.g2d = cmp.canvas.getContext('2d')
  cmp.center = {x: 0, y: 0}

  # ensure canvas is as large as possible
  window.addEventListener 'resize', resize = ->
    cmp.canvas.width = document.body.clientWidth
    cmp.canvas.height = document.body.clientHeight
    cmp.width = cmp.canvas.width
    cmp.height = cmp.canvas.height
  resize()

# the context-2d data object
rocket.key {'context-2d': null}

# maintain keyboard state. this guy mutates himself, it's prety badass
rocket.component 'keyboard-state', (cmp, {target, keymap}) ->
  cmp.target = target or document
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

# the keyboard-state data object
rocket.key
  'input': null
  'keyboard-state':
    keymap:
      37: 'LEFT'
      39: 'RIGHT'


# constants
ctx = rocket.getData 'context-2d'
ctx.center = {x: ctx.width / 2, y: ctx.height / 2}

GRAVITY = 0.4
BARRIER_DISTANCE = ctx.height * 3 / 4
BARRIER_WIDTH = 200

# game components
rocket.component 'position', {x: 0, y: 0}
rocket.component 'velocity', {x: 0, y: 0}
rocket.component 'square',   {size: 30, color: 'cornflowerblue', angle: 0}
rocket.component 'barrier',  {height: 50, gapWidth: BARRIER_WIDTH, x: 0, y: 0, color: 'cornflowerblue'}

rocket.player = rocket.key
  amazing: true
  square: {color: 'black', angle: Math.PI / 4, size: 20}
  position: {x: ctx.center.x, y: ctx.center.y + ctx.height / 4}
  velocity: null

level = -1
lastBarrierX = ctx.center.x
addLevel = ->
  barrier = {x: ctx.center.x + random(-150, 150), y: 100 - BARRIER_DISTANCE * level++}
  squareX = (barrier.x + lastBarrierX) / 2 + BARRIER_WIDTH / 2
  rocket.key {evil: true, barrier}
  rocket.key
    evil: true
    square: null
    position:
      x: squareX + random(-BARRIER_WIDTH / 2, BARRIER_WIDTH / 2)
      y: barrier.y - BARRIER_DISTANCE * 2 / 3
  rocket.key
    evil: true
    square: null
    position:
      x: squareX + random(-BARRIER_WIDTH / 2, BARRIER_WIDTH / 2)
      y: barrier.y - BARRIER_DISTANCE / 3
  lastBarrierX = barrier.x
addLevel() for i in [1..3]

score = 0
bestScore = 0
scoreEl = document.querySelector '.scores .current'
highscoreEl = document.querySelector '.scores .best'
scoreOne = ->
  scoreEl.textContent = ++score
scoreZero = ->
  if score > bestScore
    highscoreEl.textContent = bestScore = score
  scoreEl.textContent = score = 0

rocket.system 'level-barrier', ['barrier', 'evil'], (rocket, keys, barriers) ->
  pPos = rocket.dataFor rocket.player, 'position'
  pSq  = rocket.dataFor rocket.player, 'square'
  playerRect = rectangle(pPos.x, pPos.y + ctx.width / 3, pSq.size, pSq.size)
  for key in keys
    barrier = barriers[key]
    continue if barrier.marked?
    if playerRect.overlaps(0, barrier.y, ctx.width, barrier.height)
      barrier.color = 'red'
      barrier.marked = false
    if playerRect.overlaps(barrier.x, barrier.y, barrier.gapWidth, barrier.height)
      barrier.color = 'green'
      barrier.marked = true
      scoreOne()
    if barrier.marked is false then scoreZero()

rocket.system 'square-smash', ['position', 'square', 'evil'], (rocket, keys, positions, squares) ->
  pPos = rocket.dataFor rocket.player, 'position'
  pSq  = rocket.dataFor rocket.player, 'square'
  playerRect = rectangle(pPos.x, pPos.y + ctx.width / 3, pSq.size, pSq.size)
  for key in keys
    position = positions[key]
    square   = squares[key]
    continue if square.marked
    if playerRect.overlaps position.x, position.y, square.size, square.size
      square.color = 'red'
      square.marked = true
      scoreZero()

# keyboard commands
MOVE = {x: 2, y: 12}
rocket.systemForEach 'input-brick', ['velocity', 'amazing'], (rocket, key, velocity) ->
  keyboard = rocket.getData 'keyboard-state'
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
  vel.y -= GRAVITY

# move each ball
rocket.systemForEach 'move', ['position', 'velocity'], (rocket, key, pos, vel) ->
  pos.x += vel.x
  pos.y -= vel.y
  ctx.center.y = Math.min(ctx.center.y, pos.y)

# move barriers and evil squares ahead once you pass them so they'll get reused
rocket.systemForEach 'destroy-barrier', ['barrier', 'evil'], (rocket, key, barrier) ->
  if barrier.y - BARRIER_DISTANCE * 2 > ctx.center.y
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
  g2d.translate 0, barrier.y - center.y
  g2d.fillStyle = barrier.color
  g2d.rect 0, 0, barrier.x, barrier.height
  g2d.rect barrier.x + barrier.gapWidth, 0, width - barrier.gapWidth, barrier.height
  g2d.fill()
  g2d.closePath()
  g2d.restore()

# render loop
start = (time) ->
  rocket.tick(time)
  window.requestAnimationFrame start

document.addEventListener 'DOMContentLoaded', -> start()
