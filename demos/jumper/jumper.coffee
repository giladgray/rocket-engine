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

pocket = new Pocket

# context-2d component for storing CanvasRenderingContext2D and other canvas info
pocket.component 'context-2d', (cmp, {canvas}) ->
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
pocket.key {'context-2d': null}

# maintain keyboard state. this guy mutates himself, it's prety badass
pocket.component 'keyboard-state', (cmp, {target, keymap}) ->
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
pocket.key
  'input': null
  'keyboard-state':
    keymap:
      37: 'LEFT'
      39: 'RIGHT'


# constants
ctx = pocket.getData 'context-2d'
ctx.center = {x: ctx.width / 2, y: ctx.height / 2}

GRAVITY = 0.4
BARRIER_DISTANCE = ctx.height * 3 / 4
BARRIER_WIDTH = 200

# game components
pocket.component 'position', {x: 0, y: 0}
pocket.component 'velocity', {x: 0, y: 0}
pocket.component 'square',   {size: 30, color: 'cornflowerblue', angle: 0}
pocket.component 'barrier',  {height: 50, gapWidth: BARRIER_WIDTH, x: 0, y: 0, color: 'cornflowerblue'}

pocket.player = pocket.key
  amazing: true
  square: {color: 'black', angle: Math.PI / 4, size: 20}
  position: {x: ctx.center.x, y: ctx.center.y + ctx.height / 4}
  velocity: null

level = -1
lastBarrierX = ctx.center.x
addLevel = ->
  barrier = {x: ctx.center.x + random(-150, 150), y: 100 - BARRIER_DISTANCE * level++}
  squareX = (barrier.x + lastBarrierX) / 2 + BARRIER_WIDTH / 2
  pocket.key {evil: true, barrier}
  pocket.key
    evil: true
    square: null
    position:
      x: squareX + random(-BARRIER_WIDTH / 2, BARRIER_WIDTH / 2)
      y: barrier.y - BARRIER_DISTANCE * 2 / 3
  pocket.key
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

pocket.system 'level-barrier', ['barrier', 'evil'], (pocket, keys, barriers) ->
  pPos = pocket.dataFor pocket.player, 'position'
  pSq  = pocket.dataFor pocket.player, 'square'
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

pocket.system 'square-smash', ['position', 'square', 'evil'], (pocket, keys, positions, squares) ->
  pPos = pocket.dataFor pocket.player, 'position'
  pSq  = pocket.dataFor pocket.player, 'square'
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
pocket.systemForEach 'input-brick', ['velocity', 'amazing'], (pocket, key, velocity) ->
  keyboard = pocket.getData 'keyboard-state'
  jump = 0
  if keyboard.isNewPress 'LEFT'
    jump = -MOVE.x
  if keyboard.isNewPress 'RIGHT'
    jump = MOVE.x
  if jump
    velocity.x = jump
    velocity.y = MOVE.y

# apply gravity
pocket.systemForEach 'gravity', ['velocity'], (pocket, key, vel) ->
  vel.y -= GRAVITY

# move each ball
pocket.systemForEach 'move', ['position', 'velocity'], (pocket, key, pos, vel) ->
  pos.x += vel.x
  pos.y -= vel.y
  ctx.center.y = Math.min(ctx.center.y, pos.y)

# move barriers and evil squares ahead once you pass them so they'll get reused
pocket.systemForEach 'destroy-barrier', ['barrier', 'evil'], (pocket, key, barrier) ->
  if barrier.y - BARRIER_DISTANCE * 2 > ctx.center.y
    pocket.destroyKey key
    addLevel()
pocket.systemForEach 'destroy-square', ['position', 'evil'], (pocket, key, pos) ->
  if pos.y - BARRIER_DISTANCE * 2 > ctx.center.y
    pocket.destroyKey key

# clear the canvas each frame
pocket.system 'clear-canvas', [], (pocket) ->
  ctx.g2d.clearRect 0, 0, ctx.width, ctx.height

# draw each square
pocket.systemForEach 'draw-square', ['position', 'square'], (pocket, key, pos, square) ->
  isAmazing = pocket.dataFor(key, 'amazing')
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

pocket.systemForEach 'draw-barrier', ['barrier'], (pocket, key, barrier) ->
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
  pocket.tick(time)
  window.requestAnimationFrame start

document.addEventListener 'DOMContentLoaded', -> start()
