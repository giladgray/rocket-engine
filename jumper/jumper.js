(function() {
  var BARRIER_DISTANCE, GRAVITY, MOVE, ctx, i, pocket, random, start, _i;

  random = function(min, max) {
    if (max == null) {
      max = min;
      min = 0;
    }
    return Math.floor(Math.random() * (max - min)) + min;
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
      return cmp.height = cmp.canvas.height;
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

  pocket.key({
    'input': null,
    'keyboard-state': {
      keymap: {
        37: 'LEFT',
        39: 'RIGHT'
      }
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

  pocket.component('square', {
    size: 30,
    color: 'cornflowerblue',
    angle: 0
  });

  pocket.component('barrier', {
    height: 30,
    gapWidth: 200,
    x: 0,
    y: 0,
    color: 'cornflowerblue'
  });

  ctx = pocket.getData('context-2d');

  ctx.center = {
    x: ctx.width / 2,
    y: ctx.height / 2
  };

  GRAVITY = 0.4;

  BARRIER_DISTANCE = ctx.height * 3 / 4;

  pocket.key({
    amazing: true,
    square: {
      color: 'black',
      angle: Math.PI / 4
    },
    position: {
      x: ctx.center.x,
      y: ctx.center.y + ctx.height / 4
    },
    velocity: null
  });

  for (i = _i = -1; _i <= 3; i = ++_i) {
    pocket.key({
      evil: true,
      barrier: {
        x: ctx.center.x + random(-150, 150),
        y: 100 - BARRIER_DISTANCE * i
      }
    });
    pocket.key({
      evil: true,
      square: null,
      position: {
        x: ctx.center.x + random(-200, 200),
        y: -BARRIER_DISTANCE * i - ctx.height / 4 * 3
      }
    });
    pocket.key({
      evil: true,
      square: null,
      position: {
        x: ctx.center.x + random(-200, 200),
        y: -BARRIER_DISTANCE * i - ctx.height / 4 * 2
      }
    });
  }

  MOVE = {
    x: 2,
    y: 12
  };

  pocket.systemForEach('input-brick', ['velocity', 'amazing'], function(pocket, key, velocity) {
    var jump, keyboard;
    keyboard = pocket.getData('keyboard-state');
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

  pocket.systemForEach('gravity', ['velocity'], function(pocket, key, vel) {
    return vel.y -= GRAVITY;
  });

  pocket.systemForEach('move', ['position', 'velocity'], function(pocket, key, pos, vel) {
    pos.x += vel.x;
    pos.y -= vel.y;
    return ctx.center.y = Math.min(ctx.center.y, pos.y);
  });

  pocket.systemForEach('bump-barrier', ['barrier', 'evil'], function(pocket, key, barrier) {
    if (barrier.y - BARRIER_DISTANCE * 2 > ctx.center.y) {
      barrier.y = ctx.center.y - BARRIER_DISTANCE * 2;
      return barrier.x = ctx.center.x + random(-150, 150);
    }
  });

  pocket.systemForEach('bump-square', ['position', 'square', 'evil'], function(pocket, key, pos) {
    if (pos.y - BARRIER_DISTANCE * 2 > ctx.center.y) {
      pos.y = ctx.center.y - BARRIER_DISTANCE * 2;
      return pos.x = ctx.center.x + random(-200, 200);
    }
  });

  pocket.system('clear-canvas', [], function(pocket) {
    return ctx.g2d.clearRect(0, 0, ctx.width, ctx.height);
  });

  pocket.systemForEach('draw-square', ['position', 'square'], function(pocket, key, pos, square) {
    var center, g2d, width;
    g2d = ctx.g2d, center = ctx.center, width = ctx.width;
    g2d.save();
    g2d.beginPath();
    g2d.translate(pos.x, pos.y - center.y + width / 3);
    g2d.rotate(square.angle);
    g2d.fillStyle = square.color;
    g2d.rect(0, 0, square.size, square.size);
    g2d.closePath();
    g2d.fill();
    return g2d.restore();
  });

  pocket.systemForEach('draw-barrier', ['barrier'], function(pocket, key, barrier) {
    var center, g2d, width;
    g2d = ctx.g2d, width = ctx.width, center = ctx.center;
    g2d.save();
    g2d.beginPath();
    g2d.translate(0, barrier.y - center.y);
    g2d.fillStyle = barrier.color;
    g2d.rect(0, 0, barrier.x, barrier.height);
    g2d.rect(barrier.x + barrier.gapWidth, 0, width - barrier.gapWidth, barrier.height);
    g2d.closePath();
    g2d.fill();
    return g2d.restore();
  });

  start = function(time) {
    pocket.tick(time);
    return window.requestAnimationFrame(start);
  };

  document.addEventListener('DOMContentLoaded', function() {
    return start();
  });

}).call(this);
