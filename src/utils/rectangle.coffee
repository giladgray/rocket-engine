###*
 * A static Rectangle operations library.
 *
 * A rectangle is simply an object with keys `{x, y, width, height}`.
 * `Rectangle.new(x, y, width, height)` is shorthand for creating this object, but you can easily
 * do it yourself too. `Rectangle.new(x, y, width)` will create a square where `width == height`.
 *
 * @example
 * 	 r1 = Rectangle.new(1, 2, 3, 4)
 * 	 r2 = Rectangle.centered(1, 1, 4)
 * 	 r3 = {x: -1, y: -1, width: 4, height: 4}
 *
 * 	 Rectangle.equal(r2, r3)   # -> true
 *   Rectangle.overlap(r1, r2) # -> true
 *
 * @type {Object}
###
module.exports = Rectangle =
  new: (x=0, y=0, width=0, height) ->
    height ?= width
    {x, y, width, height}
  clone: (rect)  -> {x: rect.x, y: rect.y, width: rect.width, height: rect.height}
  centered: (x=0, y=0, width=0, height) ->
    height ?= width
    Rectangle.new(x - width / 2, y - height / 2, width, height)

  equal: (r1, r2) ->
    r1.x is r2.x and r1.y is r2.y and r1.width is r2.width and r2.height is r2.height

  area: (r) -> r.width * r.height

  overlap: (r1, r2) ->
    xOverlap = yOverlap = true
    if r1.x > r2.x + r2.width or r1.x + r1.width < r2.x
      xOverlap = false
    if r1.y > r2.y + r2.height or r1.y + r1.height < r2.y
      yOverlap = false
    return xOverlap and yOverlap
