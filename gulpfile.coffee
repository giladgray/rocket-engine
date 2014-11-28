gulp   = require 'gulp'
gutil  = require 'gulp-util'
notify = require 'gulp-notify'

browserSync = require 'browser-sync'

sources =
  img   : 'demos/{,*/}*.{svg,png}'
  sass  : 'demos/{,*/}*.scss'
  html  : 'demos/{,*/}index.html'
  src   : 'src/**/*.coffee'
  demos : 'demos/{,*/}*.coffee'
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

gulp.task 'test', ['test-web'], ->
  mocha = require 'gulp-mocha'
  gulp.src sources.spec
      .pipe mocha({reporter: 'spec'})
        .on 'error', notify.onError('Mocha: <%= error.message %>')

gulp.task 'test-web', ->
  source = require 'vinyl-source-stream'
  browserify = require 'browserify'
  browserify './test/web/index.coffee'
    .bundle()
    .pipe source('test/tests.js')
    .pipe gulp.dest(destination)
  gulp.src './node_modules/gulp-mocha/node_modules/mocha/mocha.*'
    .pipe gulp.dest destination + '/test'

gulp.task 'html', ->
  gulp.src sources.html
      .pipe gulp.dest(destination)
  gulp.src sources.img
      .pipe gulp.dest(destination)
  gulp.src 'test/web/index.html', base: 'test/web'
      .pipe gulp.dest(destination + '/test')

gulp.task 'sass', ->
  sass = require 'gulp-sass'
  autoprefixer = require 'gulp-autoprefixer'
  gulp.src sources.sass
      .pipe sass()
      .pipe autoprefixer()
      .pipe gulp.dest(destination)

gulp.task 'src', ->
  # bundle Rocket library into rocket.js, export global
  source = require 'vinyl-source-stream'
  browserify = require 'browserify'
  browserify './src/rocket.coffee', {standalone: 'Rocket'}
    .bundle()
    .pipe source('rocket.js')
    .pipe gulp.dest(destination)

gulp.task 'demos', ->
  # bundle each demo into a js file
  rename = require 'gulp-rename'
  browserify = require 'browserify'
  transform = require 'vinyl-transform'
  browserified = transform (filename) ->
    browserify(filename).bundle()
  gulp.src sources.demos, base: 'demos'
      .pipe browserified
      .pipe rename(extname: '.js')
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

gulp.task 'docs', ->
  exec = require('child_process').exec
  exec 'codo', (err, stdout, stderr) ->
    console.log stdout
    console.error stderr

# Watch files, but first launch server
gulp.task 'watch', ['browserSync'], ->
  # recompile sources
  gulp.watch [sources.src, sources.spec], ['lint', 'test', 'src']
  gulp.watch sources.demos, ['demos']
  gulp.watch sources.sass, ['sass']
  gulp.watch [sources.html, sources.img], ['html']
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
