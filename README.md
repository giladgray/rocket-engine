# Pocket [![Build Status](https://travis-ci.org/giladgray/pocket.svg?branch=master)](https://travis-ci.org/giladgray/pocket)

> A little game engine that fits in your pocket.

## Development
1. `npm install`
2. `gulp watch` to lint and test :coffee:

## Usage
```coffeescript
Pocket = require 'pocket'

pocket = new Pocket

# 1. define components as functions that assign values...
pocket.component 'position', (cmp, options) ->
  cmp = {x: options.x ? 0, y: options.y ? 0}
# ...or as default value objects
pocket.component 'velocity', {x: 0, y: 0}

# 2. define systems that operate on keys with specific components
pocket.systemForEach 'move', # friendly name
  # required components for a key
  ['position', 'velocity'],
  # function to call for each key that has all components
  (pocket, key, position, velocity) ->
    position.x += velocity.x
    position.y += velocity.y

# 3. add keys that contain components
pocket.key {
  spaceship : true # a label*
  velocity  : null # use default component values
  position  : {x: WIDTH / 2, y: HEIGHT / 2}
}

# * a label is simply a component without a definition,
# used to tag keys for easy discovery.
```

## Advanced Systems Design
### Data Components
```coffeescript
# singleton data can be stored as a key with a single component
pocket.component 'config', require './config'
pocket.key 'config', {config: null}
# and treated as data rather than a standard key
config = pocket.getData 'config'
```

### `pocket.systemForEach`
```coffeescript
# a system that operates on multiple keys can use systemForEach
# to reduce boilerplate. turn this:
pocket.system 'move', ['position', 'velocity'],
  (pocket, keys, position, velocity) ->
    for key in keys
      Vector.add position[key], velocity[key]
# into this:
pocket.systemForEach 'move', ['position', 'velocity'],
  (pocket, key, pos, vel) -> Vector.add pos, vel
```

### Custom Systems
```coffeescript
# pocket.system accepts instances of System too. Feel free to abuse the system...
Rectangle = require 'pocket/src/utils/rectangle.coffee'
PairSystem = require 'pocket/src/utils/pair-system.coffee'
pocket.system PairSystem.forEach 'square-on-square-action',
  ['square', 'position'], ['square', 'position'],
  (pocket, [keyA, squareA, positionA], [keyB, squareB, positionB]) ->
    continue if keyA is keyB
    rectA = Rectangle.new(positionA.x, positionA.y, squareA.size)
    rectB = Rectangle.new(positionB.x, positionB.y, squareB.size)
    pocket.destroyKeys(keyA, keyB) if Rectangle.overlap(rectA, rectB)
```

## Meet the Utilities
Pocket comes with a number of utilities components and libraries, which can be
found in [`src/utils/`](https://github.com/giladgray/pocket/tree/master/src/utils).
All you need to do is require them, register the component with a name you'll
remember, and start jamming.

### KeyboardState
A component that stores the current keyboard state and supports a keymap of named keys.
```coffeescript
# create a new keyboard using the "Data Component" pattern above
pocket.component 'keyboard', require 'pocket/src/utils/keyboard-state.coffee'
pocket.key
  keyboard:
    # omg custom key names!!
    keymap:
      W: 'JUMP'
      S: 'SLIDE'
      A: 'ROLL_LEFT'
      D: 'ROLL_RIGHT'
# sometimes it's easiest to just create a global reference...
keyboard = pocket.getData 'keyboard'
pocket.system 'keyboarding', [], (pocket) ->
  console.log keyboard.down.JUMP
```

### MouseState
A component that stores current mouse cursor location and button state.
```coffeescript
# create a new mouse using the "Data Component" pattern above
pocket.component 'mouse', require 'pocket/src/utils/mouse-state.coffee'
pocket.key {mouse: null}
mouse = pocket.getData 'mouse'
pocket.system 'mouse-master', [], (pocket) ->
  if mouse.buttons.left then alert('you\'re the mouse master!')
```

### Canvas2D
A component that stores a CanvasRenderingContext2D and various useful 2D canvas
drawing properties.
```coffeescript
# create a new mouse using the "Data Component" pattern above
pocket.component 'canvas', require 'pocket/src/utils/canvas-2d.coffee'
pocket.key canvas:
  width: 'auto'
  height: 'auto'
canvas = pocket.getData 'canvas'
pocket.system 'clear-canvas', [], (pocket) ->
  canvas.g2d.clearRect 0, 0, canvas.width, canvas.height
```

### PairSystem
A subclass of System that takes **two** dependency arrays and provides its
action function with **two** sets of keys and components. `PairSystem.forEach`
accepts a function that is invoked for **each pair** of keys. It's like having
two systems in one!

See `PairSystem` in action in the ["Custom Systems"](#custom-systems) example above.

### Vector and Rectangle
Static classes for manipulating 2D vectors of the form `{x, y}` and Rectangles
like `{x, y, width, height}`. Vectors and Rectangles are just plain objects so
they're fast and light. All operations happen through static functions that may
modify their arguments, like `Vector.add(v1, v2)`.

See `Rectangle` in action in the ["Custom Systems"](#custom-systems) example above.

```coffeescript
# define 2D components trivially
Vector = require 'pocket/src/utils/vector.coffee'
pocket.component 'position', Vector.new()
pocket.component 'velocity', Vector.new()
pocket.systemForEach 'move', ['position', 'velocity'],
  (pocket, key, pos, vel) -> Vector.add pos, vel
```

### ScoreKeeper
Keep score in your game and automatically update the high score. Persist your high
scores across multiple sessions with built-in `localStorage` support. Emits events
when points are added or a new highscore is set.
```coffeescript
ScoreKeeper = require 'pocket/src/utils/score-keeper.coffee'
keeper = new ScoreKeeper(8) # initial high score
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
