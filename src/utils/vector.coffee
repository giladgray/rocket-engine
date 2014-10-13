###
A static 2-dimensional Vector operations library.

A vector is simply a regular object with keys `{x, y}`. `Vector.new(x, y)` is shorthand for creating
this object, but you can easily do it yourself too.

All vector operations operate on one or two vectors. `equal`, `angle`, `distSq`, and `dist`
return scalar values and leave the vector unchanged. `add`, `sub`, `scale`, and `invert` will
by default mutate the components of the first vector argument and return it. if the final `clone`
argument is set to `true` on these operations then they will return a *new* vector object with
final component values.

All functions on this class are static and the constructor should never be used.

@example
  v1 = Vector.new(10, 20)
  v2 = {x: 1, y: 2}

  # add in place
  v3 = Vector.add(v1, v2)
  # -> v1 == (11, 22); v3 === v1

  # add and clone
  v4 = Vector.add(v1, v2, true)
  # -> v4 == (12, 24); v4 !== v1

@type {Object}
###
module.exports = class Vector
  # @nodoc
  constructor: -> throw new Error('Rectangle: do not use constructor')

  normalize = (num) -> if Math.abs(num) < 1e-10 then 0 else num

  ###
  Create a new Vector. A vector is simply an object with keys `{x,y}`. This method is provided
  as shorthand and allows for default and optional parameters.
  @param x [Number] x coordinate of vector
  @param y [Number] y coordinate of vector
  ###
  @new: (x=0, y=0) -> {x, y}

  ###
  Create a new Vector from polar coordinates `(r,θ)`.
  @param radius [Number] polar radius
  @param angle [Number] polar angle in radians
  @return [Vector] new vector with `{x,y}` coordinates.
  ###
  @fromPolar: (radius, angle) ->
    Vector.new(normalize(radius * Math.cos(angle)), normalize(radius * Math.sin(angle)))

  # Clone a Vector object.
  # @param v [Vector] vector
  # @return [Vector] cloned vector
  @clone: (v)  -> {x: v.x, y: v.y}

  # Returns true if two vectors have the same coordinates.
  # @param v1 [Vector] first vector
  # @param v2 [Vector] second vector
  # @return [Boolean] `true` if both vectors have the same coordinates
  @equal: (v1, v2) -> v1.x is v2.x and v1.y is v2.y

  ###
  Adds two vectors, modifiying the first one and returning the resulting vector.  If `clone=true`
  then `v1` is first cloned and this new Vector with the added components is returned.
  @param v1 [Vector] first vector
  @param v2 [Vector] second vector
  @param clone [Boolean] whether to clone the first vector before modifying components
  @return [Vector] vector with added components
  ###
  @add: (v1, v2, clone=false) ->
    if clone then v1 = Vector.clone(v1)
    v1.x += v2.x
    v1.y += v2.y
    return v1

  ###
  Subtracts two vectors, modifiying the first one and returning the resulting vector.  If
  `clone=true` then `v1` is first cloned and this new Vector with the subtracted components is
  returned.
  @param v1 [Vector] first vector
  @param v2 [Vector] second vector
  @param clone [Boolean] whether to clone the first vector before modifying components
  @return [Vector] vector with subtracted components
  ###
  @sub: (v1, v2, clone=false) ->
    if clone then v1 = Vector.clone(v1)
    v1.x -= v2.x
    v1.y -= v2.y
    return v1

  ###
  Scales a vector by the given factor, modifiying it and returning the resulting vector.  If
  `clone=true` then `v` is first cloned and this new Vector with the scaled components is returned.
  @param v [Vector] vector
  @param factor [Number] amount to scale each component by
  @param clone [Boolean] whether to clone the first vector before modifying components
  @return [Vector] vector with scaled components
  ###
  @scale: (v, factor, clone=false) ->
    if clone then v = Vector.clone(v)
    v.x *= factor
    v.y *= factor
    return v

  ###
  Scales a vector by -1 so it points in the opposite direction, modifiying it and returning the
  resulting vector.  If `clone=true` then `v` is first cloned and this new Vector with the inverted
  components is returned.
  @param v [Vector] vector
  @param clone [Boolean] whether to clone the first vector before modifying components
  @return [Vector] vector with inverted components
  ###
  @invert: (v, clone=false) -> Vector.scale(v, -1, clone)

  # Returns the angle represented by this vector.
  # @param v [Vector] vector
  # @return [Number] angle
  @angle: (v) -> Math.atan2 v.y, v.x

  # Returns the square of the distance (or length) represented by this vector.
  # @param v [Vector] vector
  # @return [Number] square of distance
  @distSq : (v) -> v.x * v.x + v.y * v.y

  # Returns the distance (or length) represented by this vector.
  # @param v [Vector] vector
  # @return [Number] distance
  @dist   : (v) -> Math.sqrt Vector.distSq v
