###*
 * A static 2-dimensional Vector operations library.
 *
 * A vector is simply an object with keys `{x, y}`. `Vector2.new(x, y)` is shorthand for creating
 * this object, but you can easily do it yourself too.
 *
 * All vector operations operate on one or two vectors. `equal`, `angle`, `lengthSq`, and `length`
 * return scalar values and leave the vector unchanged. `add`, `sub`, `scale`, and `invert` will
 * by default update the components of the first vector argument and return it. if the final `clone`
 * argument is set to `true` on these operations then they will return a *new* vector object with
 * final component values.
 *
 * @example
 * 	 v1 = Vector2.new(10, 20)
 * 	 v2 = {x: 1, y: 2}
 *
 * 	 # add in place
 * 	 v3 = Vector2.add(v1, v2)
 * 	 # -> v1 == (11, 22); v3 === v1
 *
 * 	 # add and clone
 * 	 v4 = Vector2.add(v1, v2, true)
 * 	 # -> v4 == (12, 24); v4 !== v1
 *
 * @type {Object}
###
module.exports = Vector2 =
  new: (x=0, y=0) -> {x, y}
  clone: (v)  -> {x: v.x, y: v.y}
  fromPolar: (radius, angle) ->
    normalize = (num) -> if Math.abs(num) < 1e-10 then 0 else num
    Vector2.new(normalize(radius * Math.cos(angle)), normalize(radius * Math.sin(angle)))

  equal: (v1, v2) -> v1.x is v2.x and v1.y is v2.y

  add: (v1, v2, clone=false) ->
    if clone then v1 = Vector2.clone(v1)
    v1.x += v2.x
    v1.y += v2.y
    return v1

  sub: (v1, v2, clone=false) ->
    if clone then v1 = Vector2.clone(v1)
    v1.x -= v2.x
    v1.y -= v2.y
    return v1

  scale: (v, factor, clone=false) ->
    if clone then v = Vector2.clone(v)
    v.x *= factor
    v.y *= factor
    return v

  invert: (v, clone=false) -> Vector2.scale(v, -1, clone)

  angle: (v) -> Math.atan2 v.y, v.x

  lengthSq : (v) -> v.x * v.x + v.y * v.y
  length   : (v) -> Math.sqrt Vector2.lengthSq v
