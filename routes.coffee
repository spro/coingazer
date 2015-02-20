React = require 'react'
Router = require 'react-router'
{Route, DefaultRoute} = Router
{
    AppView,
    HomeView,
    CoinView,
    CoinSummaryView,
    CoinRelatedView
    CoinEditView
} = require './static/js/components'

routes =
    <Route name="app" path="/" handler={AppView}>
        <DefaultRoute name="home" handler={HomeView} />
        <Route name="coin" path="coins/:coin_symbol" handler={CoinView}>
            <DefaultRoute name="coin_summary" handler={CoinSummaryView} />
            <Route name="coin_related" path="related" handler={CoinRelatedView} />
            <Route name="coin_edit" path="edit" handler={CoinEditView} />
        </Route>
    </Route>

renderElement = (el) ->
    Router.run routes, Router.HistoryLocation, (Handler) ->
        React.render(<Handler />, el)

renderString = (url, cb) ->
    Router.run routes, url, (Handler) ->
        cb null, React.renderToString(<Handler />)

module.exports = {renderElement, renderString}

