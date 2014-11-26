rocket = new Rocket

# context-2d component for storing CanvasRenderingContext2D and other canvas info
rocket.component 'context-2d', (cmp, options) ->
  cmp.canvas = document.querySelector options.canvas or '#canvas'
  cmp.g2d = cmp.canvas.getContext('2d')
  cmp.center = {x: 0, y: 0}

  # ensure canvas is as large as possible
  window.addEventListener 'resize', resize = ->
    cmp.canvas.width = document.body.clientWidth
    cmp.canvas.height = document.body.clientHeight
    cmp.width = cmp.canvas.width
    cmp.height = cmp.canvas.height
    cmp.center.x = cmp.canvas.width / 2
    cmp.center.y = cmp.canvas.height / 2
  resize()

# the context-2d data object
rocket.key {'context-2d': null}

# ball components
rocket.component 'position', {x: 0, y: 0}
rocket.component 'velocity', {x: 0, y: 0}
rocket.component 'circle',   {radius: 30, color: 'red'}

# the ball!
rocket.key
  position : {x: 30, y: 50}
  velocity : {x: 5, y: 0}
  circle   : null

# apply gravity to every thing with a velocity
GRAVITY = 1.0
rocket.systemForEach 'gravity', ['velocity'], (rocket, key, vel) ->
  vel.y += GRAVITY

# move each ball
rocket.systemForEach 'move', ['position', 'velocity'], (rocket, key, pos, vel) ->
  pos.x += vel.x
  pos.y += vel.y

# clear the canvas each frame
rocket.system 'clear-canvas', [], (rocket) ->
  {g2d, width, height} = rocket.getData 'context-2d'
  g2d.clearRect 0, 0, width, height

# draw each balls
rocket.systemForEach 'draw-ball', ['position', 'circle'], (rocket, key, pos, circle) ->
  {g2d} = rocket.getData 'context-2d'
  g2d.beginPath()
  g2d.fillStyle = circle.color
  g2d.arc pos.x, pos.y, circle.radius, 0, Math.PI * 2
  g2d.closePath()
  g2d.fill()

# bounce each ball when they reach the edge of the canvas
rocket.systemForEach 'bounce', ['position', 'velocity', 'circle'], (pkt, key, pos, vel, {radius}) ->
  {width, height} = pkt.getData 'context-2d'
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
