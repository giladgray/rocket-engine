###
A static Rectangle operations library.

A rectangle is simply an object with keys `{left, top, width, height}`.
`Rectangle.new(left, top, width, height)` is shorthand for creating this object, but you can easily
do it yourself too. `Rectangle.new(left, top, size)` will create a square where
`size == width == height`.

All functions on this class are static and the constructor should never be used.

@example
  r1 = Rectangle.new(1, 2, 3, 4)
  r2 = Rectangle.centered(1, 1, 4)
  r3 = {left: -1, top: -1, width: 4, height: 4}

  Rectangle.equal(r2, r3)   # -> true
  Rectangle.overlap(r1, r2) # -> true
###
module.exports = class Rectangle
  # @nodoc
  constructor: -> throw new Error('Rectangle: do not use constructor')

  ###
  @overload .new(left, top, width, height)
    Create a new Rectangle. A rectangle is simply an object with keys `{left,top,width,height}`.
    This method is provided to easily define these objects in a standard way, and to provide square
    shorthand by omitting `height` parameter.
    @param left   [Number] left coordinate of upper-left corner
    @param top    [Number] top coordinate of upper-left corner
    @param width  [Number] width of rectangle
    @param height [Number] height of rectangle
    @return [Rectangle] new rectangle

  @overload .new(left, top, size)
    Create a new square Rectangle.
    @param left [Number] left coordinate of upper-left corner
    @param top  [Number] top coordinate of upper-left corner
    @param size [Number] width and height of rectangle
    @return [Rectangle] new square rectangle
  ###
  @new: (left=0, top=0, width=0, height) ->
    height ?= width
    {left, top, width, height}

  # Clone a Rectangle object.
  # @param rect [Rectangle] rectangle to clone
  # @return [Rectangle] new Rectangle with identical dimensions
  @clone: (rect)  -> {left: rect.left, top: rect.top, width: rect.width, height: rect.height}

  ###
  Creates a new Rectangle *centered* at (x,y).
  @param x      [Number] x coordinate of rectangle center
  @param y      [Number] y coordinate of rectangel center
  @param width  [Number] width of rectangle
  @param height [Number] height of rectangle
  @return [Rectangle] rectangle centered at (x,y)
  ###
  @centered: (x=0, y=0, width=0, height) ->
    height ?= width
    Rectangle.new(x - width / 2, y - height / 2, width, height)

  # Returns `true` if two rectangles have the same properties.
  # @param r1 [Rectangle] first rectangle
  # @param r2 [Rectangle] second rectangle
  # @return [Boolean] `true` if two rectangles have the same properties.
  @equal: (r1, r2) ->
    r1.left is r2.left and r1.top is r2.top and r1.width is r2.width and r2.height is r2.height

  # Returns the area of a rectangle, `width * height`.
  # @param r [Rectangle] rectangle
  # @return [Number] area
  @area: (r) -> r.width * r.height

  # Returns `true` if two rectangles overlap on any side. Also returns `true` if one rectangle is
  # wholly contained in the other.
  # @param r1 [Rectangle] first rectangle
  # @param r2 [Rectangle] second rectangle
  # @return [Boolean] `true` if two rectangles overlap on any side
  @overlap: (r1, r2) ->
    xOverlap = yOverlap = true
    if r1.left > r2.left + r2.width or r1.left + r1.width < r2.left
      xOverlap = false
    if r1.top > r2.top + r2.height or r1.top + r1.height < r2.top
      yOverlap = false
    return xOverlap and yOverlap
