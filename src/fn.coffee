###
A mindblowingly simple functional toolbelt. Sound familiar_?

@method .uniqueId(prefix)
  Generate a unique identifier with an optional prefix.
  @param prefix [String] optional value to prepend to identifier
  @return [String] unique identifier

@method .isNumber(arg)
  Returns `true` if arg is a Number
  @param arg [*] any value
  @return [Boolean] `true` if arg is a Number

@method .isString(arg)
  Returns `true` if arg is a String
  @param arg [*] any value
  @return [Boolean] `true` if arg is a String

@method .isBoolean(arg)
  Returns `true` if arg is a Boolean
  @param arg [*] any value
  @return [Boolean] `true` if arg is a Boolean

@method .isArray(arg)
  Returns `true` if arg is an Array
  @param arg [*] any value
  @return [Boolean] `true` if arg is an Array

@method .isObject(arg)
  Returns `true` if arg is an Object
  @param arg [*] any value
  @return [Boolean] `true` if arg is an Object

@method .isFunction(arg)
  Returns `true` if arg is a Function
  @param arg [*] any value
  @return [Boolean] `true` if arg is a Function
###
class Fn

  ###
  Generate a unique identifier with an optional prefix.
  @param prefix [String] optional value to prefix returned identifier
  @return [String] unique identifier
  ###
  @uniqueId: (->
    nextId = 0 # hide counter in IIFE
    return (prefix='') -> prefix + (nextId++)
  )()

  objectTypes = {}
  # The method given in the ECMAScript standard to find the class of
  # Object is to use the toString method from Object.prototype.
  # Object::toString.call -> [object Type]
  for type in ['Number', 'String', 'Boolean', 'Object', 'Array', 'Function']
    objectTypes[type] = "[object #{type}]"
    do (type) ->
      Fn["is#{type}"] = (val) ->
        Object::toString.call(val) is objectTypes[type]

  ###
  Flattens a nested array (the nesting can be to any depth). Accepts a single array or splat of
  mixed types.
  @param arrays [Array...] a single array of splat of values to flatten
  @return [Array] a single flattened array
  ###
  @flatten: ->
    # base case: one non-array argument. otherwise, recursively flatten that array
    if arguments.length is 1
      arg = arguments[0]
      return if Fn.isArray arg then Fn.flatten.apply(null, arg) else [arg]
    flattened = []
    for arg in arguments
      # recursively flatten arrays
      if Fn.isArray arg then flattened.push Fn.flatten(arg...)...
      else flattened.push arg
    return flattened

  ###
  Recursively merges own enumerable properties of source objects into destination object.
  Subsequent sources will overwrite property assignments of previous sources.
  @param object [Object] destination object to merge properties into.
  @param sources [Object...] splat of source objects
  @return [Object] destination object with merged properties
  ###
  @merge: (object, sources...) ->
    for source in sources
      for own key, val of source
        if Fn.isObject(val)
          # recursively merge own enumerable properties
          object[key] = Fn.merge object[key] ? {}, val
        else
          object[key] = val
    return object

  ###
  Creates a new object with the same properties as the given object.
  @param object [Object] object to clone
  @return [Object] a clone of the given object
  ###
  @clone: (object) -> Fn.merge {}, object

  ###
  Assigns own enumerable properties of source object(s) to the destination object for all
  destination properties that resolve to undefined. Once a property is set, additional defaults of
  the same property will be ignored.
  @param object [Object] destination object to merge properties into.
  @param sources [Object...] splat of source objects
  @return [Object] destination object with merged properties
  ###
  @defaults: (object, sources...) ->
    for source in sources
      for own key, val of source when object[key] is undefined
        object[key] = val
    return object

  ###
  Retrieves the value of a specified property from all elements in the array.
  @param collection [Array] array of elements
  @param property [String] property name to pluck
  @return [Array] array of values for given property
  ###
  @pluck: (collection, property) -> item[property] for item in collection

module.exports = Fn
