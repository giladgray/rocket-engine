(function e(t,n,r){function s(o,u){if(!n[o]){if(!t[o]){var a=typeof require=="function"&&require;if(!u&&a)return a(o,!0);if(i)return i(o,!0);var f=new Error("Cannot find module '"+o+"'");throw f.code="MODULE_NOT_FOUND",f}var l=n[o]={exports:{}};t[o][0].call(l.exports,function(e){var n=t[o][1][e];return s(n?n:e)},l,l.exports,e,t,n,r)}return n[o].exports}var i=typeof require=="function"&&require;for(var o=0;o<r.length;o++)s(r[o]);return s})({1:[function(require,module,exports){
var GRAVITY, Vector, canvas, rocket, start;

Vector = require('../../src/utils/vector.coffee');

rocket = new Rocket;

rocket.component('canvas', require('../../src/utils/canvas-2d.coffee'));

rocket.key({
  canvas: {
    width: 'auto',
    height: 'auto'
  }
});

canvas = rocket.getData('canvas');

rocket.component('position', Vector["new"]());

rocket.component('velocity', Vector["new"]());

rocket.component('circle', {
  radius: 30,
  color: 'red'
});

rocket.key({
  position: Vector["new"](30, 50),
  velocity: Vector["new"](5, 0),
  circle: null
});

GRAVITY = Vector["new"](0, 1.0);

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



},{"../../src/utils/canvas-2d.coffee":2,"../../src/utils/vector.coffee":3}],2:[function(require,module,exports){

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



},{}],3:[function(require,module,exports){

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