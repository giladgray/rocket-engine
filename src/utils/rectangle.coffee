###
A static Rectangle operations library.

A rectangle is simply an object with keys `{x, y, width, height}`.
`Rectangle.new(x, y, width, height)` is shorthand for creating this object, but you can easily
do it yourself too. `Rectangle.new(x, y, size)` will create a square where `width == height`.

All functions on this class are static and the constructor should never be used.

@example
  r1 = Rectangle.new(1, 2, 3, 4)
  r2 = Rectangle.centered(1, 1, 4)
  r3 = {x: -1, y: -1, width: 4, height: 4}

  Rectangle.equal(r2, r3)   # -> true
  Rectangle.overlap(r1, r2) # -> true
###
module.exports = class Rectangle
  # @nodoc
  constructor: -> throw new Error('Rectangle: do not use constructor')

  ###
  @overload .new(x, y, width, height)
    Create a new Rectangle. A rectangle is simply an object with keys `{x,y,width,height}`. This
    method is provided to easily define these objects in a standard way, and to provide square
    shorthand by omitting `height` parameter.
    @param x      [Number] x coordinate of upper-left corner
    @param y      [Number] y coordinate of upper-left corner
    @param width  [Number] width of rectangle
    @param height [Number] height of rectangle
    @return [Rectangle] new rectangle

  @overload .new(x, y, size)
    Create a new square Rectangle.
    @param x    [Number] x coordinate of upper-left corner
    @param y    [Number] y coordinate of upper-left corner
    @param size [Number] width and height of rectangle
    @return [Rectangle] new square rectangle
  ###
  @new: (x=0, y=0, width=0, height) ->
    height ?= width
    {x, y, width, height}

  # Clone a Rectangle object.
  # @param rect [Rectangle] rectangle to clone
  # @return [Rectangle] new Rectangle with identical dimensions
  @clone: (rect)  -> {x: rect.x, y: rect.y, width: rect.width, height: rect.height}

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
    r1.x is r2.x and r1.y is r2.y and r1.width is r2.width and r2.height is r2.height

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
    if r1.x > r2.x + r2.width or r1.x + r1.width < r2.x
      xOverlap = false
    if r1.y > r2.y + r2.height or r1.y + r1.height < r2.y
      yOverlap = false
    return xOverlap and yOverlap
