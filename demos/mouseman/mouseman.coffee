fn        = require '../../src/fn.coffee'
Vector    = require '../../src/utils/vector.coffee'
Rectangle = require '../../src/utils/rectangle.coffee'
Keeper    = require '../../src/utils/score-keeper.coffee'

rocket = new Rocket

# the Canvas-2D data object
rocket.component 'canvas', require '../../src/utils/canvas-2d.coffee'
rocket.key canvas:
  width: 'auto'
  height: 'auto'
canvas = rocket.getData 'canvas'

# the mouse-state data object
rocket.component 'mouse', require '../../src/utils/mouse-state.coffee'
rocket.key mouse: null
mouse = rocket.getData 'mouse'

# track the score
rocket.score = new Keeper
scoreEl = document.querySelector '.scores .current'
highscoreEl = document.querySelector '.scores .best'
rocket.score.on 'score',     (points) -> scoreEl.textContent = points
rocket.score.on 'highscore', (points) -> highscoreEl.textContent = points

# game components
rocket.component 'position', {x: 0, y: 0}
rocket.component 'speed', {speed: 0}
rocket.component 'circle',   {radius: 30, color: 'cornflowerblue'}

MAX_FUEL  = 5000
mouseFuel = 0

newBall = ->
  mouseFuel = MAX_FUEL
  rocket.key
    position:
      x: fn.random canvas.width
      y: fn.random canvas.height
    speed: null
    circle: null
newBall()

rocket.systemForEach 'move-ball', ['position', 'speed'], (rocket, key, pos, spd) ->
  return unless mouse.inWindow
  angle = Math.atan2 mouse.cursor.y - pos.y, mouse.cursor.x - pos.x
  vel = Vector.fromPolar spd.speed, angle
  if mouse.buttons.left and mouseFuel > 0
    Vector.scale vel, -1 / 4
    mouseFuel -= rocket.delta
  else
    spd.speed += 1 / 20
    mouseFuel += rocket.delta / 3
    mouseFuel = Math.min(mouseFuel, MAX_FUEL)
  Vector.add pos, vel

rocket.systemForEach 'respawn-ball', ['position', 'circle'], (rocket, key, pos, {radius}) ->
  if Vector.dist(Vector.sub mouse.cursor, pos, true) < radius
    rocket.destroyKey key
    rocket.score.reset()
    newBall()

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

# draw each balls
rocket.system 'draw-fuel', [], (rocket) ->
  {g2d, width, height} = canvas
  g2d.beginPath()
  g2d.fillStyle = 'orange'
  g2d.fillRect 0, height - 30, mouseFuel / MAX_FUEL * width, 30
  g2d.closePath()

rocket.system 'update-score', [], (rocket) ->
  return unless mouse.inWindow
  rocket.score.addPoints Math.floor(rocket.delta or 0)

# render loop
start = (time) ->
  rocket.tick(time)
  window.requestAnimationFrame start

document.addEventListener 'DOMContentLoaded', -> start()
