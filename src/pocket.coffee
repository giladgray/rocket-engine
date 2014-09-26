###
Many thanks to kirbysayshi for inspiration and code samples.
@see https://github.com/kirbysayshi/pocket-ces

@author Gilad Gray
@license MIT
###

_ = require 'lodash'

class Pocket
  constructor: ->
    @componentTypes = {}

    @keys = {}
    @labels = {}
    @systems = {}
    @components = {}

    @keysToDestroy = {}

  ###*
   * Store a new key in the Pocket
   * @param  {Object} components mapping of component or label names to initial values
   * @return {String}            ID of new key
  ###
  key: (components) ->
    id = components.id ? _.uniqueId('key-')
    if components.id && @keys[components.id]
      console.warn "discarding component id #{components.id}"
      id = _.uniqueId('key-')

    @keys[id] = id

    for name, component of components
      @addComponentToKey id, name, component

    return id

  destroyKey = (id) ->
    @keysToDestroy[id] = true

  immediatelyDestroyKey: (id) ->
    unless @keys[id]
      throw new Error("key with id #{id} already destroyed")
    delete @keys[id]
    for name, cmp of @components
      delete @components[name][id]

  ###*
   * Register a new named component type in the Pocket.
   * @param {String} name        name of component
   * @param {Function, Object} initializer component initializer function
   *   `(component, options) -> void` or default options object
  ###
  componentType: (name, initializer) ->
    if _.isFunction initializer
      # noop
    else if _.isObject initializer
      compFn = (defaults, comp, options={}) ->
        console.log arguments
        _.defaults comp, _.clone(defaults, true)
        _.assign comp, options
        # _.defaults comp, _.clone(defaults, true)
      initializer = _.partial compFn, initializer
    unless _.isFunction initializer
      throw new Error 'Unexpected component initializer type. Must be function or object.'
    @componentTypes[name] = initializer
    return

  ###*
   * Adds a new instance to the given component under the given ID with options
   * @param {String} id            id of key
   * @param {String} componentName name of component
   * @param {Object} options       options for component initializer
  ###
  addComponentToKey: (id, componentName, options) ->
    key = @keys[id]
    unless key
      throw new Error "could not find key with id #{id}"

    others = @components[componentName] ?= {}
    comp = others[id]

    unless comp
      comp = others[id] = {}
      componentDef = @componentTypes[componentName]

      if componentDef
        componentDef(comp, options)
      else if !@labels[componentName]
        @labels[componentName] = true
        console.log "Found no component definition for '#{componentName}', assuming it's a label."
    return

module.exports = Pocket
