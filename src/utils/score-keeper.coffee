events = require 'events'

###*
 * Keeps track of current score and high score. Emits events when points are added or a new
 * high score is achieved. Saves high score to localStorage, if enabled.
###
class ScoreKeeper
  ###*
   * Create a new ScoreKeeper with an initial high score.
   * @param  {Number} highScore initial high score
  ###
  constructor: (@highScore = 0) ->
    @_events = new events.EventEmitter
    @score = 0

  on   : => @_events.on arguments...
  once : => @_events.once arguments...
  off  : => @_events.removeListener arguments...

  ###*
   * Add a number of points to the score and maybe updates high score.
   * @param {Number} amt points to add
   * @event score
   *   emits an event when points are added. arguments are `(total score, new points)`.
   * @event highscore
   *   emits an event when a new high score is set. arguments are `(highscore)`.
  ###
  addPoints: (amt = 0) ->
    @score += amt
    if @score > @highScore
      @highScore = @score
      @saveHighScore()
    @_events.emit 'score', @score, amt

  ###*
   * Resets the score to zero.
  ###
  reset: ->
    oldScore = @score
    @score = 0
    @_events.emit 'score', @score, -oldScore

  ###*
   * Enables saving of the high score to the given localStorage key.
   * @param {String} scoreKey localStorage key for saving high score
  ###
  enableSaving: (@scoreKey) ->
    savedScore = localStorage.getItem @scoreKey
    if savedScore? then @highScore = savedScore

  ###*
   * Disables saving of the high score by forgetting the localStorage key.
  ###
  disableSaving: -> @scoreKey = undefined

  ###*
   * Saves the current highscore to localStorage and emits an event.
   * @event highscore
   *   emits an event when a new high score is set. arguments are `(highscore)`.
  ###
  saveHighScore: ->
    @_events.emit 'highscore', @highScore
    return unless @scoreKey
    localStorage.setItem @scoreKey, @highScore

module.exports = ScoreKeeper
