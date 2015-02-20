polar = require 'polar'
{getCoin} = require './coins'
{getPrice} = require './prices'

app = polar.setup_app
    port: 5555
    metaserve: compilers:
        css: require('metaserve-css-styl')()
        js: require('metaserve-js-coffee-reactify')(ext: 'coffee', uglify: false)

app.get /^\/[^\.]*$/, require('./isorender')

app.get '/coins/:symbol/price.json', (req, res) ->
    getPrice req.params.symbol, (err, price) ->
        res.end price

app.get '/coins/:symbol.json', (req, res) ->
    res.json getCoin req.params.symbol

app.post '/coins/:symbol/notes.json', (req, res) ->
    coin = getCoin req.params.symbol
    coin.notes = req.body.notes
    res.json success: true

app.start()

