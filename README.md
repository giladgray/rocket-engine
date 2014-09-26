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

# 1. define components...
# ... as default values
pocket.component 'position', {x: 0, y: 0}
# ... or as functions
pocket.component 'velocity', (cmp, options) ->
  cmp.velocity = {x: options.x ? 0, y: options.y ? 0}

# 2. define systems that operate on keys with specific
# components or labels.
pocket.system 'apply-velocity', # friendly name
  # required components or labels for a key
  ['position', 'velocity'],
  # function to call for each key that has all components
  (pocket, key, position, velocity) ->
    position.x += velocity.x
    position.y += velocity.y

# 3. add keys that contain components or labels.
pocket.key {
  spaceship: null # a label
  position: {x: WIDTH / 2, y: HEIGHT / 2}
  velocity: null # use default component values
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
  for i in [1..5]
    pocket.key
      badguy: true
      position: randomPosition()
      health: 10
      speed: i

# more advanced systems on the way:
# - input components: keyboard and mouse
# - graphics systems: Context2D data and rendering components
```

## Thanks
My deepest thanks go to @kirbysayshi for his presentation
[Developing Games Using Data not Trees](http://2014.jsconf.eu/speakers/#/speakers/drew-petersen-developing-games-using-data-not-trees)
at JSConf EU 2014, and for his code at [kirbysayshi/pocket-ces](https://github.com/kirbysayshi/pocket-ces).

## License
MIT
