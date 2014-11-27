(function e(t,n,r){function s(o,u){if(!n[o]){if(!t[o]){var a=typeof require=="function"&&require;if(!u&&a)return a(o,!0);if(i)return i(o,!0);var f=new Error("Cannot find module '"+o+"'");throw f.code="MODULE_NOT_FOUND",f}var l=n[o]={exports:{}};t[o][0].call(l.exports,function(e){var n=t[o][1][e];return s(n?n:e)},l,l.exports,e,t,n,r)}return n[o].exports}var i=typeof require=="function"&&require;for(var o=0;o<r.length;o++)s(r[o]);return s})({1:[function(require,module,exports){
var MAX_FUEL, bestScore, canvas, distance, highscoreEl, mouse, mouseFuel, newBall, random, rocket, score, scoreEl, scoreOne, scoreZero, start;

random = function(min, max) {
  if (max == null) {
    max = min;
    min = 0;
  }
  return Math.floor(Math.random() * (max - min)) + min;
};

distance = function(a, b) {
  var dx, dy;
  dx = a.x - b.x;
  dy = a.y - b.y;
  return Math.sqrt(dx * dx + dy * dy);
};

rocket = new Rocket;

rocket.component('context-2d', function(cmp, _arg) {
  var canvas, resize;
  canvas = _arg.canvas;
  cmp.canvas = document.querySelector(canvas || '#canvas');
  cmp.g2d = cmp.canvas.getContext('2d');
  cmp.center = {
    x: 0,
    y: 0
  };
  window.addEventListener('resize', resize = function() {
    cmp.canvas.width = document.body.clientWidth;
    cmp.canvas.height = document.body.clientHeight;
    cmp.width = cmp.canvas.width;
    return cmp.height = cmp.canvas.height;
  });
  return resize();
});

rocket.key({
  'context-2d': {
    width: 'auto',
    height: 'auto'
  }
});

canvas = rocket.getData('context-2d');

rocket.component('mouse-state', function(cmp, _arg) {
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
});

rocket.key({
  'mouse-state': null
});

mouse = rocket.getData('mouse-state');

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
  color: 'cornflowerblue'
});

MAX_FUEL = 5000;

mouseFuel = 0;

newBall = function() {
  mouseFuel = MAX_FUEL;
  return rocket.key({
    position: {
      x: random(canvas.width),
      y: random(canvas.height)
    },
    velocity: {
      speed: 0
    },
    circle: null
  });
};

newBall();

rocket.systemForEach('move-ball', ['position', 'velocity'], function(rocket, key, pos, vel) {
  var angle;
  if (!mouse.inWindow) {
    return;
  }
  angle = Math.atan2(mouse.cursor.y - pos.y, mouse.cursor.x - pos.x);
  vel.x = vel.speed * Math.cos(angle);
  vel.y = vel.speed * Math.sin(angle);
  if (mouse.buttons.left && mouseFuel > 0) {
    vel.x *= -1 / 4;
    vel.y *= -1 / 4;
    mouseFuel -= rocket.delta;
  } else {
    vel.speed += 1 / 20;
    mouseFuel += rocket.delta / 3;
    mouseFuel = Math.min(mouseFuel, MAX_FUEL);
  }
  pos.x += vel.x;
  return pos.y += vel.y;
});

rocket.systemForEach('respawn-ball', ['position', 'circle'], function(rocket, key, pos, _arg) {
  var radius;
  radius = _arg.radius;
  if (distance(mouse.cursor, pos) < radius) {
    rocket.destroyKey(key);
    scoreZero();
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

score = 0;

bestScore = 0;

scoreEl = document.querySelector('.scores .current');

highscoreEl = document.querySelector('.scores .best');

scoreOne = function(amt) {
  if (amt == null) {
    amt = 1;
  }
  return scoreEl.textContent = score += amt;
};

scoreZero = function() {
  if (score > bestScore) {
    highscoreEl.textContent = bestScore = score;
  }
  return scoreEl.textContent = score = 0;
};

rocket.system('update-score', [], function(rocket) {
  if (!mouse.inWindow) {
    return;
  }
  return scoreOne(Math.floor(rocket.delta || 0));
});

start = function(time) {
  rocket.tick(time);
  return window.requestAnimationFrame(start);
};

document.addEventListener('DOMContentLoaded', function() {
  return start();
});



},{}]},{},[1]);
