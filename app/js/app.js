const Web3 = require("web3");
const Promise = require("bluebird");
// require("Splitter"); ??
const truffleContract = require("truffle-contract");
const $ = require("jquery");
// Not to forget our built contract
const metaCoinJson = require("../../build/contracts/Splitter.json");

// Supports Metamask, and other wallets that provide / inject 'web3'.
if (typeof web3 !== 'undefined') {
    // Use the Mist/wallet/Metamask provider.
    window.web3 = new Web3(web3.currentProvider);
} else {
    // Your preferred fallback.
    window.web3 = new Web3(new Web3.providers.HttpProvider('http://localhost:8545')); 
}
// splittreJson???
const Splitter = truffleContract(splitterJson);
Splitter.setProvider(web3.currentProvider);

window.addEventListener('load', function() {
    return web3.eth.getAccounts()
        .then(accounts => {
            if (accounts.length == 0) {
                $("#balance").html("N/A");
                throw new Error("No account with which to transact");
            }
            window.account = accounts[0];
            console.log("Account:", window.account);
            return web3.eth.net.getId();
        })
        .then(network => {
            console.log("Network:", network.toString(10));
            return Splitter.deployed();
        })
        .then(deployed => deployed.getBalance.call(window.account))
        // Notice how the conversion to a string is done only when displaying.
        .then(balance => $("#balance").html(balance.toString(10)))
        // Never let an error go unlogged.
        .catch(console.error);
});