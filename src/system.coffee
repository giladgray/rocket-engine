_ = require './fn.coffee'

###
###
module.exports = class System
  ###
  Create a new System. All three parameters are required. The `action` function will be bound
  to run in the context of the System instance.
  @param {String}        name               name of the system
  @param {Array<String>} requiredComponents array of required component names
  @param {Function}      action             system action function invoked with
    `(rocket, keys, cValues1, ..., cValuesN)`
  ###
  constructor: (@name, @requiredComponents, action) ->
    throw new Error('System requires String name')              unless _.isString @name
    throw new Error('System requires requiredComponents Array') unless _.isArray @requiredComponents
    throw new Error('System requires action Function')          unless _.isFunction action
    @action = action.bind @

  ###
  Creates a new system that runs the given function *for each* matched key. This helps to reduce
  system boilerplate. This function is called internally by {Rocket#systemForEach}.
  @param {String}        name name of the system
  @param {Array<String>} reqs array of required component names
  @param {Function}      fn   system action function for each key, invoked with
    `(rocket, key, cValue1, ..., cValueN)`
  @return {System} new instance of System
  ###
  @forEach: (name, reqs, fn) ->
    action = (rocket, keys, components...) ->
      for key in keys
        values = _.pluck components, key
        fn(rocket, key, values...)
    return new System name, reqs, action
