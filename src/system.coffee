module.exports = class System
  constructor: (@name, @requiredComponents, action) ->
    @action = action.bind @
