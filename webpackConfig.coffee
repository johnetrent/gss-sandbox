module.exports =
  cache: true
  entry:
    index: 'index'
  output:
    publicPath: '/js/'
    filename: 'bundle.js'
  module:
    loaders: [
      {test: /jquery\.js$/, loader: 'expose?$!expose?jQuery'}
      {test: /\.coffee$/, loader: 'coffee-loader'}
    ]
  resolve:
    extensions: ['', '.js', '.litcoffee', '.coffee']
    alias:
      jquery: 'jquery/dist/jquery'
