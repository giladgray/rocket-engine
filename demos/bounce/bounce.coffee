console.log 'hello from coffee!'

pocket = new Pocket

# context-2d component for storing CanvasRenderingContext2D and other canvas info
pocket.component 'context-2d', (cmp, options) ->
  cmp.canvas = document.querySelector options.canvas or '#canvas'
  cmp.g2d = cmp.canvas.getContext('2d')
  cmp.center = {x: 0, y: 0}

  # ensure canvas is as large as possible
  window.addEventListener "resize", resize = ->
    cmp.canvas.width = document.body.clientWidth
    cmp.canvas.height = document.body.clientHeight
    cmp.width = cmp.canvas.width
    cmp.height = cmp.canvas.height
    cmp.center.x = cmp.canvas.width / 2
    cmp.center.y = cmp.canvas.height / 2
  resize()

# the context-2d data object
pocket.key {'context-2d': null}

pocket.component 'position', {x: 0, y: 0}
pocket.component 'velocity', {x: 0, y: 0}
pocket.component 'circle',   {radius: 30, color: 'red'}

# the ball!
pocket.key
  position : {x: 30, y: 50}
  velocity : {x: 5, y: 0}
  circle   : null

# apply gravity to every thing with a velocity
GRAVITY = 1.0
pocket.systemForEach 'gravity', ['velocity'], (pocket, key, vel) ->
  vel.y += GRAVITY

# move all balls
pocket.systemForEach 'move', ['position', 'velocity'], (pocket, key, pos, vel) ->
  pos.x += vel.x
  pos.y += vel.y

# clear the canvas each frame
pocket.system 'clear-canvas', [], (pocket) ->
  {g2d, width, height} = pocket.getData 'context-2d'
  g2d.clearRect 0, 0, width, height

# draw all the balls
pocket.systemForEach 'draw-ball', ['position', 'circle'], (pocket, key, pos, circle) ->
  {g2d} = pocket.getData 'context-2d'
  g2d.beginPath()
  g2d.fillStyle = circle.color
  g2d.arc pos.x, pos.y, circle.radius, 0, Math.PI * 2
  g2d.closePath()
  g2d.fill()

# bounce balls when they reach the edge of the canvas
pocket.systemForEach 'bounce', ['position', 'velocity', 'circle'], (pkt, key, pos, vel, {radius}) ->
  {width, height} = pkt.getData 'context-2d'
  if pos.x < radius or pos.x > width - radius
    vel.x *= -1
    pos.x += vel.x
  if pos.y < radius or pos.y > height - radius
    vel.y *= -1
    pos.y += vel.y

# render loop
start = ->
  pocket.tick()
  window.requestAnimationFrame start
start()
