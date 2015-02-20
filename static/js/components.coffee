$ = require 'jquery'
_ = require 'underscore'
React = require 'react/addons'
Router = require 'react-router'
Kefir = require 'kefir'
marked = require 'marked'

{Link, RouteHandler} = Router
cx = React.addons.classSet

coin_symbols = ['BTC', 'NMC', 'PPC', 'LTC']

# Stores
# ------------------------------------------------------------------------------

# A get that doesn't try getting when there's no window (e.g. iso-rendering)
safeGet = (url, cb) ->
    if !window?
        cb null
    else
        $.get url, cb

# Stream helpers for store outputs
getStream = (url) ->
    Kefir.fromCallback(safeGet.bind null, url)

postStream = (url, data) ->
    Kefir.fromCallback($.post.bind null, url, data)

immediateStream = (obj) ->
    Kefir.later(0, obj)

CoinStore =
    coins: {}

    getCoin: (symbol) ->
        if coin = CoinStore.coins[symbol]
            immediateStream coin
        else
            getStream("/coins/#{symbol}.json")
                .map (c) -> CoinStore.coins[symbol] = c

    getCoinPrice: (symbol) ->
        getStream("/coins/#{symbol}/price.json")
            .map (p) -> parseFloat p

    saveNotes: (symbol, notes) ->
        CoinStore.coins[symbol]?.notes = notes
        postStream "/coins/#{symbol}/notes.json", {notes}

# Views
# ------------------------------------------------------------------------------

AppView = React.createClass
    render: ->
        <div>
            <h1><Link to="home">Coingazer</Link></h1>
            <Navigation className='header' />
            <RouteHandler />
            <Navigation className='footer' />
        </div>

Navigation = React.createClass

    # Build a classObj by extending default w/ passed className and/or classObj
    getClassObj: ->
        classObj = 'tabs': true
        classObj[@props.className] = true if @props.className
        _.extend classObj, @props.classObj if @props.classObj
        classObj

    render: ->
        <ul className={cx @getClassObj()}>
            {coin_symbols.map (symbol) ->
                <li key={symbol}><CoinLink symbol={symbol} /></li>}
        </ul>

CoinLink = React.createClass
    render: ->
        <Link to="coin" params={coin_symbol: @props.symbol}>{@props.symbol}</Link>

HomeView = React.createClass
    render: ->
        <div>
            <p>Welcome to Coingazer. Learn Bitcoin and various forks as a way to pass the time. My favorite is <CoinLink symbol="NMC" />.</p>
        </div>

CoinView = React.createClass
    mixins: [Router.State]
    getInitialState: ->
        loading: true
        coin: null

    componentDidMount: -> @startLoading()
    componentWillReceiveProps: ->
        console.log 'CoinView componentWillReceiveProps', @state, @getParams()
        if @state.coin?.symbol != @getParams().coin_symbol
            @startLoading()
    componentWillUnmount: -> @stopLoading()

    startLoading: ->
        @setState loading: true
        symbol = @getParams().coin_symbol
        @loading_stream = CoinStore.getCoin symbol
        @loading_stream.onValue @endLoading

    endLoading: (coin) ->
        console.log 'dis is', coin
        @setState {loading: false, coin}

    stopLoading: ->
        @loading_stream.offValue @endLoading if @loading_stream?

    render: ->
        if @state.loading
            return <em>Loading..</em>

        coin = @state.coin
        <div>
            <h2>{coin.name} ({coin.symbol})</h2>
            <ul className="tabs">
                <li><Link to="coin_summary" params={{coin_symbol: coin.symbol}}>Summary</Link></li>
                <li><Link to="coin_related" params={{coin_symbol: coin.symbol}}>Related</Link></li>
                <li><Link to="coin_edit" params={{coin_symbol: coin.symbol}}>Edit</Link></li>
            </ul>
            <RouteHandler coin=coin />
        </div>

CoinSummaryView = React.createClass
    render: ->
        coin = @props.coin
        <div>
            <p><em>Announced {coin.date}</em> &mdash; <CoinPriceView symbol={coin.symbol} /></p>
            <MarkdownText text={coin.notes} />
        </div>

MarkdownText = React.createClass
    render: ->
        <div dangerouslySetInnerHTML={__html: marked @props.text} />

CoinEditView = React.createClass
    getInitialState: ->
        saving: false

    saveNotes: (text) ->
        @setState saving: true
        coin_symbol = @props.coin.symbol
        saving_stream = CoinStore.saveNotes coin_symbol, text
        saving_stream.onValue @stopSaving

    stopSaving: ->
        @setState saving: false

    render: ->
        coin = @props.coin
        <EditingText text={coin.notes} onSave={@saveNotes} saving={@state.saving} />

EditingText = React.createClass
    getInitialState: ->
        text: @props.text

    changeValue: (e) ->
        @setState text: e.target.value

    onSave: ->
        @props.onSave?(@state.text)

    render: ->
        <div>
            <textarea value={@state.text} onChange={@changeValue} />
            <a className="right button" onClick={@onSave}>{if @props.saving then 'Saving...' else 'Save'}</a>
        </div>

CoinPriceView = React.createClass
    getInitialState: ->
        loading: true
        price: 0.0

    componentDidMount: ->
        console.log 'CoinPriceView componentDidMount'
        @startLoading @props.symbol
    componentWillReceiveProps: (nextProps) ->
        console.log 'CoinPriceView componentWillReceiveProps', nextProps
        @startLoading nextProps.symbol
    componentWillUnmount: ->
        @stopLoading()

    startLoading: (symbol) ->
        @setState loading: true
        @stopLoading()
        @loading_stream = CoinStore.getCoinPrice symbol
        @loading_stream.onValue @endLoading

    stopLoading: ->
        @loading_stream.offValue @endLoading if @loading_stream?

    endLoading: (price) ->
        @setState
            loading: false
            price: price

    render: ->
        if @state.loading
            <em>Loading...</em>
        else
            <strong>1 {@props.symbol} = ${@state.price.toFixed(4)}</strong>

CoinRelatedView = React.createClass
    render: ->
        <ul>
            {_.sample(coin_symbols, Math.round(coin_symbols.length*Math.random())).map (s) ->
                <li key={s}><CoinLink symbol={s} /></li>}
        </ul>

module.exports = {
    AppView
    HomeView
    CoinView
    CoinSummaryView
    CoinRelatedView
    CoinEditView
}

