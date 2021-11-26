module.exports = class Utils {

    static eth(n) {
        return web3.utils.toWei(n, 'ether');
    }

    static finney(n) {
        return web3.utils.toWei(n, 'finney');
    }

    static finneyInt(n) {
        return parseInt(web3.utils.toWei(n, 'finney'));
    }

    static nullAddress() {
        return '0x0000000000000000000000000000000000000000';
    }
}