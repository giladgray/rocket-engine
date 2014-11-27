(function e(t,n,r){function s(o,u){if(!n[o]){if(!t[o]){var a=typeof require=="function"&&require;if(!u&&a)return a(o,!0);if(i)return i(o,!0);var f=new Error("Cannot find module '"+o+"'");throw f.code="MODULE_NOT_FOUND",f}var l=n[o]={exports:{}};t[o][0].call(l.exports,function(e){var n=t[o][1][e];return s(n?n:e)},l,l.exports,e,t,n,r)}return n[o].exports}var i=typeof require=="function"&&require;for(var o=0;o<r.length;o++)s(r[o]);return s})({1:[function(require,module,exports){
var GRAVITY, Vector, canvas, colors, countElem, curColor, fn, i, nextColor, numBalls, randomBall, rocket, start, updateCount, _i;

fn = require('../../src/fn.coffee');

Vector = require('../../src/utils/vector.coffee');

numBalls = 0;

countElem = document.querySelector('.count');

updateCount = function(delta) {
  if (delta) {
    numBalls += delta;
  } else {
    numBalls = 0;
  }
  return countElem.textContent = numBalls;
};

rocket = new Rocket;

rocket.component('canvas', require('../../src/utils/canvas-2d.coffee'));

rocket.key({
  canvas: {
    width: 'auto',
    height: 'auto'
  }
});

canvas = rocket.getData('canvas');

rocket.component('keyboard', require('../../src/utils/keyboard-state.coffee'));

rocket.key({
  keyboard: {
    keymap: {
      13: 'ADD',
      32: 'DESTROY'
    }
  }
});

rocket.systemForEach('input-balls', ['keyboard'], function(rocket, key, keyboard) {
  if (keyboard.isNewPress('DESTROY')) {
    rocket.destroyKeys(rocket.filterKeys('ball'));
    updateCount(0);
  }
  if (keyboard.isNewPress('ADD')) {
    return randomBall();
  }
});

rocket.component('position', {
  x: 0,
  y: 0
});

rocket.component('velocity', {
  x: 0,
  y: 0
});

rocket.component('circle', {
  radius: 30,
  color: 'red'
});

colors = ['seagreen', 'navy', 'indigo', 'firebrick', 'goldenrod'];

curColor = 0;

nextColor = function() {
  var color;
  color = colors[curColor++];
  curColor %= colors.length;
  return color;
};

randomBall = function() {
  var height, radius, width;
  updateCount(1);
  width = canvas.width, height = canvas.height;
  radius = fn.random(20, 100);
  return rocket.key({
    ball: true,
    position: {
      x: fn.random(radius, width - radius),
      y: fn.random(radius, height / 2 - radius)
    },
    velocity: {
      x: fn.random(-8, 8),
      y: 0
    },
    circle: {
      radius: radius,
      color: nextColor()
    }
  });
};

for (i = _i = 0; _i < 5; i = ++_i) {
  randomBall();
}


/* NOW IT'S IDENTICAL TO BOUNCE! DEMO */

GRAVITY = Vector["new"](0, 0.5);

rocket.systemForEach('gravity', ['velocity'], function(rocket, key, vel) {
  return Vector.add(vel, GRAVITY);
});

rocket.systemForEach('move', ['position', 'velocity'], function(rocket, key, pos, vel) {
  return Vector.add(pos, vel);
});

rocket.system('clear-canvas', [], function(rocket) {
  var g2d, height, width;
  g2d = canvas.g2d, width = canvas.width, height = canvas.height;
  return g2d.clearRect(0, 0, width, height);
});

rocket.systemForEach('draw-ball', ['position', 'circle'], function(rocket, key, pos, circle) {
  var g2d;
  g2d = canvas.g2d;
  g2d.beginPath();
  g2d.fillStyle = circle.color;
  g2d.arc(pos.x, pos.y, circle.radius, 0, Math.PI * 2);
  g2d.closePath();
  return g2d.fill();
});

rocket.systemForEach('bounce', ['position', 'velocity', 'circle'], function(pkt, key, pos, vel, _arg) {
  var height, radius, width;
  radius = _arg.radius;
  width = canvas.width, height = canvas.height;
  if (pos.x < radius || pos.x > width - radius) {
    vel.x *= -1;
    pos.x += vel.x;
  }
  if (pos.y < radius || pos.y > height - radius) {
    vel.y *= -1;
    return pos.y += vel.y;
  }
});

start = function(time) {
  rocket.tick(time);
  return window.requestAnimationFrame(start);
};

document.addEventListener('DOMContentLoaded', function() {
  return start();
});



},{"../../src/fn.coffee":2,"../../src/utils/canvas-2d.coffee":3,"../../src/utils/keyboard-state.coffee":4,"../../src/utils/vector.coffee":5}],2:[function(require,module,exports){

/*
A mindblowingly simple functional toolbelt. Sound familiar_?

@method .uniqueId(prefix)
  Generate a unique identifier with an optional prefix.
  @param prefix [String] optional value to prepend to identifier
  @return [String] unique identifier

@method .isNumber(arg)
  Returns `true` if arg is a Number
  @param arg [*] any value
  @return [Boolean] `true` if arg is a Number

@method .isString(arg)
  Returns `true` if arg is a String
  @param arg [*] any value
  @return [Boolean] `true` if arg is a String

@method .isBoolean(arg)
  Returns `true` if arg is a Boolean
  @param arg [*] any value
  @return [Boolean] `true` if arg is a Boolean

@method .isArray(arg)
  Returns `true` if arg is an Array
  @param arg [*] any value
  @return [Boolean] `true` if arg is an Array

@method .isObject(arg)
  Returns `true` if arg is an Object
  @param arg [*] any value
  @return [Boolean] `true` if arg is an Object

@method .isFunction(arg)
  Returns `true` if arg is a Function
  @param arg [*] any value
  @return [Boolean] `true` if arg is a Function
 */
var Fn,
  __slice = [].slice,
  __hasProp = {}.hasOwnProperty;

Fn = (function() {
  var objectTypes, type, _fn, _i, _len, _ref;

  function Fn() {}


  /*
  Generate a unique identifier with an optional prefix.
  @param prefix [String] optional value to prefix returned identifier
  @return [String] unique identifier
   */

  Fn.uniqueId = (function() {
    var nextId;
    nextId = 0;
    return function(prefix) {
      if (prefix == null) {
        prefix = '';
      }
      return prefix + (nextId++);
    };
  })();

  objectTypes = {};

  _ref = ['Number', 'String', 'Boolean', 'Object', 'Array', 'Function'];
  _fn = function(type) {
    return Fn["is" + type] = function(val) {
      return Object.prototype.toString.call(val) === objectTypes[type];
    };
  };
  for (_i = 0, _len = _ref.length; _i < _len; _i++) {
    type = _ref[_i];
    objectTypes[type] = "[object " + type + "]";
    _fn(type);
  }


  /*
  Returns a random integer between `[min, max)`: from `min` (inclusive) up to but
  not including `max` (exclusive). If only one argument `max` is provided, the range
  becomes `[0, max)`. Uses `Math.random()` internally.
  @param min [Number] minimum value, inclusive; defaults to 0 if omitted
  @param max [Number] maximum value, exclusive
  @return [Number] random integer between `min` and `max`
   */

  Fn.random = function(min, max) {
    if (max == null) {
      max = min;
      min = 0;
    }
    return Math.floor(Math.random() * (max - min)) + min;
  };


  /*
  Flattens a nested array (the nesting can be to any depth). Accepts a single array or splat of
  mixed types.
  @param arrays [Array...] a single array of splat of values to flatten
  @return [Array] a single flattened array
   */

  Fn.flatten = function() {
    var arg, flattened, _j, _len1;
    if (arguments.length === 1) {
      arg = arguments[0];
      if (Fn.isArray(arg)) {
        return Fn.flatten.apply(null, arg);
      } else {
        return [arg];
      }
    }
    flattened = [];
    for (_j = 0, _len1 = arguments.length; _j < _len1; _j++) {
      arg = arguments[_j];
      if (Fn.isArray(arg)) {
        flattened.push.apply(flattened, Fn.flatten.apply(Fn, arg));
      } else {
        flattened.push(arg);
      }
    }
    return flattened;
  };


  /*
  Recursively merges own enumerable properties of source objects into destination object.
  Subsequent sources will overwrite property assignments of previous sources.
  @param object [Object] destination object to merge properties into.
  @param sources [Object...] splat of source objects
  @return [Object] destination object with merged properties
   */

  Fn.merge = function() {
    var key, object, source, sources, val, _j, _len1, _ref1;
    object = arguments[0], sources = 2 <= arguments.length ? __slice.call(arguments, 1) : [];
    for (_j = 0, _len1 = sources.length; _j < _len1; _j++) {
      source = sources[_j];
      for (key in source) {
        if (!__hasProp.call(source, key)) continue;
        val = source[key];
        if (Fn.isObject(val)) {
          object[key] = Fn.merge((_ref1 = object[key]) != null ? _ref1 : {}, val);
        } else {
          object[key] = val;
        }
      }
    }
    return object;
  };


  /*
  Creates a new object with the same properties as the given object.
  @param object [Object] object to clone
  @return [Object] a clone of the given object
   */

  Fn.clone = function(object) {
    return Fn.merge({}, object);
  };


  /*
  Assigns own enumerable properties of source object(s) to the destination object for all
  destination properties that resolve to undefined. Once a property is set, additional defaults of
  the same property will be ignored.
  @param object [Object] destination object to merge properties into.
  @param sources [Object...] splat of source objects
  @return [Object] destination object with merged properties
   */

  Fn.defaults = function() {
    var key, object, source, sources, val, _j, _len1;
    object = arguments[0], sources = 2 <= arguments.length ? __slice.call(arguments, 1) : [];
    for (_j = 0, _len1 = sources.length; _j < _len1; _j++) {
      source = sources[_j];
      for (key in source) {
        if (!__hasProp.call(source, key)) continue;
        val = source[key];
        if (object[key] === void 0) {
          object[key] = val;
        }
      }
    }
    return object;
  };


  /*
  Retrieves the value of a specified property from all elements in the array.
  @param collection [Array] array of elements
  @param property [String] property name to pluck
  @return [Array] array of values for given property
   */

  Fn.pluck = function(collection, property) {
    var item, _j, _len1, _results;
    _results = [];
    for (_j = 0, _len1 = collection.length; _j < _len1; _j++) {
      item = collection[_j];
      _results.push(item[property]);
    }
    return _results;
  };

  return Fn;

})();

module.exports = Fn;



},{}],3:[function(require,module,exports){

/*
A component definition for a 2D canvas graphics provider. Given a selector for a canvas element,
stores a reference to the CanvasRenderingContext2D, its width and height, and a center vector.
Automatically updates canvas size if one or both dimensions are set to 'auto'.

A `canvas-2d` component defines several keys:
- **`canvas`** - the canvas element that is being rendered to
- **`width`** - the width of the canvas, in pixels
- **`height`** - the height of the canvas, in pixels
- **`g2d`** - a CanvasRenderingContext2D graphics drawing surface
- **`camera`** - a 2D vector representing the location of the 'camera'. the component does not
  actually use this value, but instead provides it in a central place for your
  game to modify and for your rendering systems to use.

@example
   * require and register the component
  rocket.component 'canvas-2d', require('rocket-engine/utils/canvas-2d.coffee')
   * define a key with the canvas-2d component and your options
  rocket.key {
  	'canvas-2d':
      canvas: '#game'
      width : 'auto'
      height: 600
  }
   * use rocket.getData in a system to get the component data and draw some graphics!
  rocket.systemForEach 'draw-squares', ['position', 'square'], (p, k, {x, y}, {size, color}) ->
  	{g2d} = p.getData 'canvas-2d'
  	g2d.fillStyle = color
  	g2d.fillRect x, y, size, size

@param {Object}       cmp    component entry
@param {String}       canvas CSS selector for canvas element (default: `'#canvas'`)
@param {Integer|auto} width  width of canvas element, or 'auto' to match window width
  (default: `'auto'`)
@param {Integer|auto} height height of canvas element, or 'auto' to match window height
  (default: `'auto'`)
 */
var Canvas2D;

Canvas2D = function(cmp, _arg) {
  var autoWidth, autoheight, canvas, height, resize, width;
  canvas = _arg.canvas, width = _arg.width, height = _arg.height;
  autoWidth = width === 'auto';
  autoheight = height === 'auto';
  cmp.canvas = document.querySelector(canvas || 'canvas');
  cmp.g2d = cmp.canvas.getContext('2d');
  cmp.camera = {
    x: 0,
    y: 0
  };
  cmp.pointShape = function(points) {
    var i, pt, _i, _len;
    for (i = _i = 0, _len = points.length; _i < _len; i = ++_i) {
      pt = points[i];
      if (i === 0) {
        cmp.g2d.moveTo(pt.x, pt.y);
      } else {
        cmp.g2d.lineTo(pt.x, pt.y);
      }
    }
    return cmp.g2d.lineTo(points[0].x, points[0].y);
  };
  window.addEventListener('resize', resize = function() {
    cmp.width = cmp.canvas.width = autoWidth ? document.body.clientWidth : width;
    return cmp.height = cmp.canvas.height = autoheight ? document.body.clientHeight : height;
  });
  return resize();
};

module.exports = Canvas2D;



},{}],4:[function(require,module,exports){

/*
A component that stores keyboard state and supports a map of keys to action names. Keyboard
state is stored in the `down` field. When a key is pressed, its keyCode is set to true and
its action name, if present in the `keymap, is set to the time at which it was pressed.

To check if a given key is pressed, either look up its keyCode (`event.which`) or its name
in the keymap via `cmp.down[keyCode]` or `cmp.down[keyName] isnt 0`.

The `keymap` is a map of keyCodes or key names to string names, allowing for dynamic
and descriptive bindings, such as `{32: 'SHOOT'}` to name the spacebar 'SHOOT'. When
the spacebar is pressed, `cmp.down.SHOOT` will contain the time at which it was pressed. The
keymap also supports single-character key names such as `{W: 'UP', S: 'DOWN'}` and a number of
whole-word key names, which will be converted to their corresponding keyCodes.

Supported whole-word key names (case sensitive): Alt, Bksp, Backspace, Caps, CapsLock, Ctrl,
Enter, Esc, Escape, Shift, Space, Tab, Up, Left, Down, Right.

The component provides a function `isNewPress(keyName, recency=10)` that returns true if the
`keyName` was pressed at least `recency` milliseconds ago. Only the first call to `isNewPress`
after a key is pressed will return true because the keypress is no longer new. You can still
check that the key is pressed `if cmp.down[keyName] isnt 0`.

@example
   * register the keyboard-state component
  rocket.component 'keyboard-state', require('rocket-engine/utils/keyboard-state.coffee')
   * define a key with keymap for your game
  rocket.key {
    'keyboard-state':
      keymap:
        27: 'MENU'  # esc
        32: 'SHOOT' # space
        37: 'LEFT'  # left arrow
        39: 'RIGHT' # right arrow
  }
   * call rocket.getData in a system to use the keyboard
  rocket.systemForEach 'name', ['player'], (rocket, key, player) ->
    keyboard = rocket.getData 'keyboard-state'
    player.shoot()  if keyboard.isNewPress 'SHOOT'
    player.move(-1) if keyboard.down.LEFT
    player.move(1)  if keyboard.down.RIGHT

@param {Object} cmp    component entry
@param {String} target CSS selector of target element for keypress events,
  or omit to bind to `document`
@param {Object} keymap map of keyCodes to string names
 */
var KeyboardState, convertKeymap;

KeyboardState = function(cmp, _arg) {
  var keymap, target;
  target = _arg.target, keymap = _arg.keymap;
  keymap = convertKeymap(keymap);
  cmp.target = typeof target === 'string' ? document.querySelector(target) : document.body;
  cmp.down = {};
  cmp.isNewPress = function(keyName, recency) {
    var delta, downTime;
    if (recency == null) {
      recency = 10;
    }
    downTime = cmp.down[keyName];
    delta = Date.now() - downTime;
    if (downTime > 0 && delta > recency) {
      cmp.down[keyName] = -1;
      return true;
    }
    return false;
  };
  cmp.target.addEventListener('keydown', function(e) {
    var keyName;
    keyName = keymap[e.which];
    cmp.down[e.which] = true;
    if (keyName && cmp.down[keyName] === 0) {
      return cmp.down[keyName] = Date.now();
    }
  });
  return cmp.target.addEventListener('keyup', function(e) {
    var keyName;
    keyName = keymap[e.which];
    cmp.down[e.which] = false;
    if (keyName) {
      return cmp.down[keyName] = 0;
    }
  });
};

KeyboardState.SpecialKeys = {
  Alt: 18,
  Bksp: 8,
  Caps: 20,
  Ctrl: 17,
  Enter: 13,
  Esc: 27,
  Escape: 27,
  Shift: 16,
  Space: 32,
  Tab: 9,
  Backspace: 8,
  CapsLock: 20,
  Up: 38,
  Left: 37,
  Down: 40,
  Right: 39
};

convertKeymap = function(keymap) {
  var code, key, name;
  if (keymap == null) {
    keymap = {};
  }
  for (key in keymap) {
    name = keymap[key];
    if (!(!+key)) {
      continue;
    }
    delete keymap[key];
    if (key.length === 1) {
      keymap[key.charCodeAt(0)] = name;
    } else if (code = KeyboardState.SpecialKeys[key]) {
      keymap[code] = name;
    } else {
      throw new Error("KeyboardState: unknown key name '" + key + "'");
    }
  }
  return keymap;
};

KeyboardState.convertKeymap = convertKeymap;

module.exports = KeyboardState;



},{}],5:[function(require,module,exports){

/*
A static 2-dimensional Vector operations library.

A vector is simply a regular object with keys `{x, y}`. `Vector.new(x, y)` is shorthand for creating
this object, but you can easily do it yourself too.

All vector operations operate on one or two vectors. `equal`, `angle`, `distSq`, and `dist`
return scalar values and leave the vector unchanged. `add`, `sub`, `scale`, and `invert` will
by default mutate the components of the first vector argument and return it. if the final `clone`
argument is set to `true` on these operations then they will return a *new* vector object with
final component values.

All functions on this class are static and the constructor should never be used.

@example
  v1 = Vector.new(10, 20)
  v2 = {x: 1, y: 2}

   * add in place
  v3 = Vector.add(v1, v2)
   * -> v1 == (11, 22); v3 === v1

   * add and clone
  v4 = Vector.add(v1, v2, true)
   * -> v4 == (12, 24); v4 !== v1
 */
var Vector;

module.exports = Vector = (function() {
  var normalize;

  function Vector() {
    throw new Error('Vector: static class, do not use constructor');
  }

  normalize = function(num) {
    if (Math.abs(num) < 1e-10) {
      return 0;
    } else {
      return num;
    }
  };


  /*
  Create a new Vector. A vector is simply an object with keys `{x,y}`. This method is provided
  as shorthand and allows for default and optional parameters.
  @param x [Number] x coordinate of vector
  @param y [Number] y coordinate of vector
   */

  Vector["new"] = function(x, y) {
    if (x == null) {
      x = 0;
    }
    if (y == null) {
      y = 0;
    }
    return {
      x: x,
      y: y
    };
  };


  /*
  Create a new Vector from polar coordinates `(r,θ)`.
  @param radius [Number] polar radius
  @param angle [Number] polar angle in radians
  @return [Vector] new vector with `{x,y}` coordinates.
   */

  Vector.fromPolar = function(radius, angle) {
    return Vector["new"](normalize(radius * Math.cos(angle)), normalize(radius * Math.sin(angle)));
  };

  Vector.clone = function(v) {
    return {
      x: v.x,
      y: v.y
    };
  };

  Vector.equal = function(v1, v2) {
    return v1.x === v2.x && v1.y === v2.y;
  };


  /*
  Adds two vectors, modifiying the first one and returning the resulting vector.  If `clone=true`
  then `v1` is first cloned and this new Vector with the added components is returned.
  @param v1 [Vector] first vector
  @param v2 [Vector] second vector
  @param clone [Boolean] whether to clone the first vector before modifying components
  @return [Vector] vector with added components
   */

  Vector.add = function(v1, v2, clone) {
    if (clone == null) {
      clone = false;
    }
    if (clone) {
      v1 = Vector.clone(v1);
    }
    v1.x += v2.x;
    v1.y += v2.y;
    return v1;
  };


  /*
  Subtracts two vectors, modifiying the first one and returning the resulting vector.  If
  `clone=true` then `v1` is first cloned and this new Vector with the subtracted components is
  returned.
  @param v1 [Vector] first vector
  @param v2 [Vector] second vector
  @param clone [Boolean] whether to clone the first vector before modifying components
  @return [Vector] vector with subtracted components
   */

  Vector.sub = function(v1, v2, clone) {
    if (clone == null) {
      clone = false;
    }
    if (clone) {
      v1 = Vector.clone(v1);
    }
    v1.x -= v2.x;
    v1.y -= v2.y;
    return v1;
  };


  /*
  Scales a vector by the given factor, modifiying it and returning the resulting vector.  If
  `clone=true` then `v` is first cloned and this new Vector with the scaled components is returned.
  @param v [Vector] vector
  @param factor [Number] amount to scale each component by
  @param clone [Boolean] whether to clone the first vector before modifying components
  @return [Vector] vector with scaled components
   */

  Vector.scale = function(v, factor, clone) {
    if (clone == null) {
      clone = false;
    }
    if (clone) {
      v = Vector.clone(v);
    }
    v.x *= factor;
    v.y *= factor;
    return v;
  };


  /*
  Scales a vector by -1 so it points in the opposite direction, modifiying it and returning the
  resulting vector.  If `clone=true` then `v` is first cloned and this new Vector with the inverted
  components is returned.
  @param v [Vector] vector
  @param clone [Boolean] whether to clone the first vector before modifying components
  @return [Vector] vector with inverted components
   */

  Vector.invert = function(v, clone) {
    if (clone == null) {
      clone = false;
    }
    return Vector.scale(v, -1, clone);
  };

  Vector.angle = function(v) {
    return Math.atan2(v.y, v.x);
  };

  Vector.distSq = function(v) {
    return v.x * v.x + v.y * v.y;
  };

  Vector.dist = function(v) {
    return Math.sqrt(Vector.distSq(v));
  };

  return Vector;

})();



},{}]},{},[1]);
