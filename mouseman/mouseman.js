(function e(t,n,r){function s(o,u){if(!n[o]){if(!t[o]){var a=typeof require=="function"&&require;if(!u&&a)return a(o,!0);if(i)return i(o,!0);var f=new Error("Cannot find module '"+o+"'");throw f.code="MODULE_NOT_FOUND",f}var l=n[o]={exports:{}};t[o][0].call(l.exports,function(e){var n=t[o][1][e];return s(n?n:e)},l,l.exports,e,t,n,r)}return n[o].exports}var i=typeof require=="function"&&require;for(var o=0;o<r.length;o++)s(r[o]);return s})({1:[function(require,module,exports){
var Keeper, MAX_FUEL, Rectangle, Vector, canvas, fn, highscoreEl, mouse, mouseFuel, newBall, rocket, scoreEl, start;

fn = require('../../src/fn.coffee');

Vector = require('../../src/utils/vector.coffee');

Rectangle = require('../../src/utils/rectangle.coffee');

Keeper = require('../../src/utils/score-keeper.coffee');

rocket = new Rocket;

rocket.component('canvas', require('../../src/utils/canvas-2d.coffee'));

rocket.key({
  canvas: {
    width: 'auto',
    height: 'auto'
  }
});

canvas = rocket.getData('canvas');

rocket.component('mouse', require('../../src/utils/mouse-state.coffee'));

rocket.key({
  mouse: null
});

mouse = rocket.getData('mouse');

rocket.score = new Keeper;

scoreEl = document.querySelector('.scores .current');

highscoreEl = document.querySelector('.scores .best');

rocket.score.on('score', function(points) {
  return scoreEl.textContent = points;
});

rocket.score.on('highscore', function(points) {
  return highscoreEl.textContent = points;
});

rocket.component('position', {
  x: 0,
  y: 0
});

rocket.component('speed', {
  speed: 0
});

rocket.component('circle', {
  radius: 30,
  color: 'cornflowerblue'
});

MAX_FUEL = 5000;

mouseFuel = 0;

newBall = function() {
  mouseFuel = MAX_FUEL;
  return rocket.key({
    position: {
      x: fn.random(canvas.width),
      y: fn.random(canvas.height)
    },
    speed: null,
    circle: null
  });
};

newBall();

rocket.systemForEach('move-ball', ['position', 'speed'], function(rocket, key, pos, spd) {
  var angle, vel;
  if (!mouse.inWindow) {
    return;
  }
  angle = Math.atan2(mouse.cursor.y - pos.y, mouse.cursor.x - pos.x);
  vel = Vector.fromPolar(spd.speed, angle);
  if (mouse.buttons.left && mouseFuel > 0) {
    Vector.scale(vel, -1 / 4);
    mouseFuel -= rocket.delta;
  } else {
    spd.speed += 1 / 20;
    mouseFuel += rocket.delta / 3;
    mouseFuel = Math.min(mouseFuel, MAX_FUEL);
  }
  return Vector.add(pos, vel);
});

rocket.systemForEach('respawn-ball', ['position', 'circle'], function(rocket, key, pos, _arg) {
  var radius;
  radius = _arg.radius;
  if (Vector.dist(Vector.sub(mouse.cursor, pos, true)) < radius) {
    rocket.destroyKey(key);
    rocket.score.reset();
    return newBall();
  }
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

rocket.system('draw-fuel', [], function(rocket) {
  var g2d, height, width;
  g2d = canvas.g2d, width = canvas.width, height = canvas.height;
  g2d.beginPath();
  g2d.fillStyle = 'orange';
  g2d.fillRect(0, height - 30, mouseFuel / MAX_FUEL * width, 30);
  return g2d.closePath();
});

rocket.system('update-score', [], function(rocket) {
  if (!mouse.inWindow) {
    return;
  }
  return rocket.score.addPoints(Math.floor(rocket.delta || 0));
});

start = function(time) {
  rocket.tick(time);
  return window.requestAnimationFrame(start);
};

document.addEventListener('DOMContentLoaded', function() {
  return start();
});



},{"../../src/fn.coffee":3,"../../src/utils/canvas-2d.coffee":4,"../../src/utils/mouse-state.coffee":5,"../../src/utils/rectangle.coffee":6,"../../src/utils/score-keeper.coffee":7,"../../src/utils/vector.coffee":8}],2:[function(require,module,exports){
// Copyright Joyent, Inc. and other Node contributors.
//
// Permission is hereby granted, free of charge, to any person obtaining a
// copy of this software and associated documentation files (the
// "Software"), to deal in the Software without restriction, including
// without limitation the rights to use, copy, modify, merge, publish,
// distribute, sublicense, and/or sell copies of the Software, and to permit
// persons to whom the Software is furnished to do so, subject to the
// following conditions:
//
// The above copyright notice and this permission notice shall be included
// in all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
// OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
// MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN
// NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
// DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
// OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE
// USE OR OTHER DEALINGS IN THE SOFTWARE.

function EventEmitter() {
  this._events = this._events || {};
  this._maxListeners = this._maxListeners || undefined;
}
module.exports = EventEmitter;

// Backwards-compat with node 0.10.x
EventEmitter.EventEmitter = EventEmitter;

EventEmitter.prototype._events = undefined;
EventEmitter.prototype._maxListeners = undefined;

// By default EventEmitters will print a warning if more than 10 listeners are
// added to it. This is a useful default which helps finding memory leaks.
EventEmitter.defaultMaxListeners = 10;

// Obviously not all Emitters should be limited to 10. This function allows
// that to be increased. Set to zero for unlimited.
EventEmitter.prototype.setMaxListeners = function(n) {
  if (!isNumber(n) || n < 0 || isNaN(n))
    throw TypeError('n must be a positive number');
  this._maxListeners = n;
  return this;
};

EventEmitter.prototype.emit = function(type) {
  var er, handler, len, args, i, listeners;

  if (!this._events)
    this._events = {};

  // If there is no 'error' event listener then throw.
  if (type === 'error') {
    if (!this._events.error ||
        (isObject(this._events.error) && !this._events.error.length)) {
      er = arguments[1];
      if (er instanceof Error) {
        throw er; // Unhandled 'error' event
      }
      throw TypeError('Uncaught, unspecified "error" event.');
    }
  }

  handler = this._events[type];

  if (isUndefined(handler))
    return false;

  if (isFunction(handler)) {
    switch (arguments.length) {
      // fast cases
      case 1:
        handler.call(this);
        break;
      case 2:
        handler.call(this, arguments[1]);
        break;
      case 3:
        handler.call(this, arguments[1], arguments[2]);
        break;
      // slower
      default:
        len = arguments.length;
        args = new Array(len - 1);
        for (i = 1; i < len; i++)
          args[i - 1] = arguments[i];
        handler.apply(this, args);
    }
  } else if (isObject(handler)) {
    len = arguments.length;
    args = new Array(len - 1);
    for (i = 1; i < len; i++)
      args[i - 1] = arguments[i];

    listeners = handler.slice();
    len = listeners.length;
    for (i = 0; i < len; i++)
      listeners[i].apply(this, args);
  }

  return true;
};

EventEmitter.prototype.addListener = function(type, listener) {
  var m;

  if (!isFunction(listener))
    throw TypeError('listener must be a function');

  if (!this._events)
    this._events = {};

  // To avoid recursion in the case that type === "newListener"! Before
  // adding it to the listeners, first emit "newListener".
  if (this._events.newListener)
    this.emit('newListener', type,
              isFunction(listener.listener) ?
              listener.listener : listener);

  if (!this._events[type])
    // Optimize the case of one listener. Don't need the extra array object.
    this._events[type] = listener;
  else if (isObject(this._events[type]))
    // If we've already got an array, just append.
    this._events[type].push(listener);
  else
    // Adding the second element, need to change to array.
    this._events[type] = [this._events[type], listener];

  // Check for listener leak
  if (isObject(this._events[type]) && !this._events[type].warned) {
    var m;
    if (!isUndefined(this._maxListeners)) {
      m = this._maxListeners;
    } else {
      m = EventEmitter.defaultMaxListeners;
    }

    if (m && m > 0 && this._events[type].length > m) {
      this._events[type].warned = true;
      console.error('(node) warning: possible EventEmitter memory ' +
                    'leak detected. %d listeners added. ' +
                    'Use emitter.setMaxListeners() to increase limit.',
                    this._events[type].length);
      if (typeof console.trace === 'function') {
        // not supported in IE 10
        console.trace();
      }
    }
  }

  return this;
};

EventEmitter.prototype.on = EventEmitter.prototype.addListener;

EventEmitter.prototype.once = function(type, listener) {
  if (!isFunction(listener))
    throw TypeError('listener must be a function');

  var fired = false;

  function g() {
    this.removeListener(type, g);

    if (!fired) {
      fired = true;
      listener.apply(this, arguments);
    }
  }

  g.listener = listener;
  this.on(type, g);

  return this;
};

// emits a 'removeListener' event iff the listener was removed
EventEmitter.prototype.removeListener = function(type, listener) {
  var list, position, length, i;

  if (!isFunction(listener))
    throw TypeError('listener must be a function');

  if (!this._events || !this._events[type])
    return this;

  list = this._events[type];
  length = list.length;
  position = -1;

  if (list === listener ||
      (isFunction(list.listener) && list.listener === listener)) {
    delete this._events[type];
    if (this._events.removeListener)
      this.emit('removeListener', type, listener);

  } else if (isObject(list)) {
    for (i = length; i-- > 0;) {
      if (list[i] === listener ||
          (list[i].listener && list[i].listener === listener)) {
        position = i;
        break;
      }
    }

    if (position < 0)
      return this;

    if (list.length === 1) {
      list.length = 0;
      delete this._events[type];
    } else {
      list.splice(position, 1);
    }

    if (this._events.removeListener)
      this.emit('removeListener', type, listener);
  }

  return this;
};

EventEmitter.prototype.removeAllListeners = function(type) {
  var key, listeners;

  if (!this._events)
    return this;

  // not listening for removeListener, no need to emit
  if (!this._events.removeListener) {
    if (arguments.length === 0)
      this._events = {};
    else if (this._events[type])
      delete this._events[type];
    return this;
  }

  // emit removeListener for all listeners on all events
  if (arguments.length === 0) {
    for (key in this._events) {
      if (key === 'removeListener') continue;
      this.removeAllListeners(key);
    }
    this.removeAllListeners('removeListener');
    this._events = {};
    return this;
  }

  listeners = this._events[type];

  if (isFunction(listeners)) {
    this.removeListener(type, listeners);
  } else {
    // LIFO order
    while (listeners.length)
      this.removeListener(type, listeners[listeners.length - 1]);
  }
  delete this._events[type];

  return this;
};

EventEmitter.prototype.listeners = function(type) {
  var ret;
  if (!this._events || !this._events[type])
    ret = [];
  else if (isFunction(this._events[type]))
    ret = [this._events[type]];
  else
    ret = this._events[type].slice();
  return ret;
};

EventEmitter.listenerCount = function(emitter, type) {
  var ret;
  if (!emitter._events || !emitter._events[type])
    ret = 0;
  else if (isFunction(emitter._events[type]))
    ret = 1;
  else
    ret = emitter._events[type].length;
  return ret;
};

function isFunction(arg) {
  return typeof arg === 'function';
}

function isNumber(arg) {
  return typeof arg === 'number';
}

function isObject(arg) {
  return typeof arg === 'object' && arg !== null;
}

function isUndefined(arg) {
  return arg === void 0;
}

},{}],3:[function(require,module,exports){

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



},{}],4:[function(require,module,exports){

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



},{}],5:[function(require,module,exports){

/*
A component that stores mouse cursor and buttons state. Also sets a flag if the mouse leaves
the window.

Button state is stored as boolean values in `cmp.buttons.{left|middle|right}`. A `true` value
means the button is currently pressed.

Mouse cursor is stored as a {Vector} in `cmp.cursor` with `x` and `y` properties. If an `origin`
Vector option is provided then the mouse cursor will be stored relative to that point.

The boolean flag `cmp.isWindow` is true when the mouse cursor is inside the window and `false`
when it leaves. This can be used to implement a simple pause feature.

@param  {Object} cmp    component entry
@param {String} target CSS selector for element to bind listeners to (default: document.body)
@param {Vector} origin Vector that cursor will be stored relative to (default: `{x:0, y:0}`)
 */
var MouseState;

MouseState = function(cmp, _arg) {
  var origin, target, _ref, _ref1;
  target = _arg.target, origin = _arg.origin;
  if (origin == null) {
    origin = {};
  }
  cmp.origin = {
    x: (_ref = origin.x) != null ? _ref : 0,
    y: (_ref1 = origin.y) != null ? _ref1 : 0
  };
  cmp.target = typeof target === 'string' ? document.querySelector(target) : document.body;
  cmp.buttons = {
    left: false,
    middle: false,
    right: false
  };
  cmp.cursor = {
    x: null,
    y: null
  };
  cmp.inWindow = true;
  cmp.target.addEventListener('mousemove', function(e) {
    cmp.cursor.x = e.clientX - cmp.origin.x;
    return cmp.cursor.y = e.clientY - cmp.origin.x;
  });
  cmp.target.addEventListener('mousedown', function(e) {
    if (e.which === 1) {
      cmp.buttons.left = true;
    }
    if (e.which === 2) {
      cmp.buttons.middle = true;
    }
    if (e.which === 3) {
      return cmp.buttons.right = true;
    }
  });
  cmp.target.addEventListener('mouseup', function(e) {
    if (e.which === 1) {
      cmp.buttons.left = false;
    }
    if (e.which === 2) {
      cmp.buttons.middle = false;
    }
    if (e.which === 3) {
      return cmp.buttons.right = false;
    }
  });
  cmp.target.addEventListener('mouseenter', function(e) {
    return cmp.inWindow = true;
  });
  return cmp.target.addEventListener('mouseleave', function(e) {
    return cmp.inWindow = false;
  });
};

module.exports = MouseState;



},{}],6:[function(require,module,exports){

/*
A static Rectangle operations library.

A rectangle is simply an object with keys `{left, top, width, height}`.
`Rectangle.new(left, top, width, height)` is shorthand for creating this object, but you can easily
do it yourself too. `Rectangle.new(left, top, size)` will create a square where
`size == width == height`.

All functions on this class are static and the constructor should never be used.

@example
   * A classic Rectangle:
  r1 = Rectangle.new(1, 2, 3, 4)
   * A square Rectangle:
  r2 = Rectangle.centered(1, 1, 4)
   * A DIY Rectangle:
  r3 = {left: -1, top: -1, width: 4, height: 4}

  Rectangle.equal(r2, r3)   # -> true
  Rectangle.overlap(r1, r2) # -> true
 */
var Rectangle;

module.exports = Rectangle = (function() {
  function Rectangle() {
    throw new Error('Rectangle: static class, do not use constructor');
  }


  /*
  Create a new Rectangle. A rectangle is simply an object with keys `{left,top,width,height}`.
  This method is provided to easily define these objects and allows a "square" shorthand by
  omitting the `height` parameter.
  @param left   [Number] left coordinate of upper-left corner
  @param top    [Number] top coordinate of upper-left corner
  @param width  [Number] width of rectangle
  @param height [Number] height of rectangle. omit to create a square.
  @return [Rectangle] new rectangle
   */

  Rectangle["new"] = function(left, top, width, height) {
    if (left == null) {
      left = 0;
    }
    if (top == null) {
      top = 0;
    }
    if (width == null) {
      width = 0;
    }
    if (height == null) {
      height = width;
    }
    return {
      left: left,
      top: top,
      width: width,
      height: height
    };
  };

  Rectangle.clone = function(rect) {
    return {
      left: rect.left,
      top: rect.top,
      width: rect.width,
      height: rect.height
    };
  };


  /*
  Creates a new Rectangle *centered* at (x,y).
  @param x      [Number] x coordinate of rectangle center
  @param y      [Number] y coordinate of rectangel center
  @param width  [Number] width of rectangle
  @param height [Number] height of rectangle
  @return [Rectangle] rectangle centered at (x,y)
   */

  Rectangle.centered = function(x, y, width, height) {
    if (x == null) {
      x = 0;
    }
    if (y == null) {
      y = 0;
    }
    if (width == null) {
      width = 0;
    }
    if (height == null) {
      height = width;
    }
    return Rectangle["new"](x - width / 2, y - height / 2, width, height);
  };

  Rectangle.equal = function(r1, r2) {
    return r1.left === r2.left && r1.top === r2.top && r1.width === r2.width && r2.height === r2.height;
  };

  Rectangle.area = function(r) {
    return r.width * r.height;
  };


  /*
  Translates a Rectangle's (left,top) by the given (x,y) coordinates. Modifies the given
  Rectangle unless `clone==true`, in which case a new instance is returned with the translated
  components.
  @param r [Rectangle] rectangle
  @param x [Number] amount to translate `r.left`
  @param y [Number] amount to translate `r.top`
  @param clone [Boolean] whether to clone the rectangle before modifying components
  @return [Rectangle] the rectangle, translated
  
  @overload .translate(r, v, clone = false)
    Translates a Rectangle's (left,top) by the given Vector. Modifies the given Rectangle unless
    `clone==true`, in which case a new instance is returned with the translated components.
    @param r [Rectangle] rectangle
    @param v [Vector] translation vector
    @param clone [Boolean] whether to clone the rectangle before modifying components
    @return [Rectangle] the rectangle, translated
   */

  Rectangle.translate = function(r, x, y, clone) {
    var _ref;
    if (x == null) {
      x = 0;
    }
    if (y == null) {
      y = 0;
    }
    if (clone == null) {
      clone = false;
    }
    if (typeof x === 'object' && (x.x != null) && (x.y != null)) {
      clone = y;
      _ref = x, x = _ref.x, y = _ref.y;
    }
    if (clone) {
      r = Rectangle.clone(r);
    }
    r.left += x;
    r.top += y;
    return r;
  };

  Rectangle.overlap = function(r1, r2) {
    var xOverlap, yOverlap;
    xOverlap = yOverlap = true;
    if (r1.left > r2.left + r2.width || r1.left + r1.width < r2.left) {
      xOverlap = false;
    }
    if (r1.top > r2.top + r2.height || r1.top + r1.height < r2.top) {
      yOverlap = false;
    }
    return xOverlap && yOverlap;
  };

  return Rectangle;

})();



},{}],7:[function(require,module,exports){
var ScoreKeeper, events,
  __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

events = require('events');


/*
Keeps track of current score and high score. Emits events when points are added or a new
high score is achieved. Saves high score to localStorage, if enabled.
 */

ScoreKeeper = (function() {

  /*
  Create a new ScoreKeeper with an initial high score.
  @param  {Number} highScore initial high score
   */
  function ScoreKeeper(highScore) {
    this.highScore = highScore != null ? highScore : 0;
    this.off = __bind(this.off, this);
    this.once = __bind(this.once, this);
    this.on = __bind(this.on, this);
    this._events = new events.EventEmitter;
    this.score = 0;
  }

  ScoreKeeper.prototype.on = function() {
    var _ref;
    return (_ref = this._events).on.apply(_ref, arguments);
  };

  ScoreKeeper.prototype.once = function() {
    var _ref;
    return (_ref = this._events).once.apply(_ref, arguments);
  };

  ScoreKeeper.prototype.off = function() {
    var _ref;
    return (_ref = this._events).removeListener.apply(_ref, arguments);
  };


  /*
  Add a number of points to the score and maybe updates high score.
  @param {Number} amt points to add
  @event score
    emits an event when points are added. arguments are `(total score, new points)`.
  @event highscore
    emits an event when a new high score is set. arguments are `(highscore)`.
   */

  ScoreKeeper.prototype.addPoints = function(amt) {
    if (amt == null) {
      amt = 0;
    }
    this.score += amt;
    if (this.score > this.highScore) {
      this.highScore = this.score;
      this.saveHighScore();
    }
    return this._events.emit('score', this.score, amt);
  };


  /*
  Resets the score to zero.
   */

  ScoreKeeper.prototype.reset = function() {
    var oldScore;
    oldScore = this.score;
    this.score = 0;
    return this._events.emit('score', this.score, -oldScore);
  };


  /*
  Enables saving of the high score to the given localStorage key.
  @param {String} scoreKey localStorage key for saving high score
   */

  ScoreKeeper.prototype.enableSaving = function(scoreKey) {
    var savedScore;
    this.scoreKey = scoreKey;
    savedScore = localStorage.getItem(this.scoreKey);
    if (savedScore != null) {
      return this.highScore = savedScore;
    }
  };


  /*
  Disables saving of the high score by forgetting the localStorage key.
   */

  ScoreKeeper.prototype.disableSaving = function() {
    return this.scoreKey = void 0;
  };


  /*
  Saves the current highscore to localStorage and emits an event.
  @event highscore
    emits an event when a new high score is set. arguments are `(highscore)`.
   */

  ScoreKeeper.prototype.saveHighScore = function() {
    this._events.emit('highscore', this.highScore);
    if (!this.scoreKey) {
      return;
    }
    return localStorage.setItem(this.scoreKey, this.highScore);
  };

  return ScoreKeeper;

})();

module.exports = ScoreKeeper;



},{"events":2}],8:[function(require,module,exports){

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
