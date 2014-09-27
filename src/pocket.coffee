###
@author Gilad Gray
@license MIT

Many thanks to kirbysayshi for inspiration and code samples.
@see https://github.com/kirbysayshi/pocket-ces
###

_ = require 'lodash'

class Pocket
  constructor: ->
    @_componentTypes = {}

    @_keys = {}
    @_labels = {}
    @_systems = {}
    @_components = {}

    @_keysToDestroy = {}

  ###*
   * Store a new key in the Pocket
   * @param  {Object} components mapping of component or label names to initial values
   * @return {String}            ID of new key
  ###
  key: (components) ->
    id = components.id ? _.uniqueId('key-')
    if components.id && @_keys[components.id]
      console.warn "discarding component id #{components.id}"
      id = _.uniqueId('key-')

    @_keys[id] = id

    for name, component of components
      @addComponentToKey id, name, component

    return id

  destroyKey = (id) ->
    @_keysToDestroy[id] = true

  immediatelyDestroyKey: (id) ->
    unless @_keys[id]
      throw new Error("key with id #{id} already destroyed")
    delete @_keys[id]
    for name, cmp of @_components
      delete @_components[name][id]

  ###*
   * Register a new named component type in the Pocket.
   * @param {String} name        name of component
   * @param {Function, Object} initializer component initializer function
   *   `(component, options) -> void` or default options object
  ###
  component: (name, initializer) ->
    if _.isFunction initializer
      # noop
    else if _.isObject initializer
      compFn = (defaults, comp, options={}) ->
        _.defaults comp, _.clone(defaults, true)
        _.assign comp, options
        # _.defaults comp, _.clone(defaults, true)
      initializer = _.partial compFn, initializer
    unless _.isFunction initializer
      throw new Error 'Unexpected component initializer type. Must be function or object.'
    @_componentTypes[name] = initializer
    @_components[name] = {}
    return

  ###*
   * Returns the state of the given component, for testing only.
   * @param {String} name component name
   * @return {Object} component state: mapping of keys to their component values
  ###
  getComponent: (name) -> @_components[name]

  ###*
   * Adds a new instance to the given component under the given ID with options
   * @param {String} id            id of key
   * @param {String} componentName name of component
   * @param {Object} options       options for component initializer
  ###
  addComponentToKey: (id, componentName, options) ->
    key = @_keys[id]
    unless key
      throw new Error "could not find key with id #{id}"

    others = @_components[componentName] ?= {}
    comp = others[id]

    unless comp
      comp = others[id] = {}
      componentDef = @_componentTypes[componentName]

      if componentDef
        componentDef(comp, options)
      else if !@_labels[componentName]
        @_labels[componentName] = true
        console.log "Found no component definition for '#{componentName}', assuming it's a label."
    return

  ###*
   * Returns the contents of the first key associated with the component name.
   * @param {String} name name of component to query for data
  ###
  getData: (name) ->
    data = @_components[name]
    return data[_.keys(data)[0]]

module.exports = Pocket
