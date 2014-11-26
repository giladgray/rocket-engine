# Rocket Engine [![Build Status](https://travis-ci.org/giladgray/rocket-engine.svg?branch=master)](https://travis-ci.org/giladgray/rocket-engine)

> A little game engine that'll take you over the moon.

## Development
1. `npm install`
2. `gulp watch` to lint and test :coffee:

## Usage
```coffeescript
Rocket = require 'rocket-engine'

rocket = new Rocket

# 1. define components as functions that assign values...
rocket.component 'position', (cmp, options) ->
  cmp = {x: options.x ? 0, y: options.y ? 0}
# ...or as default value objects
rocket.component 'velocity', {x: 0, y: 0}

# 2. define systems that operate on keys with specific components
rocket.systemForEach 'move',
  # required components for a key
  ['position', 'velocity'],
  # function to call for each key that has all components
  (rocket, key, position, velocity) ->
    position.x += velocity.x
    position.y += velocity.y

# 3. add keys that contain components
rocket.key {
  spaceship : true # a label, for filtering
  velocity  : null # use default component values
  position  : {x: WIDTH / 2, y: HEIGHT / 2}
}
```

## Advanced Systems Design
### Data Components
```coffeescript
# singleton data can be stored as a key with a single component
rocket.component 'config', require './config'
rocket.key 'config', {config: null}
# and treated as data rather than a standard key
config = rocket.getData 'config'
```

### `rocket.systemForEach`
```coffeescript
# a system that operates on multiple keys can use systemForEach
# to reduce boilerplate. turn this:
rocket.system 'move', ['position', 'velocity'],
  (rocket, keys, position, velocity) ->
    for key in keys
      Vector.add position[key], velocity[key]
# into this:
rocket.systemForEach 'move', ['position', 'velocity'],
  (rocket, key, pos, vel) -> Vector.add pos, vel
```

### Custom Systems
```coffeescript
# rocket.system accepts instances of System too. Feel free to abuse the system...
Rectangle  = require 'rocket-engine/src/utils/rectangle.coffee'
PairSystem = require 'rocket-engine/src/utils/pair-system.coffee'
rocket.system PairSystem.forEach 'square-on-square-action',
  ['square', 'position'], ['square', 'position'],
  (rocket, [keyA, squareA, positionA], [keyB, squareB, positionB]) ->
    continue if keyA is keyB
    rectA = Rectangle.new(positionA.x, positionA.y, squareA.size)
    rectB = Rectangle.new(positionB.x, positionB.y, squareB.size)
    rocket.destroyKeys(keyA, keyB) if Rectangle.overlap(rectA, rectB)
```

## Meet the Utilities
Rocket comes with a number of utilities components and libraries, which can be
found in [`src/utils/`](https://github.com/giladgray/rocket-engine/tree/master/src/utils).
All you need to do is require them, register the component with a name you'll
remember, and start jamming.

### KeyboardState
A component that stores the current keyboard state and supports a keymap of named keys.
```coffeescript
# create a new keyboard using the "Data Component" pattern above
rocket.component 'keyboard', require 'rocket-engine/src/utils/keyboard-state.coffee'
rocket.key
  keyboard:
    # omg custom key names!!
    keymap:
      W: 'JUMP'
      S: 'SLIDE'
      A: 'ROLL_LEFT'
      D: 'ROLL_RIGHT'
# sometimes it's easiest to just create a global reference...
keyboard = rocket.getData 'keyboard'
rocket.system 'keyboarding', [], (rocket) ->
  console.log keyboard.down.JUMP
```

### MouseState
A component that stores current mouse cursor location and button state.
```coffeescript
# create a new mouse using the "Data Component" pattern above
rocket.component 'mouse', require 'rocket-engine/src/utils/mouse-state.coffee'
rocket.key {mouse: null}
mouse = rocket.getData 'mouse'
rocket.system 'mouse-master', [], (rocket) ->
  if mouse.buttons.left then alert('you\'re the mouse master!')
```

### Canvas2D
A component that stores a CanvasRenderingContext2D and various useful 2D canvas
drawing properties.
```coffeescript
# create a new mouse using the "Data Component" pattern above
rocket.component 'canvas', require 'rocket-engine/src/utils/canvas-2d.coffee'
rocket.key canvas:
  width: 'auto'
  height: 'auto'
canvas = rocket.getData 'canvas'
rocket.system 'clear-canvas', [], (rocket) ->
  canvas.g2d.clearRect 0, 0, canvas.width, canvas.height
```

### PairSystem
A subclass of System that takes **two** dependency arrays and provides its
action function with **two** sets of keys and components. `PairSystem.forEach`
accepts a function that is invoked for **each pair** of keys. It's like having
two systems in one!

See `PairSystem` in action in the [Custom Systems](#custom-systems) example above.

### Vector and Rectangle
Static classes for manipulating 2D vectors of the form `{x, y}` and Rectangles
like `{x, y, width, height}`. Vectors and Rectangles are just plain objects so
they're fast and light. All operations happen through static functions that may
modify their arguments, like `Vector.add(v1, v2)`.

See `Rectangle` in action in the [Custom Systems](#custom-systems) example above.

```coffeescript
Vector = require 'rocket-engine/src/utils/vector.coffee'
# define 2D components trivially
rocket.component 'position', Vector.new()
rocket.component 'velocity', Vector.new()
rocket.systemForEach 'move', ['position', 'velocity'],
  (rocket, key, pos, vel) -> Vector.add pos, vel
```

### ScoreKeeper
Keep score in your game and automatically update the high score. Persist your high
scores across multiple sessions with built-in `localStorage` support. Emits events
when points are added or a new highscore is set.
```coffeescript
ScoreKeeper = require 'rocket-engine/src/utils/score-keeper.coffee'
keeper = new ScoreKeeper
keeper.enableSaving 'demo-high-score' # loads a high score of 8 from localStorage
keeper.on 'score', (total, points) -> alert "#{total} (#{points})"
keeper.on 'highscore', (record) -> alert "crushed it! #{record}"
keeper.addScore(4) # -> "4 (4)"
keeper.addScore(7) # -> "11 (7)", "crushed it! 11"
keeper.reset()     # -> "0 (-11)"
keeper.addScore(6) # -> "6 (6)"
```

## Thanks
My deepest thanks go to Drew Petersen (@kirbysayshi) for his presentation
[Developing Games Using Data not Trees](http://2014.jsconf.eu/speakers/#/speakers/drew-petersen-developing-games-using-data-not-trees)
at JSConf EU 2014, and for his code at [kirbysayshi/pocket-ces](https://github.com/kirbysayshi/pocket-ces).

## License
MIT
