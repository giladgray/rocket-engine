random = (min, max) ->
  unless max?
    max = min
    min = 0
  return Math.floor(Math.random() * (max - min)) + min

distance = (a, b) ->
  dx = a.x - b.x
  dy = a.y - b.y
  Math.sqrt(dx * dx + dy * dy)

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
pocket.key
  'context-2d':
    width: 'auto'
    height: 'auto'
canvas = pocket.getData 'context-2d'

pocket.component 'mouse-state', (cmp, {target, origin}) ->
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

pocket.key
  'mouse-state': null
mouse = pocket.getData 'mouse-state'

# game components
pocket.component 'position', {x: 0, y: 0}
pocket.component 'velocity', {x: 0, y: 0}
pocket.component 'circle',   {radius: 30, color: 'cornflowerblue'}

MAX_FUEL  = 5000
mouseFuel = 0

newBall = ->
  mouseFuel = MAX_FUEL
  pocket.key
    position:
      x: random canvas.width
      y: random canvas.height
    velocity:
      speed: 0
    circle: null
newBall()

pocket.systemForEach 'move-ball', ['position', 'velocity'], (pocket, key, pos, vel) ->
  return unless mouse.inWindow
  angle = Math.atan2 mouse.cursor.y - pos.y, mouse.cursor.x - pos.x
  vel.x = vel.speed * Math.cos(angle)
  vel.y = vel.speed * Math.sin(angle)
  if mouse.buttons.left and mouseFuel > 0 
    vel.x *= -1 / 4
    vel.y *= -1 / 4
    mouseFuel -= pocket.delta
  else
    vel.speed += 1 / 20
    mouseFuel += pocket.delta / 3
    mouseFuel = Math.min(mouseFuel, MAX_FUEL)
  pos.x += vel.x
  pos.y += vel.y

pocket.systemForEach 'respawn-ball', ['position', 'circle'], (pocket, key, pos, {radius}) ->
  if distance(mouse.cursor, pos) < radius
    pocket.destroyKey key
    scoreZero()
    newBall()

# clear the canvas each frame
pocket.system 'clear-canvas', [], (pocket) ->
  {g2d, width, height} = canvas
  g2d.clearRect 0, 0, width, height

# draw each balls
pocket.systemForEach 'draw-ball', ['position', 'circle'], (pocket, key, pos, circle) ->
  {g2d} = canvas
  g2d.beginPath()
  g2d.fillStyle = circle.color
  g2d.arc pos.x, pos.y, circle.radius, 0, Math.PI * 2
  g2d.closePath()
  g2d.fill()

# draw each balls
pocket.system 'draw-fuel', [], (pocket) ->
  {g2d, width, height} = canvas
  g2d.beginPath()
  g2d.fillStyle = 'orange'
  g2d.fillRect 0, height - 30, mouseFuel / MAX_FUEL * width, 30
  g2d.closePath()

score = 0
bestScore = 0
scoreEl = document.querySelector '.scores .current'
highscoreEl = document.querySelector '.scores .best'
scoreOne = (amt = 1)->
  scoreEl.textContent = score += amt
scoreZero = ->
  if score > bestScore
    highscoreEl.textContent = bestScore = score
  scoreEl.textContent = score = 0

pocket.system 'update-score', [], (pocket) ->
  return unless mouse.inWindow
  scoreOne Math.floor(pocket.delta or 0)

# render loop
start = (time) ->
  pocket.tick(time)
  window.requestAnimationFrame start

document.addEventListener 'DOMContentLoaded', -> start()
