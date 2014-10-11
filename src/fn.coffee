###*
 * A mindblowingly simple functional toolbelt. Sound familiar_?
###
fn = {}

###*
 * Generate a unique identifier with an optional prefix.
 * @param prefix [String] optional value to prefix returned identifier
 * @return [String] unique identifier
###
fn.uniqueId = (->
  nextId = 0 # hide counter in IIFE
  return (prefix='') -> prefix + (nextId++)
)()

# The method given in the ECMAScript standard to find the class of
# Object is to use the toString method from Object.prototype.
# Object::toString.call -> [object Type]
for type in ['Number', 'String', 'Boolean', 'Object', 'Array', 'Function']
  do (type) ->
    fn["is#{type[0].toUpperCase()}#{type[1..]}"] = (val) ->
      Object::toString.call(val) is "[object #{type}]"

###*
 * Flattens a nested array (the nesting can be to any depth). Accepts a single array or splat of
 * mixed types.
 * @param arrays [Array...] a single array of splat of values to flatten
 * @return [Array] a single flattened array
###
fn.flatten = ->
  # base case: one non-array argument. otherwise, recursively flatten that array
  if arguments.length is 1
    arg = arguments[0]
    return if fn.isArray arg then fn.flatten.apply(null, arg) else [arg]
  flattened = []
  for arg in arguments
    # recursively flatten arrays
    if fn.isArray arg then flattened.push fn.flatten(arg...)...
    else flattened.push arg
  return flattened

###*
 * Recursively merges own enumerable properties of source objects into destination object.
 * Subsequent sources will overwrite property assignments of previous sources.
 * @param object [Object] destination object to merge properties into.
 * @param sources [Object...] splat of source objects
 * @return [Object] destination object with merged properties
###
fn.merge = (object, sources...) ->
  for source in sources
    for own key, val of source
      if fn.isObject(val)
        # recursively merge own enumerable properties
        object[key] = fn.merge object[key] ? {}, val
      else
        object[key] = val
  return object

###*
 * Creates a new object with the same properties as the given object.
 * @param object [Object] object to clone
 * @return [Object] a clone of the given object
###
fn.clone = (object) -> fn.merge {}, object

###*
 * Assigns own enumerable properties of source object(s) to the destination object for all
 * destination properties that resolve to undefined. Once a property is set, additional defaults of
 * the same property will be ignored.
 * @param object [Object] destination object to merge properties into.
 * @param sources [Object...] splat of source objects
 * @return [Object] destination object with merged properties
###
fn.defaults = (object, sources...) ->
  for source in sources
    for own key, val of source when object[key] is undefined
      object[key] = val
  return object

###*
 * Retrieves the value of a specified property from all elements in the array.
 * @param collection [Array] array of elements
 * @param property [String] property name to pluck
 * @return [Array] array of values for given property
###
fn.pluck = (collection, property) -> item[property] for item in collection

module.exports = fn
