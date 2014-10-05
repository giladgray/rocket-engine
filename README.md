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
  spaceship : null # a label*
  velocity  : null # use default component values
  position  : {x: WIDTH / 2, y: HEIGHT / 2}
}

# * a label is simply a component without a definition,
# used to tag keys for easy discovery.
```

## Advanced Systems Design
```coffeescript
# singleton data can be stored as a key with a single component
pocket.component 'config', require './config'
pocket.key 'config', {config: null}
# and treated as data rather than a standard key
config = pocket.getData 'config'

# a system with no dependencies can be used to setup the game
pocket.system 'inital-badguy-generation', [], (pocket) ->
  for i in [1..5]
    pocket.key
      badguy: true
      position: randomPosition()
      health: 10
      speed: i

# a system that operates on multiple keys can use systemForEach
# to reduce boilerplate. turn this:
pocket.system 'move', ['position', 'velocity'],
  (pocket, keys, position, velocity) ->
    for key in keys
      Vector.add position[key], velocity[key]
# into this:
pocket.systemForEach 'move', ['position', 'velocity'],
  (pocket, key, pos, vel) -> Vector.add pos, vel

# more advanced systems on the way:
# - input components: keyboard and mouse
# - graphics systems: Context2D data and rendering components
```

## Thanks
My deepest thanks go to Drew Petersen (@kirbysayshi) for his presentation
[Developing Games Using Data not Trees](http://2014.jsconf.eu/speakers/#/speakers/drew-petersen-developing-games-using-data-not-trees)
at JSConf EU 2014, and for his code at [kirbysayshi/pocket-ces](https://github.com/kirbysayshi/pocket-ces).

## License
MIT
