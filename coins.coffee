coins = [
    symbol: 'BTC'
    name: 'Bitcoin'
    date: '2009/01/03'
    notes: """
Satoshi Nakamoto described his invention as "A Peer-to-Peer Electronic Cash System". Bitcoin has been shown to effectively solve the problems that arise from a trust-less and scalable electronic cash system by using a peer-to-peer, distributed ledger, the Bitcoin block chain.

The block chain is a distributed database -- in order to independently verify the chain of ownership of every bitcoin, each network node stores its own copy of the block chain. Approximately six times per hour, a new group of accepted transactions (a block) is created, added to the block chain, and published to all nodes
"""
,
    symbol: 'NMC'
    name: 'Namecoin'
    date: '2011/04/18'
    notes: """
The first fork of Bitcoin. The primary difference from Bitcoin is that Namecoin offers the ability to store data within its blockchain. Namecoin extends Bitcoin to add transactions for registering, updating and transferring domain names and other key-value records.

Proposed uses for Namecoin include:

* Identity systems
* Messaging systems
* Personal namespaces
* Notary/timestamp systems
* Alias systems
* Issuance of shares/stocks
"""
,
    symbol: 'PPC'
    name: 'Peercoin'
    date: '2013/07/04'
    notes: "Peercoin's major distinguishing feature is that it uses a hybrid proof-of-stake/proof-of-work system. The proof-of-stake system was designed to address vulnerabilities that could occur in a pure proof-of-work system."
,
    symbol: 'LTC'
    name: 'Litecoin'
    date: '2011/10/07'
    notes: "The Litecoin network aims to process a block every 2.5 minutes, rather than Bitcoin's 10 minutes, which its developers claim allows for faster transaction confirmation. The drawbacks of faster block times are increased blockchain size, and an increase in the number of orphaned blocks."
]

getCoin = (symbol) ->
    for coin in coins
        if coin.symbol == symbol
            return coin

module.exports = {coins, getCoin}
