gulp   = require 'gulp'
gutil  = require 'gulp-util'
notify = require 'gulp-notify'

browserSync = require 'browser-sync'

sources =
  sass  : 'demos/{,*}/*.scss'
  html  : 'demos/{,*}/index.html'
  src   : 'src/**/*.coffee'
  demos : 'demos/{,*}/*.coffee'
  spec  : 'test/**/*.coffee'

destination = 'dist/'

gulp.task 'clean', ->
  gulp.src destination
      .pipe require('gulp-clean')()

gulp.task 'lint', ->
  coffeelint = require 'gulp-coffeelint'
  gulp.src sources.src
      .pipe coffeelint()
      .pipe coffeelint.reporter()
      .pipe coffeelint.reporter('fail').on 'error',
        notify.onError('<%= error.message %>')

gulp.task 'test', ->
  mocha = require 'gulp-mocha'
  gulp.src sources.spec
      .pipe mocha({reporter: 'spec'})
        .on 'error', notify.onError('Mocha: <%= error.message %>')

gulp.task 'html', ->
  gulp.src sources.html
      .pipe gulp.dest(destination)

gulp.task 'sass', ->
  sass = require 'gulp-sass'
  gulp.src sources.sass
      .pipe sass()
      .pipe gulp.dest(destination)

gulp.task 'src', ->
  # bundle Pocket library into pocket.js, export global
  source = require 'vinyl-source-stream'
  browserify = require 'browserify'
  browserify './src/pocket.coffee', {standalone: 'Pocket'}
    .bundle()
    .pipe source('pocket.js')
    .pipe gulp.dest(destination)

gulp.task 'demos', ->
  # compile demo scripts
  coffee = require 'gulp-coffee'
  sourcemaps = require 'gulp-sourcemaps'
  gulp.src sources.demos, base: 'demos'
      .pipe sourcemaps.init()
      .pipe coffee()
        .on 'error', notify.onError('Coffee: <%= error.message %>')
      .pipe sourcemaps.write()
      .pipe gulp.dest(destination)

# Compile all sources!
gulp.task 'build', ['html', 'sass', 'src', 'demos']

# Reloads the page for us, but first builds all the sources
gulp.task 'browserSync', ['build'], ->
  browserSync.init null,
    open: true
    server:
      baseDir: destination
    watchOptions:
      debounceDelay: 1000

# Watch files, but first launch server
gulp.task 'watch', ['browserSync'], ->
  # recompile sources
  gulp.watch [sources.src, sources.spec], ['lint', 'test', 'src']
  gulp.watch sources.demos, ['demos']
  gulp.watch sources.sass, ['sass']
  gulp.watch sources.html, ['html']
  # trigger reload when compiled files change
  gulp.watch 'dist/**', (file) ->
    browserSync.reload(file.path) if file.type is "changed"

# Do everything! build, browserSync, watch
gulp.task 'default', ['watch']

# Push to
gulp.task 'deploy', ->
  deploy = require 'gulp-gh-pages'
  gulp.src("./#{destination}/**/*")
      .pipe deploy()
