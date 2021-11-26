
require('chai')
    .use(require('chai-as-promised'))
    .should()
const truffleAssert = require('truffle-assertions');


contract('BlackHole', ([owner, player1Address, player2Address]) => {

    beforeEach(async () => {
        console.log("- NEW CONTRACT -")
    })

    afterEach(async () => {
    });

    describe('BlackHole deployment', async () => {
        it('BlackHole game setup', async () => {
        })
    })
})