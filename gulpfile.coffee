gulp = require 'gulp'
gutil = require 'gulp-util'
gulpif = require 'gulp-if'
plumber = require 'gulp-plumber'
changed = require 'gulp-changed'
path = require 'path'

# exec
exec = require 'gulp-exec'

# clean
clean = require 'gulp-clean'

# concat
concat = require 'gulp-concat'

# HTML
include = require 'gulp-include'
htmlmin = require 'gulp-htmlmin'

# Images
imagemin = require 'gulp-imagemin'
svgmin = require 'gulp-svgmin'

# Styles
less = require 'gulp-less'
prefix = require 'gulp-autoprefixer'
csso = require 'gulp-csso'

# GSS
gss = require 'gulp-gss'

# Scripts
uglify = require 'gulp-uglify'

# webpack
webpack = require 'webpack'

# modernizr
modernizr = require 'gulp-modernizr'

# livereload
livereload = require 'gulp-livereload'
lr = require 'tiny-lr'
server = lr()

# args from cli
args = require('optimist').argv
env = args.env
buildenv =  if env is 'production' then 'dist' else 'dev'
process.env.NODE_ENV = if env is 'production' then 'production' else 'development'
cmd = args.cmd

src = path.join __dirname, 'src'
site = '/sandbox'
build = path.join __dirname, 'build', buildenv

folder =
  vendor: src + '/vendor/'
  custom: src + '/custom/'
  html: src + site + '/html/'
  images: src + site + '/images/'
  less: src + site + '/less/'
  gss: src + site + '/gss/'
  coffee: src + site + '/coffee/'

paths =
  html: folder.html + '*.html'
  includes: folder.html + 'includes/**/*.html'
  images: folder.images + '**/*'
  svg: folder.images + '**/*.svg'
  less: folder.less + '**/*.less'
  gss: folder.gss + '**/*.gss'
  coffee: folder.coffee + '*.coffee'
  
vendor =
  js: [folder.vendor + 'gss/dist/worker.js', folder.vendor + 'gss/dist/gss.js']

dest =
  html: build
  img: build + '/img'
  css: build + '/css'
  gss: build + '/gss'
  js: build + '/js'
  modernizr: build + '/js'

webpackConfig = require './webpackConfig'

EXPRESS_PORT = 8080
EXPRESS_ROOT = build
LIVERELOAD_PORT = 35729

gulp.task 'default', ['exec']

gulp.task 'exec', ->
  gulp.src src
    .pipe gulpif cmd is 'installrequirements',
      exec 'npm install && bower install'

gulp.task 'build', ['clean'], ->
  if env is 'production'
    gulp.start 'modernizr'
  gulp.start 'html', 'images', 'styles', 'gss', 'webpack', 'vendor'

gulp.task 'clean', ->
  gulp.src build
    .pipe clean()

gulp.task 'modernizr', ->
  gulp.src [ paths.less, paths.coffee ]
    .pipe modernizr()
    .pipe uglify()
    .pipe gulp.dest dest.modernizr

gulp.task 'html', ->
  gulp.src paths.html
    .pipe plumber()
    .pipe include()
    .pipe htmlmin()
    .pipe gulp.dest dest.html
    .pipe livereload server

gulp.task 'images', ['imagemin', 'svgmin']

gulp.task 'imagemin', ->
  gulp.src [ paths.images, '!**/*.svg' ]
    .pipe changed dest.img
    .pipe imagemin()
    .pipe gulp.dest dest.img
    .pipe livereload server

gulp.task 'svgmin', ->
  gulp.src paths.svg
    .pipe plumber()
    .pipe changed dest.img
    .pipe svgmin()
    .pipe gulp.dest dest.img
    .pipe livereload server

gulp.task 'styles', ->
  gulp.src [ paths.less, '!**/_*.less' ]
    .pipe plumber()
    .pipe less()
    .pipe prefix 'last 2 version', 'ie 9'
    .pipe csso()
    .pipe gulp.dest dest.css
    .pipe livereload server

gulp.task 'gss', ->
  gulp.src paths.gss
    .pipe concat 'styles.gss'
    # .pipe gss() waiting for clarification on using gss-ast json
    .pipe gulp.dest dest.gss
    .pipe livereload server

gulp.task 'webpack', ->
  myConfig = Object.create webpackConfig
  myConfig.resolve.root = [folder.coffee, folder.vendor, folder.custom]
  myConfig.output.path = dest.js
  if env is 'production'
    myConfig.plugins = [
      new webpack.optimize.DedupePlugin()
      new webpack.optimize.UglifyJsPlugin()
    ]
  else
    myConfig.devtool = 'sourcemap'
    myConfig.debug = true

  webpack myConfig, (err, stats)->
    throw new gutil.PluginError '[webpack]', err if err
    gutil.log '[webpack]', stats.toString colors: true
    gulp.src build
      .pipe livereload server

gulp.task 'vendor', ->
  gulp.src vendor.js
    .pipe gulp.dest dest.js

gulp.task 'connect', ->
  express = require 'express'
  app = express()
  app.use require('connect-livereload')()
  app.use express.static EXPRESS_ROOT
  app.listen EXPRESS_PORT

gulp.task 'watch', ->
  gulp.start 'build'
  
  gulp.start 'connect'
  server.listen LIVERELOAD_PORT, (err)->
    console.log err if err

  gulp.watch [paths.html, paths.includes], ['html']
  gulp.watch paths.images, ['images']
  gulp.watch paths.less, ['styles']
  gulp.watch paths.gss, ['gss']
  gulp.watch paths.coffee, ['webpack']
