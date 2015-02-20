request = require 'request'

getPrice = (symbol, cb) ->
    url = "https://api.exchange.coinbase.com/products/#{symbol}-USD/ticker"
    url = "https://www.eobot.com/api.aspx?coin=#{symbol}"
    headers = 'user-agent': 'price ticker'
    options = {url, headers}
    request.get options, (err, res, data) ->
        cb err, data

module.exports = {getPrice}
