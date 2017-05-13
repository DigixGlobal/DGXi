const DGXi = artifacts.require('DGXi');
const { wait } = require('@digix/tempo')(web3);

const day = 60 * 60 * 24;
const year = 365 * day;

contract('DGXi', function (accounts) {
  let dgxi;
  beforeEach(async function () {
    dgxi = await DGXi.new({ from: accounts[0] });
  });
  describe('withdraw rate', function () {
    it('withdraw rate is correct', async function () {
      assert.equal((await dgxi.withdrawRate.call(1000000000)).toNumber(), 1000000000);
      await wait(year);
      assert.equal((await dgxi.withdrawRate.call(1000000000)).toNumber(), 993795000);
    });
  });
  describe('deposit rate', function () {
    it('deposite rate is correct', async function () {
      assert.equal((await dgxi.depositRate.call(1000000000)).toNumber(), 1000000000);
      await wait(year);
      assert.equal((await dgxi.depositRate.call(1000000000)).toNumber(), 1006205000);
    });
  });
});
