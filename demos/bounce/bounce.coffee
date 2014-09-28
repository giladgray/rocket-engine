console.log 'hello from coffee!'

pocket = new Pocket

pocket.component 'context-2d', (cmp, options) ->
  cmp.canvas = document.querySelector options.canvas or '#canvas'
  cmp.g2d = cmp.canvas.getContext('2d')
  cmp.center = {x: 0, y: 0}

  # ensure canvas is as large as possible
  window.addEventListener "resize", resize = ->
    cmp.canvas.width = document.body.clientWidth
    cmp.canvas.height = document.body.clientHeight
    cmp.width = cmp.canvas.width
    cmp.height = cmp.canvas.height
    cmp.center.x = cmp.canvas.width / 2
    cmp.center.y = cmp.canvas.height / 2
  resize()

pocket.key {'context-2d': null}
