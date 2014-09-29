(function() {
  var GRAVITY, colors, countElem, curColor, i, nextColor, numBalls, pocket, random, randomBall, start, updateCount, _i;

  random = function(min, max) {
    if (max == null) {
      max = min;
      min = 0;
    }
    return Math.floor(Math.random() * (max - min)) + min;
  };

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

  pocket = new Pocket;

  pocket.component('context-2d', function(cmp, _arg) {
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
      cmp.height = cmp.canvas.height;
      cmp.center.x = cmp.canvas.width / 2;
      return cmp.center.y = cmp.canvas.height / 2;
    });
    return resize();
  });

  pocket.key({
    'context-2d': null
  });

  pocket.component('keyboard-state', function(cmp, _arg) {
    var keymap, target;
    target = _arg.target, keymap = _arg.keymap;
    cmp.target = target || document;
    cmp.down = {};
    cmp.isNewPress = function(keyName, recency) {
      var delta, downTime;
      if (recency == null) {
        recency = 16;
      }
      downTime = cmp.down[keyName];
      delta = Date.now() - downTime;
      return downTime && (0 < delta && delta < recency);
    };
    cmp.target.addEventListener('keydown', function(e) {
      var keyName;
      keyName = keymap[e.which];
      cmp.down[e.which] = true;
      if (keyName && !cmp.down[keyName]) {
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

  pocket.key({
    'input': null,
    'keyboard-state': {
      keymap: {
        13: 'ADD',
        32: 'DESTROY'
      }
    }
  });

  pocket.systemForEach('input-balls', ['keyboard-state'], function(pocket, key, keyboard) {
    if (keyboard.isNewPress('DESTROY')) {
      pocket.destroyKeys(pocket.filterKeys('ball'));
      updateCount(0);
    }
    if (keyboard.isNewPress('ADD')) {
      return randomBall();
    }
  });

  pocket.component('position', {
    x: 0,
    y: 0
  });

  pocket.component('velocity', {
    x: 0,
    y: 0
  });

  pocket.component('circle', {
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
    var height, radius, width, _ref;
    updateCount(1);
    _ref = pocket.getData('context-2d'), width = _ref.width, height = _ref.height;
    radius = random(20, 100);
    return pocket.key({
      ball: true,
      position: {
        x: random(radius, width - radius),
        y: random(radius, height / 2 - radius)
      },
      velocity: {
        x: random(-8, 8),
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

  GRAVITY = 0.5;

  pocket.systemForEach('gravity', ['velocity'], function(pocket, key, vel) {
    return vel.y += GRAVITY;
  });

  pocket.systemForEach('move', ['position', 'velocity'], function(pocket, key, pos, vel) {
    pos.x += vel.x;
    return pos.y += vel.y;
  });

  pocket.system('clear-canvas', [], function(pocket) {
    var g2d, height, width, _ref;
    _ref = pocket.getData('context-2d'), g2d = _ref.g2d, width = _ref.width, height = _ref.height;
    return g2d.clearRect(0, 0, width, height);
  });

  pocket.systemForEach('draw-ball', ['position', 'circle'], function(pocket, key, pos, circle) {
    var g2d;
    g2d = pocket.getData('context-2d').g2d;
    g2d.beginPath();
    g2d.fillStyle = circle.color;
    g2d.arc(pos.x, pos.y, circle.radius, 0, Math.PI * 2);
    g2d.closePath();
    return g2d.fill();
  });

  pocket.systemForEach('bounce', ['position', 'velocity', 'circle'], function(pkt, key, pos, vel, _arg) {
    var height, radius, width, _ref;
    radius = _arg.radius;
    _ref = pkt.getData('context-2d'), width = _ref.width, height = _ref.height;
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
    pocket.tick(time);
    return window.requestAnimationFrame(start);
  };

  document.addEventListener('DOMContentLoaded', function() {
    return start();
  });

}).call(this);
