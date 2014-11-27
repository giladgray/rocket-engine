(function e(t,n,r){function s(o,u){if(!n[o]){if(!t[o]){var a=typeof require=="function"&&require;if(!u&&a)return a(o,!0);if(i)return i(o,!0);var f=new Error("Cannot find module '"+o+"'");throw f.code="MODULE_NOT_FOUND",f}var l=n[o]={exports:{}};t[o][0].call(l.exports,function(e){var n=t[o][1][e];return s(n?n:e)},l,l.exports,e,t,n,r)}return n[o].exports}var i=typeof require=="function"&&require;for(var o=0;o<r.length;o++)s(r[o]);return s})({1:[function(require,module,exports){
var BARRIER_DISTANCE, BARRIER_WIDTH, GRAVITY, MOVE, addLevel, bestScore, ctx, highscoreEl, i, lastBarrierX, level, random, rectangle, rocket, score, scoreEl, scoreOne, scoreZero, start, _i,
  __slice = [].slice;

random = function(min, max) {
  if (max == null) {
    max = min;
    min = 0;
  }
  return Math.floor(Math.random() * (max - min)) + min;
};

rectangle = function() {
  var rect1;
  rect1 = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
  return {
    overlaps: function() {
      var rect2, xOverlap, yOverlap;
      rect2 = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
      xOverlap = yOverlap = true;
      if (rect1[0] > rect2[0] + rect2[2] || rect1[0] + rect1[2] < rect2[0]) {
        xOverlap = false;
      }
      if (rect1[1] > rect2[1] + rect2[3] || rect1[1] + rect1[3] < rect2[1]) {
        yOverlap = false;
      }
      return xOverlap && yOverlap;
    }
  };
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
  'context-2d': null
});

rocket.component('keyboard-state', function(cmp, _arg) {
  var keymap, target;
  target = _arg.target, keymap = _arg.keymap;
  cmp.target = target || document;
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
});

rocket.key({
  'input': null,
  'keyboard-state': {
    keymap: {
      37: 'LEFT',
      39: 'RIGHT'
    }
  }
});

ctx = rocket.getData('context-2d');

ctx.center = {
  x: ctx.width / 2,
  y: ctx.height / 2
};

GRAVITY = 0.4;

BARRIER_DISTANCE = ctx.height * 3 / 4;

BARRIER_WIDTH = 200;

rocket.component('position', {
  x: 0,
  y: 0
});

rocket.component('velocity', {
  x: 0,
  y: 0
});

rocket.component('square', {
  size: 30,
  color: 'cornflowerblue',
  angle: 0
});

rocket.component('barrier', {
  height: 50,
  gapWidth: BARRIER_WIDTH,
  x: 0,
  y: 0,
  color: 'cornflowerblue'
});

rocket.player = rocket.key({
  amazing: true,
  square: {
    color: 'black',
    angle: Math.PI / 4,
    size: 20
  },
  position: {
    x: ctx.center.x,
    y: ctx.center.y + ctx.height / 4
  },
  velocity: null
});

level = -1;

lastBarrierX = ctx.center.x;

addLevel = function() {
  var barrier, squareX;
  barrier = {
    x: ctx.center.x + random(-150, 150),
    y: 100 - BARRIER_DISTANCE * level++
  };
  squareX = (barrier.x + lastBarrierX) / 2 + BARRIER_WIDTH / 2;
  rocket.key({
    evil: true,
    barrier: barrier
  });
  rocket.key({
    evil: true,
    square: null,
    position: {
      x: squareX + random(-BARRIER_WIDTH / 2, BARRIER_WIDTH / 2),
      y: barrier.y - BARRIER_DISTANCE * 2 / 3
    }
  });
  rocket.key({
    evil: true,
    square: null,
    position: {
      x: squareX + random(-BARRIER_WIDTH / 2, BARRIER_WIDTH / 2),
      y: barrier.y - BARRIER_DISTANCE / 3
    }
  });
  return lastBarrierX = barrier.x;
};

for (i = _i = 1; _i <= 3; i = ++_i) {
  addLevel();
}

score = 0;

bestScore = 0;

scoreEl = document.querySelector('.scores .current');

highscoreEl = document.querySelector('.scores .best');

scoreOne = function() {
  return scoreEl.textContent = ++score;
};

scoreZero = function() {
  if (score > bestScore) {
    highscoreEl.textContent = bestScore = score;
  }
  return scoreEl.textContent = score = 0;
};

rocket.system('level-barrier', ['barrier', 'evil'], function(rocket, keys, barriers) {
  var barrier, key, pPos, pSq, playerRect, _j, _len, _results;
  pPos = rocket.dataFor(rocket.player, 'position');
  pSq = rocket.dataFor(rocket.player, 'square');
  playerRect = rectangle(pPos.x, pPos.y + ctx.width / 3, pSq.size, pSq.size);
  _results = [];
  for (_j = 0, _len = keys.length; _j < _len; _j++) {
    key = keys[_j];
    barrier = barriers[key];
    if (barrier.marked != null) {
      continue;
    }
    if (playerRect.overlaps(0, barrier.y, ctx.width, barrier.height)) {
      barrier.color = 'red';
      barrier.marked = false;
    }
    if (playerRect.overlaps(barrier.x, barrier.y, barrier.gapWidth, barrier.height)) {
      barrier.color = 'green';
      barrier.marked = true;
      scoreOne();
    }
    if (barrier.marked === false) {
      _results.push(scoreZero());
    } else {
      _results.push(void 0);
    }
  }
  return _results;
});

rocket.system('square-smash', ['position', 'square', 'evil'], function(rocket, keys, positions, squares) {
  var key, pPos, pSq, playerRect, position, square, _j, _len, _results;
  pPos = rocket.dataFor(rocket.player, 'position');
  pSq = rocket.dataFor(rocket.player, 'square');
  playerRect = rectangle(pPos.x, pPos.y + ctx.width / 3, pSq.size, pSq.size);
  _results = [];
  for (_j = 0, _len = keys.length; _j < _len; _j++) {
    key = keys[_j];
    position = positions[key];
    square = squares[key];
    if (square.marked) {
      continue;
    }
    if (playerRect.overlaps(position.x, position.y, square.size, square.size)) {
      square.color = 'red';
      square.marked = true;
      _results.push(scoreZero());
    } else {
      _results.push(void 0);
    }
  }
  return _results;
});

MOVE = {
  x: 2,
  y: 12
};

rocket.systemForEach('input-brick', ['velocity', 'amazing'], function(rocket, key, velocity) {
  var jump, keyboard;
  keyboard = rocket.getData('keyboard-state');
  jump = 0;
  if (keyboard.isNewPress('LEFT')) {
    jump = -MOVE.x;
  }
  if (keyboard.isNewPress('RIGHT')) {
    jump = MOVE.x;
  }
  if (jump) {
    velocity.x = jump;
    return velocity.y = MOVE.y;
  }
});

rocket.systemForEach('gravity', ['velocity'], function(rocket, key, vel) {
  return vel.y -= GRAVITY;
});

rocket.systemForEach('move', ['position', 'velocity'], function(rocket, key, pos, vel) {
  pos.x += vel.x;
  pos.y -= vel.y;
  return ctx.center.y = Math.min(ctx.center.y, pos.y);
});

rocket.systemForEach('destroy-barrier', ['barrier', 'evil'], function(rocket, key, barrier) {
  if (barrier.y - BARRIER_DISTANCE * 2 > ctx.center.y) {
    rocket.destroyKey(key);
    return addLevel();
  }
});

rocket.systemForEach('destroy-square', ['position', 'evil'], function(rocket, key, pos) {
  if (pos.y - BARRIER_DISTANCE * 2 > ctx.center.y) {
    return rocket.destroyKey(key);
  }
});

rocket.system('clear-canvas', [], function(rocket) {
  return ctx.g2d.clearRect(0, 0, ctx.width, ctx.height);
});

rocket.systemForEach('draw-square', ['position', 'square'], function(rocket, key, pos, square) {
  var center, g2d, isAmazing, width;
  isAmazing = rocket.dataFor(key, 'amazing');
  g2d = ctx.g2d, center = ctx.center, width = ctx.width;
  g2d.save();
  g2d.beginPath();
  g2d.translate(pos.x, pos.y - center.y + (isAmazing ? width / 3 : 0));
  g2d.rotate(square.angle);
  g2d.fillStyle = square.color;
  g2d.rect(0, 0, square.size, square.size);
  g2d.closePath();
  g2d.fill();
  return g2d.restore();
});

rocket.systemForEach('draw-barrier', ['barrier'], function(rocket, key, barrier) {
  var center, g2d, width;
  g2d = ctx.g2d, width = ctx.width, center = ctx.center;
  g2d.save();
  g2d.beginPath();
  g2d.translate(0, barrier.y - center.y);
  g2d.fillStyle = barrier.color;
  g2d.rect(0, 0, barrier.x, barrier.height);
  g2d.rect(barrier.x + barrier.gapWidth, 0, width - barrier.gapWidth, barrier.height);
  g2d.fill();
  g2d.closePath();
  return g2d.restore();
});

start = function(time) {
  rocket.tick(time);
  return window.requestAnimationFrame(start);
};

document.addEventListener('DOMContentLoaded', function() {
  return start();
});



},{}]},{},[1]);
