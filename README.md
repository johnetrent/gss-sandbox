THINK Wednesday - Static
========================

An app for generating a static version of the THINK Wednesday site


Development
-----------

This project uses [Gulp]. In order to work on the site, you must first install
[nodejs] and [bower]. Then:

1. Install dependencies using `npm install && bower install`
2. Run `gulp watch` to begin working on the site. This will start an express and livereload server that serves your files, compiling HTML, CoffeeScript, LESS, and image files as you update them.
3. Run `gulp build --env production` to build for production.


[Gulp]: http://gulpjs.com
[nodejs]: http://nodejs.org
[bower]: http://bower.io
