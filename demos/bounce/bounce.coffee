Vector = require '../../src/utils/vector.coffee'

rocket = new Rocket

rocket.component 'canvas', require '../../src/utils/canvas-2d.coffee'
rocket.key canvas:
  width: 'auto'
  height: 'auto'
canvas = rocket.getData 'canvas'

# ball components
rocket.component 'position', Vector.new()
rocket.component 'velocity', Vector.new()
rocket.component 'circle',   {radius: 30, color: 'red'}

# the ball!
rocket.key
  position : Vector.new(30, 50)
  velocity : Vector.new(5, 0)
  circle   : null

# apply gravity to every thing with a velocity
GRAVITY = Vector.new(0, 1.0)
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
