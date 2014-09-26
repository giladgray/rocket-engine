gulp   = require 'gulp'
gutil  = require 'gulp-util'
notify = require 'gulp-notify'

sources =
  sass   : 'sass/**/*.scss'
  html   : 'index.html'
  coffee : 'src/**/*.coffee'
  spec   : 'test/**/*.coffee'

destinations =
  css  : 'dist/css'
  html : 'dist/'
  js   : 'dist/js'

gulp.task 'default', ->

gulp.task 'lint', ->
  coffeelint = require 'gulp-coffeelint'
  gulp.src sources.coffee
      .pipe coffeelint()
      .pipe coffeelint.reporter()
      .pipe coffeelint.reporter('fail').on 'error',
        notify.onError('<%= error.message %>')

gulp.task 'src', ->
  coffee = require 'gulp-coffee'
  concat = require 'gulp-concat'
  gulp.src sources.coffee
      .pipe coffee().on 'error', gutil.log
      .pipe concat('app.js')
      .pipe gulp.dest(destinations.js)

gulp.task 'test', ->
  mocha = require 'gulp-mocha'
  gulp.src sources.spec
      .pipe mocha({reporter: 'spec'})
        .on 'error', notify.onError('Mocha: <%= error.message %>')

gulp.task 'watch', ->
  gulp.watch [sources.coffee, sources.spec], ['lint', 'test']
