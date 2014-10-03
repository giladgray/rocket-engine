_ = require 'lodash'
System = require '../system.coffee'

###*
 * A System that accepts two `requiredComponents` arrays and passes both sets of resolved
 * keys and components to its action function. Also support `PairSystem.forEach` to create a
 * system that calls its action function *for each* pair of matching keys. This can be used
 * to detect collisions or other interactions between keys.
 *
 * @example
 * 	 pocket.system PairSystem.forEach 'a-b', ['letter'], ['number'],
 * 	 	 (pocket, [keyA, letter], [keyB, number]) ->
 * 	 	   # function is called for each pair of [letter key, number key]
###
class PairSystem extends System
  constructor: (name, requiredA, requiredB, @actionFn) ->
    # run subclass validation
    super name, requiredA, @action
    # new validation checks for this class
    throw new Error('PairSystem requires two requiredComponents arrays') unless _.isArray requiredB
    throw new Error('System requires action Function') unless _.isFunction @actionFn
    @requiredComponentsB = requiredB

  action: (pocket, keysA, reqsA...) ->
    # the following block copied from Pocket#_runSystem and modified to fit this class:
    # reqsB contains all keys that have any of the B names
    reqsB = @requiredComponentsB.map (name) -> pocket.getComponent(name) or {}
    # keysB contains keys that have all B components
    keysB = pocket.filterKeys @requiredComponentsB

    # call the action with an array for each pair
    @actionFn.call @, pocket, [keysA, reqsA...], [keysB, reqsB...]

  # Returns a PairSystem that will run its given function for each pair of matching keys.
  @forEach: (name, reqsA, reqsB, fn) ->
    action = (pocket, [keysA, cmpsA...], [keysB, cmpsB...]) ->
      for keyA in keysA
        valuesA = cmpsA.map (cmp) -> cmp[keyA]
        for keyB in keysB
          valuesB = cmpsB.map (cmp) -> cmp[keyB]
          fn(pocket, [keyA, valuesA...], [keyB, valuesB...])
    return new PairSystem name, reqsA, reqsB, action

module.exports = PairSystem
