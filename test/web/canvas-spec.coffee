chai = require 'chai'
expect = chai.expect

# THIS TEST ONLY WORKS IN THE BROWSER
return unless document?

document.body.appendChild document.createElement('canvas')

Rocket = require '../../src/rocket.coffee'
Canvas2D = require '../../src/utils/canvas-2d.coffee'

describe 'Canvas2D', ->
  rocket = null
  canvas = null

  makeCanvas = (options = null) ->
    rocket = new Rocket
    rocket.component 'canvas-2d', Canvas2D
    rocket.key {'canvas-2d': options}
    canvas = rocket.getData 'canvas-2d'
    return canvas

  beforeEach ->
    makeCanvas()

  it 'can be loaded as component data via getData', ->
    expect(canvas).to.exist

  it 'has a canvas element and rendering context and camera', ->
    expect(canvas.canvas).to.be.instanceof HTMLElement
    expect(canvas.g2d).to.be.instanceof CanvasRenderingContext2D
    expect(canvas.camera).to.exist

  describe 'dimensions options', ->
    it 'exact width can be passed as option', ->
      canvas = makeCanvas
        width: 300
      expect(canvas.width).to.equal 300

    it 'exact height can be passed as option', ->
      canvas = makeCanvas
        height: 500
      expect(canvas.height).to.equal 500

    it 'auto width can be passed as option', ->
      canvas = makeCanvas
        width: 'auto'
      expect(canvas.width).to.equal document.body.clientWidth

    it 'auto height can be passed as option', ->
      canvas = makeCanvas
        height: 'auto'
      expect(canvas.height).to.equal document.body.clientHeight
