_ = require 'lodash'

module.exports = class System
  constructor: (@name, @requiredComponents, action) ->
    throw new Error('System requires String name')              unless _.isString @name
    throw new Error('System requires requiredComponents Array') unless _.isArray @requiredComponents
    throw new Error('System requires action Function')          unless _.isFunction action
    @action = action.bind @

  @forEach: (name, reqs, fn) ->
    action = (pocket, keys, components...) ->
      for key in keys
        values = components.map (cmp) -> cmp[key]
        fn(pocket, key, values...)
    return new System name, reqs, action
