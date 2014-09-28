gulp   = require 'gulp'
gutil  = require 'gulp-util'
notify = require 'gulp-notify'

browserSync = require 'browser-sync'

sources =
  sass  : 'demos/{,*}/*.scss'
  html  : 'demos/{,*}/index.html'
  src   : 'src/*.coffee'
  demos : 'demos/{,*}/*.coffee'
  spec  : 'test/**/*.coffee'

destinations =
  css  : 'dist/'
  html : 'dist/'
  js   : 'dist/'

gulp.task 'default', ->

gulp.task 'clean', ->
  gulp.src destinations.html
      .pipe require('gulp-clean')()

gulp.task 'lint', ->
  coffeelint = require 'gulp-coffeelint'
  gulp.src sources.src
      .pipe coffeelint()
      .pipe coffeelint.reporter()
      .pipe coffeelint.reporter('fail').on 'error',
        notify.onError('<%= error.message %>')

gulp.task 'html', ->
  gulp.src sources.html
      .pipe gulp.dest(destinations.html)

gulp.task 'sass', ->
  sass = require 'gulp-sass'
  gulp.src sources.sass
      .pipe sass()
      .pipe gulp.dest(destinations.css)

gulp.task 'src', ->
  source = require 'vinyl-source-stream'
  browserify = require 'browserify'
  browserify './src/pocket.coffee', {standalone: 'Pocket'}
    .bundle()
    .pipe source('pocket.js')
    .pipe gulp.dest(destinations.js)

gulp.task 'demos', ->
  coffee = require 'gulp-coffee'
  gulp.src sources.demos, base: 'demos'
      .pipe coffee().on 'error', gutil.log
      .pipe gulp.dest(destinations.js)

gulp.task 'test', ->
  mocha = require 'gulp-mocha'
  gulp.src sources.spec
      .pipe mocha({reporter: 'spec'})
        .on 'error', notify.onError('Mocha: <%= error.message %>')

# Reloads the page for us
gulp.task 'browser-sync', ->
  browserSync.init null,
    open: true
    server:
      baseDir: destinations.html
    watchOptions:
      debounceDelay: 1000

gulp.task 'watch', ->
  gulp.watch [sources.src, sources.spec], ['lint', 'test', 'src']
  gulp.watch sources.demos, ['demos']
  gulp.watch sources.sass, ['sass']
  gulp.watch sources.html, ['html']

  gulp.watch 'dist/**', (file) ->
    browserSync.reload(file.path) if file.type is "changed"

gulp.task 'deploy', ->
  deploy = require 'gulp-gh-pages'
  gulp.src('./dist/**/*')
      .pipe deploy()
