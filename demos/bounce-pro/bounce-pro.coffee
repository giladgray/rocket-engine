fn = require '../../src/fn.coffee'
Vector = require '../../src/utils/vector.coffee'

# track number of balls on the screen
numBalls = 0
countElem = document.querySelector '.count'
updateCount = (delta) ->
  if delta then numBalls += delta
  else numBalls = 0
  countElem.textContent = numBalls

rocket = new Rocket

# the Canvas-2D data object
rocket.component 'canvas', require '../../src/utils/canvas-2d.coffee'
rocket.key canvas:
  width: 'auto'
  height: 'auto'
canvas = rocket.getData 'canvas'

# the keyboard-state data object
rocket.component 'keyboard', require '../../src/utils/keyboard-state.coffee'
rocket.key keyboard:
  keymap:
    13: 'ADD'
    32: 'DESTROY'

# keyboard commands
rocket.systemForEach 'input-balls', ['keyboard'], (rocket, key, keyboard) ->
  if keyboard.isNewPress 'DESTROY'
    rocket.destroyKeys rocket.filterKeys('ball')
    updateCount(0)
  if keyboard.isNewPress 'ADD'
    randomBall()

# ball components
rocket.component 'position', {x: 0, y: 0}
rocket.component 'velocity', {x: 0, y: 0}
rocket.component 'circle',   {radius: 30, color: 'red'}

# cycle through colors
colors = ['seagreen', 'navy', 'indigo', 'firebrick', 'goldenrod']
curColor = 0
nextColor = ->
  color = colors[curColor++]
  curColor %= colors.length
  return color

# make a ball with random attributes
randomBall = ->
  updateCount(1)
  {width, height} = canvas
  radius = fn.random(20, 100)
  rocket.key {
    ball: true
    position :
      x: fn.random(radius, width - radius)
      y: fn.random(radius, height / 2 - radius)
    velocity : {x: fn.random(-8, 8), y: 0}
    circle   : {radius, color: nextColor()}
  }

# start with 5 of them
randomBall() for i in [0...5]

### NOW IT'S IDENTICAL TO BOUNCE! DEMO ###

# apply gravity to every thing with a velocity
GRAVITY = Vector.new(0, 0.5)
rocket.systemForEach 'gravity', ['velocity'], (rocket, key, vel) ->
  Vector.add vel, GRAVITY

# move each ball
rocket.systemForEach 'move', ['position', 'velocity'], (rocket, key, pos, vel) ->
  Vector.add pos, vel

# clear the canvas each frame
rocket.system 'clear-canvas', [], (rocket) ->
  {g2d, width, height} = canvas
  g2d.clearRect 0, 0, width, height

# draw each balls
rocket.systemForEach 'draw-ball', ['position', 'circle'], (rocket, key, pos, circle) ->
  {g2d} = canvas
  g2d.beginPath()
  g2d.fillStyle = circle.color
  g2d.arc pos.x, pos.y, circle.radius, 0, Math.PI * 2
  g2d.closePath()
  g2d.fill()

# bounce each ball when they reach the edge of the canvas
rocket.systemForEach 'bounce', ['position', 'velocity', 'circle'], (pkt, key, pos, vel, {radius}) ->
  {width, height} = canvas
  if pos.x < radius or pos.x > width - radius
    vel.x *= -1
    pos.x += vel.x
  if pos.y < radius or pos.y > height - radius
    vel.y *= -1
    pos.y += vel.y

# render loop
start = (time) ->
  rocket.tick(time)
  window.requestAnimationFrame start

document.addEventListener 'DOMContentLoaded', -> start()
