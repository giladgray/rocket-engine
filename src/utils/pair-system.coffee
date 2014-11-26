System = require '../system.coffee'

###
A System that accepts two `requiredComponents` arrays and passes both sets of resolved
keys and components to its action function. Also support {PairSystem#forEach} to create a
system that calls its action function *for each* pair of matching keys. This can be used
to detect collisions or other interactions between keys.

@example
  rocket.system PairSystem.forEach 'a-b', ['letter'], ['number'],
    (rocket, [keyA, letter], [keyB, number]) ->
      # function is called for each pair of [letter key, number key]
###
class PairSystem extends System
  ###
  Create a new PairSystem.
  @param name [String] name of the System
  @param requiredA [Array<String>] first array of required component names
  @param requiredB [Array<String>] second array of required component names
  @param actionFn  [Function]      pair system action function invoked with
    `(rocket, [keysA, compA1, ...compAN], [keysB, compB1, ...compBN)`
  ###
  constructor: (name, requiredA, requiredB, @actionFn) ->
    # run subclass validation
    super name, requiredA, @action
    # new validation checks for this class
    unless Array.isArray requiredB
      throw new Error('PairSystem requires two requiredComponents arrays')
    unless typeof @actionFn is 'function'
      throw new Error('System requires action Function')
    @requiredComponentsB = requiredB

  action: (rocket, keysA, reqsA...) ->
    # the following block copied from Rocket#_runSystem and modified to fit this class:
    # reqsB contains all keys that have any of the B names
    reqsB = @requiredComponentsB.map (name) -> rocket.getComponent(name) or {}
    # keysB contains keys that have all B components
    keysB = rocket.filterKeys @requiredComponentsB

    # call the action with an array for each pair
    @actionFn.call @, rocket, [keysA, reqsA...], [keysB, reqsB...]

  # Returns a PairSystem that will run its given function for each pair of matching keys.
  @forEach: (name, reqsA, reqsB, fn) ->
    action = (rocket, [keysA, cmpsA...], [keysB, cmpsB...]) ->
      for keyA in keysA
        valuesA = cmpsA.map (cmp) -> cmp[keyA]
        for keyB in keysB
          valuesB = cmpsB.map (cmp) -> cmp[keyB]
          fn(rocket, [keyA, valuesA...], [keyB, valuesB...])
    return new PairSystem name, reqsA, reqsB, action

module.exports = PairSystem
