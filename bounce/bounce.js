(function() {
  var GRAVITY, pocket, start;

  pocket = new Pocket;

  pocket.component('context-2d', function(cmp, options) {
    var resize;
    cmp.canvas = document.querySelector(options.canvas || '#canvas');
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

  pocket.key({
    position: {
      x: 30,
      y: 50
    },
    velocity: {
      x: 5,
      y: 0
    },
    circle: null
  });

  GRAVITY = 1.0;

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
