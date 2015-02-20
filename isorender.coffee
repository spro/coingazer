require('node-cjsx').transform()

{renderString} = require './routes'

react_router_renderer = (req, res) ->
    renderString req.url, (err, body) ->
        res.render 'base', content: body

module.exports = react_router_renderer

