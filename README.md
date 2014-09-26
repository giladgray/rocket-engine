Pocket
======

> A little game engine that fits in your pocket

## Development
1. `npm install`
2. `gulp watch` to lint and test :coffee:

## Usage
```coffeescript
Pocket = require 'pocket'

pocket = new Pocket

# define components...
# ... as default values
pocket.component 'position', {x: 0, y: 0}
# ... or as functions
pocket.component 'velocity', (cmp, options) ->
  cmp.velocity = {x: options.x ? 0, y: options.y ? 0}

# define systems that operate on keys with specific
# components or labels.
pocket.system 'apply-velocity',
  ['position', 'velocity'],
  (pocket, key, position, velocity) ->
    position.x += velocity.x
    position.y += velocity.y

# add keys that contain components or labels.
pocket.key {
  spaceship: null # a label
  position: {x: WIDTH / 2, y: WIDTH / 2}
  velocity: null # use default values
}

# a label is simply a component without a definition,
# used to tag keys for easy discovery.
```

## Advanced Systems Design
```coffeescript
# singleton data can be stored as a key with a single component
pocket.component 'config', require './config'
pocket.key 'config', {config: null}
# and treated as data rather than a standard key
config = pocket.getData 'config' # (aka firstData)

# a system with no dependencies can be used to setup the game
pocket.system 'inital-badguy-generation', (pocket) ->
  for i in [0...3]
    pocket.key
      badguy: true
      position: randomPosition()
      health: 10
      speed: 3

# more advanced systems:
# - input components: keyboard and mouse
# - graphics systems: Context2D data and rendering components
```
