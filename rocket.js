!function(e){if("object"==typeof exports&&"undefined"!=typeof module)module.exports=e();else if("function"==typeof define&&define.amd)define([],e);else{var f;"undefined"!=typeof window?f=window:"undefined"!=typeof global?f=global:"undefined"!=typeof self&&(f=self),f.Rocket=e()}}(function(){var define,module,exports;return (function e(t,n,r){function s(o,u){if(!n[o]){if(!t[o]){var a=typeof require=="function"&&require;if(!u&&a)return a(o,!0);if(i)return i(o,!0);var f=new Error("Cannot find module '"+o+"'");throw f.code="MODULE_NOT_FOUND",f}var l=n[o]={exports:{}};t[o][0].call(l.exports,function(e){var n=t[o][1][e];return s(n?n:e)},l,l.exports,e,t,n,r)}return n[o].exports}var i=typeof require=="function"&&require;for(var o=0;o<r.length;o++)s(r[o]);return s})({1:[function(require,module,exports){
var RocketEngine, System, _,
  __slice = [].slice;

_ = require('./fn.coffee');

System = require('./system.coffee');


/*
@author Gilad Gray
@license MIT

Rocket Engine: A data-driven game engine that'll take you over the moon.

Many thanks to kirbysayshi for inspiration and code samples.
@see https://github.com/kirbysayshi/pocket-ces
 */

RocketEngine = (function() {
  RocketEngine.System = System;

  function RocketEngine() {
    this.time = 0;
    this._componentTypes = {};
    this._keys = {};
    this._labels = {};
    this._systems = [];
    this._components = {};
    this._keysToDestroy = {};
  }


  /* KEYS */


  /*
  Store a new key in the Rocket.
  @param  {Object} components mapping of component or label names to initial values
  @return {String}            ID of new key
   */

  RocketEngine.prototype.key = function(components) {
    var component, id, name, _ref;
    id = (_ref = components.id) != null ? _ref : _.uniqueId('key-');
    if (components.id && this._keys[components.id]) {
      console.warn("discarding component id " + components.id);
      id = _.uniqueId('key-');
    }
    this._keys[id] = id;
    for (name in components) {
      component = components[name];
      this.addComponentToKey(id, name, component);
    }
    return id;
  };


  /*
  Convenience method to add a series of keys at once.
  @see RocketEngine::key
  @param  {Array<Object>} keys an array or splat of key definitions
  @return {Array<String>}      IDs of new keys
   */

  RocketEngine.prototype.keys = function() {
    var cmps, keys, _i, _len, _ref, _results;
    keys = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
    _ref = _.flatten(keys);
    _results = [];
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      cmps = _ref[_i];
      _results.push(this.key(cmps));
    }
    return _results;
  };


  /*
  Returns an array of all existing keys.
  @return {Array<String>} all existing keys
   */

  RocketEngine.prototype.getKeys = function() {
    return Object.keys(this._keys);
  };

  RocketEngine.prototype.destroyKey = function(id) {
    return this._keysToDestroy[id] = true;
  };

  RocketEngine.prototype.destroyKeys = function() {
    var id, ids, _i, _len, _ref, _results;
    ids = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
    _ref = _.flatten(ids);
    _results = [];
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      id = _ref[_i];
      _results.push(this.destroyKey(id));
    }
    return _results;
  };


  /*
  Deletes key entry and all component data about it.
  This operation is UNSAFE, prefer using {#destroyKey} which allows the
  Rocket to delete keys at its earliest, safe convenience.
   */

  RocketEngine.prototype.immediatelyDestroyKey = function(id) {
    var cmp, name, _ref, _results;
    if (!this._keys[id]) {
      throw new Error("key with id " + id + " already destroyed");
    }
    delete this._keys[id];
    _ref = this._components;
    _results = [];
    for (name in _ref) {
      cmp = _ref[name];
      _results.push(delete this._components[name][id]);
    }
    return _results;
  };


  /* COMPONENTS */


  /*
  Register a new named component type in the Rocket.
  @param {String} name        name of component
  @param {Function, Object} initializer component initializer function
    `(component, options) -> void` or default options object
   */

  RocketEngine.prototype.component = function(name, initializer) {
    var defaults;
    if (_.isFunction(initializer)) {

    } else if (_.isObject(initializer)) {
      defaults = initializer;
      (function(defaults) {
        return initializer = function(comp, options) {
          if (options == null) {
            options = {};
          }
          _.defaults(comp, _.clone(defaults, true));
          return _.merge(comp, options);
        };
      })(defaults);
    }
    if (!_.isFunction(initializer)) {
      throw new Error('Unexpected component initializer type. Must be function or object.');
    }
    this._componentTypes[name] = initializer;
    this._components[name] = {};
  };


  /*
  Convenience function to define several components at once.
  @see RocketEngine::component
  @param  {Object} components mapping of names to initializers
   */

  RocketEngine.prototype.components = function(components) {
    var initializer, name;
    for (name in components) {
      initializer = components[name];
      this.component(name, initializer);
    }
  };


  /*
  Returns the state of the given component, for testing only.
  @param {String} name component name
  @return {Object} component state: mapping of keys to their component values
   */

  RocketEngine.prototype.getComponent = function(name) {
    return this._components[name];
  };


  /*
  Returns the contents of the first key associated with the component name.
  @param {String} name name of component to query for data
  @return {Object} component state for its first key
   */

  RocketEngine.prototype.getData = function(name) {
    var data;
    data = this._components[name];
    if (data == null) {
      throw new Error("No data found for " + name);
    }
    return data[Object.keys(data)[0]];
  };


  /*
  Returns component data for the given key.
  @param {String} key  key to look up
  @param {String} name component name
  @return {Object} component state for the key
   - TODO: dataFor(key) constructs the entire data object? this would be expensive so be careful!
   */

  RocketEngine.prototype.dataFor = function(key, name) {
    var _ref;
    return (_ref = this._components[name]) != null ? _ref[key] : void 0;
  };


  /* KEYS + COMPONENTS */


  /*
  Adds a new instance to the given component under the given ID with options
  @param {String} id            id of key
  @param {String} componentName name of component
  @param {Object} options       options for component initializer
   */

  RocketEngine.prototype.addComponentToKey = function(id, componentName, options) {
    var cmpEntry, cmpInitializer, component, _base;
    if (!this._keys[id]) {
      throw new Error("could not find key with id " + id);
    }
    component = (_base = this._components)[componentName] != null ? _base[componentName] : _base[componentName] = {};
    cmpEntry = component[id];
    if (!cmpEntry) {
      cmpEntry = component[id] = {};
      cmpInitializer = this._componentTypes[componentName];
      if (cmpInitializer) {
        cmpInitializer(cmpEntry, options != null ? options : {});
      } else if (!this._labels[componentName]) {
        this._labels[componentName] = true;
        console.log("Found no component definition for '" + componentName + "', assuming it's a label.");
      }
    }
  };


  /*
  Returns an array of keys that contain all the given components.
  @param componentArray {String...} array or splat of component names
  @return {Array<String>} array of matching key IDs
   */

  RocketEngine.prototype.filterKeys = function() {
    var componentArray, hasAll, id, matching, name, names, table0, _i, _len, _ref;
    componentArray = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
    names = _.flatten(componentArray);
    matching = [];
    table0 = this._components[names.shift()];
    if (!table0) {
      return matching;
    }
    for (id in table0) {
      hasAll = true;
      for (_i = 0, _len = names.length; _i < _len; _i++) {
        name = names[_i];
        if (((_ref = this._components[name]) != null ? _ref[id] : void 0) == null) {
          hasAll = false;
          break;
        }
      }
      if (hasAll) {
        matching.push(id);
      }
    }
    return matching;
  };


  /* SYSTEMS */


  /*
  Register a new {System} in the Rocket.
  @param  {String}        name name of the system
  @param  {Array<String>} reqs array of required component names
  @param  {Function}      fn   system action function, invoked with
                               (rocket, keys[], cName1{}, ..., cNameN{})
  @return {System} new instance of System that was added.
   */

  RocketEngine.prototype.system = function(name, reqs, fn) {
    var system;
    system = name instanceof System ? name : new System(name, reqs, fn);
    this._systems.push(system);
    return system;
  };


  /*
  Register a new {System} in the Rocket that calls its function *for each* key
  that matches the requirements, to reduce boilerplate.
  @param {String}        name name of the system
  @param {Array<String>} reqs array of required component names
  @param {Function}      fn   system action function for each key, invoked with
                              (rocket, key, cValue1, ..., cValueN)
  @return {System} new instance of System that was added.
   */

  RocketEngine.prototype.systemForEach = function(name, reqs, fn) {
    return this.system(System.forEach(name, reqs, fn));
  };


  /*
  @private
  Returns array with all system names
  @return [Array<String>] array with all system names
   */

  RocketEngine.prototype.getSystems = function() {
    return _.pluck(this._systems, 'name');
  };

  RocketEngine.prototype._destroyMarkedKeys = function() {
    var key, _results;
    _results = [];
    for (key in this._keysToDestroy) {
      this.immediatelyDestroyKey(key);
      _results.push(delete this._keysToDestroy[key]);
    }
    return _results;
  };

  RocketEngine.prototype._runSystems = function() {
    var keys, reqs, system, _i, _len, _ref, _results;
    _ref = this._systems;
    _results = [];
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      system = _ref[_i];
      reqs = system.requiredComponents.map((function(_this) {
        return function(name) {
          return _this._components[name] || {};
        };
      })(this));
      keys = this.filterKeys(system.requiredComponents);
      _results.push(system.action.apply(system, [this, keys].concat(__slice.call(reqs))));
    }
    return _results;
  };


  /*
  Perform one tick of the Rocket environment: destroy marked keys and run all systems.
  This function is intended to be wrapped in a `requestAnimationFrame` loop so it will
  be run every frame.
  @param {DOMHighResTimeStamp} time a timestamp from `requestAnimationFrame`
   */

  RocketEngine.prototype.tick = function(time) {
    if (time != null) {
      this.delta = time - this.time;
      this.time = time;
    }
    this._destroyMarkedKeys();
    this._runSystems();
  };

  return RocketEngine;

})();

module.exports = RocketEngine;


/*
TODO
- firstKey(componentName) returns first key for that component, useful when you only have one
  (like the player's ship in Asteroids)
  - firstData(componentName) returns the data associated with first key for a *single* component
  - firstKey(componentName) returns the first key for a component, which you can use to get all its
    other data
 */



},{"./fn.coffee":2,"./system.coffee":3}],2:[function(require,module,exports){

/*
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
 */
var Fn,
  __slice = [].slice,
  __hasProp = {}.hasOwnProperty;

Fn = (function() {
  var objectTypes, type, _fn, _i, _len, _ref;

  function Fn() {}


  /*
  Generate a unique identifier with an optional prefix.
  @param prefix [String] optional value to prefix returned identifier
  @return [String] unique identifier
   */

  Fn.uniqueId = (function() {
    var nextId;
    nextId = 0;
    return function(prefix) {
      if (prefix == null) {
        prefix = '';
      }
      return prefix + (nextId++);
    };
  })();

  objectTypes = {};

  _ref = ['Number', 'String', 'Boolean', 'Object', 'Array', 'Function'];
  _fn = function(type) {
    return Fn["is" + type] = function(val) {
      return Object.prototype.toString.call(val) === objectTypes[type];
    };
  };
  for (_i = 0, _len = _ref.length; _i < _len; _i++) {
    type = _ref[_i];
    objectTypes[type] = "[object " + type + "]";
    _fn(type);
  }


  /*
  Returns a random integer between `[min, max)`: from `min` (inclusive) up to but
  not including `max` (exclusive). If only one argument `max` is provided, the range
  becomes `[0, max)`. Uses `Math.random()` internally.
  @param min [Number] minimum value, inclusive; defaults to 0 if omitted
  @param max [Number] maximum value, exclusive
  @return [Number] random integer between `min` and `max`
   */

  Fn.random = function(min, max) {
    if (max == null) {
      max = min;
      min = 0;
    }
    return Math.floor(Math.random() * (max - min)) + min;
  };


  /*
  Flattens a nested array (the nesting can be to any depth). Accepts a single array or splat of
  mixed types.
  @param arrays [Array...] a single array of splat of values to flatten
  @return [Array] a single flattened array
   */

  Fn.flatten = function() {
    var arg, flattened, _j, _len1;
    if (arguments.length === 1) {
      arg = arguments[0];
      if (Fn.isArray(arg)) {
        return Fn.flatten.apply(null, arg);
      } else {
        return [arg];
      }
    }
    flattened = [];
    for (_j = 0, _len1 = arguments.length; _j < _len1; _j++) {
      arg = arguments[_j];
      if (Fn.isArray(arg)) {
        flattened.push.apply(flattened, Fn.flatten.apply(Fn, arg));
      } else {
        flattened.push(arg);
      }
    }
    return flattened;
  };


  /*
  Recursively merges own enumerable properties of source objects into destination object.
  Subsequent sources will overwrite property assignments of previous sources.
  @param object [Object] destination object to merge properties into.
  @param sources [Object...] splat of source objects
  @return [Object] destination object with merged properties
   */

  Fn.merge = function() {
    var key, object, source, sources, val, _j, _len1, _ref1;
    object = arguments[0], sources = 2 <= arguments.length ? __slice.call(arguments, 1) : [];
    for (_j = 0, _len1 = sources.length; _j < _len1; _j++) {
      source = sources[_j];
      for (key in source) {
        if (!__hasProp.call(source, key)) continue;
        val = source[key];
        if (Fn.isObject(val)) {
          object[key] = Fn.merge((_ref1 = object[key]) != null ? _ref1 : {}, val);
        } else {
          object[key] = val;
        }
      }
    }
    return object;
  };


  /*
  Creates a new object with the same properties as the given object.
  @param object [Object] object to clone
  @return [Object] a clone of the given object
   */

  Fn.clone = function(object) {
    return Fn.merge({}, object);
  };


  /*
  Assigns own enumerable properties of source object(s) to the destination object for all
  destination properties that resolve to undefined. Once a property is set, additional defaults of
  the same property will be ignored.
  @param object [Object] destination object to merge properties into.
  @param sources [Object...] splat of source objects
  @return [Object] destination object with merged properties
   */

  Fn.defaults = function() {
    var key, object, source, sources, val, _j, _len1;
    object = arguments[0], sources = 2 <= arguments.length ? __slice.call(arguments, 1) : [];
    for (_j = 0, _len1 = sources.length; _j < _len1; _j++) {
      source = sources[_j];
      for (key in source) {
        if (!__hasProp.call(source, key)) continue;
        val = source[key];
        if (object[key] === void 0) {
          object[key] = val;
        }
      }
    }
    return object;
  };


  /*
  Retrieves the value of a specified property from all elements in the array.
  @param collection [Array] array of elements
  @param property [String] property name to pluck
  @return [Array] array of values for given property
   */

  Fn.pluck = function(collection, property) {
    var item, _j, _len1, _results;
    _results = [];
    for (_j = 0, _len1 = collection.length; _j < _len1; _j++) {
      item = collection[_j];
      _results.push(item[property]);
    }
    return _results;
  };

  return Fn;

})();

module.exports = Fn;



},{}],3:[function(require,module,exports){
var System, _,
  __slice = [].slice;

_ = require('./fn.coffee');


/*
 */

module.exports = System = (function() {

  /*
  Create a new System. All three parameters are required. The `action` function will be bound
  to run in the context of the System instance.
  @param {String}        name               name of the system
  @param {Array<String>} requiredComponents array of required component names
  @param {Function}      action             system action function invoked with
    `(rocket, keys, cValues1, ..., cValuesN)`
   */
  function System(name, requiredComponents, action) {
    this.name = name;
    this.requiredComponents = requiredComponents;
    if (!_.isString(this.name)) {
      throw new Error('System requires String name');
    }
    if (!_.isArray(this.requiredComponents)) {
      throw new Error('System requires requiredComponents Array');
    }
    if (!_.isFunction(action)) {
      throw new Error('System requires action Function');
    }
    this.action = action.bind(this);
  }


  /*
  Creates a new system that runs the given function *for each* matched key. This helps to reduce
  system boilerplate. This function is called internally by {Rocket#systemForEach}.
  @param {String}        name name of the system
  @param {Array<String>} reqs array of required component names
  @param {Function}      fn   system action function for each key, invoked with
    `(rocket, key, cValue1, ..., cValueN)`
  @return {System} new instance of System
   */

  System.forEach = function(name, reqs, fn) {
    var action;
    action = function() {
      var components, key, keys, rocket, values, _i, _len, _results;
      rocket = arguments[0], keys = arguments[1], components = 3 <= arguments.length ? __slice.call(arguments, 2) : [];
      _results = [];
      for (_i = 0, _len = keys.length; _i < _len; _i++) {
        key = keys[_i];
        values = _.pluck(components, key);
        _results.push(fn.apply(null, [rocket, key].concat(__slice.call(values))));
      }
      return _results;
    };
    return new System(name, reqs, action);
  };

  return System;

})();



},{"./fn.coffee":2}]},{},[1])(1)
});