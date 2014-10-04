chai = require 'chai'
expect = chai.expect

ScoreKeeper = require '../src/utils/score-keeper.coffee'

describe 'ScoreKeeper', ->
  keeper = null
  beforeEach ->
    keeper = new ScoreKeeper

  it 'can be created', ->
    expect(keeper).to.exist

  it 'can be created with initial high score', ->
    s = new ScoreKeeper(10)
    expect(s).to.exist
    expect(s.highScore).to.equal 10

  describe 'events proxy', ->
    it 'provides on, once, and off', ->
      expect(keeper.on).to.be.a.function
      expect(keeper.off).to.be.a.function
      expect(keeper.once).to.be.a.function

  describe '#addPoints', ->
    it 'adds points to score', ->
      keeper.addPoints(10)
      expect(keeper.score).to.equal 10

    it 'emits \'score\' event with total and new points', (done) ->
      keeper.on 'score', (total, pts) ->
        expect(total).to.equal 10
        expect(pts).to.equal 10
        done()
      expect(keeper.addPoints 10).to.be.true

    it 'updates high score', ->
      keeper.addPoints(10)
      expect(keeper.highScore).to.equal 10

    it 'emits \'highscore\' event with new highscore', -> (done) ->
      keeper.on 'highscore', (record) ->
        expect(record).to.equal 100
        done()
      keeper.addPoints 100

  describe '#reset', ->
    it 'resets score to zero', ->
      keeper.addPoints 10
      keeper.reset()
      expect(keeper.score).to.equal 0

    it 'emits \'score\' event with total 0 and negative old score', (done) ->
      keeper.addPoints 12
      keeper.on 'score', (total, pts) ->
        expect(total).to.equal 0
        expect(pts).to.equal -12
        done()
      keeper.reset()

  # describe '#enableSaving', ->
  #   it 'saves highscore to local storage', ->
  #     key = 'test-score-keeper'
  #     keeper.enableSaving key
  #     keeper.addScore 200
  #     expect(localStorage.getItem key).to.equal 200

  describe 'example: score, reset, smaller score', ->
    game = ->
      keeper.addPoints 10
      keeper.addPoints 4
      keeper.reset()
      keeper.addPoints 12

    it 'has appropriate final state', ->
      game()
      expect(keeper.score).to.equal 12
      expect(keeper.highScore).to.equal 14

    it 'emits \'score\' events for each step', ->
      scores = []
      points = []
      keeper.on 'score', (total, pts) ->
        scores.push total
        points.push pts
      game()
      expect(scores).to.deep.equal [10, 14,   0, 12]
      expect(points).to.deep.equal [10,  4, -14, 12]

    it 'emits two \'highscore\' events for first two adds', ->
      highscores = []
      keeper.on 'highscore', (record) -> highscores.push record
      game()
      expect(highscores).to.deep.equal [10, 14]
