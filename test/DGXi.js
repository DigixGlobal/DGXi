const DGXi = artifacts.require('DGXi');
const { wait } = require('@digix/tempo')(web3);

const TestToken = artifacts.require('TestToken');

const day = 60 * 60 * 24;
const year = 365 * day;
const oneDgxYearFee = 6205000;

contract('DGXi', function (accounts) {
  let dgxi;
  let testToken;
  beforeEach(async function () {
    testToken = await TestToken.new();
    dgxi = await DGXi.new(testToken.address, 17);
    await testToken.approve(dgxi.address, 3e9);
  });
  describe('dgxiToDgx', function () {
    it('withdraw rate is correct', async function () {
      assert.equal((await dgxi.dgxiToDgx.call(1e9)).toNumber(), 1e9);
      await wait(year);
      assert.equal((await dgxi.dgxiToDgx.call(1e9)).toNumber(), 1e9 - oneDgxYearFee);
    });
  });
  describe('dgxToDgxi', function () {
    it('dopsit rate is correct', async function () {
      assert.equal((await dgxi.dgxToDgxi.call(1e9)).toNumber(), 1e9);
      await wait(year);
      assert.equal((await dgxi.dgxToDgxi.call(1e9)).toNumber(), 1e9 + oneDgxYearFee);
    });
  });
  describe('depositDgx', function () {
    it('deposits DGX in exchange for DGXi', async function () {
      const beforeBalances = [
        await dgxi.balanceOf.call(accounts[0]),
        await testToken.balanceOf.call(accounts[0]),
      ];
      await dgxi.depositDgx(1e9, accounts[0]);
      assert.equal(await dgxi.balanceOf.call(accounts[0]), beforeBalances[0].add(1e9).toNumber());
      assert.equal(await testToken.balanceOf.call(accounts[0]), beforeBalances[1].sub(1e9).toNumber());
      await wait(year);
      await dgxi.depositDgx(1e9, accounts[0]);
      assert.equal(await dgxi.balanceOf.call(accounts[0]), beforeBalances[0].add(2e9).add(oneDgxYearFee).toNumber());
      assert.equal(await testToken.balanceOf.call(accounts[0]), beforeBalances[1].sub(2e9).toNumber());
    });
  });
  describe('redeemDgxi', function () {
    it('redeems DGXi for DGX', async function () {
      const beforeBalances = [
        await dgxi.balanceOf.call(accounts[0]),
        await testToken.balanceOf.call(accounts[0]),
      ];
      await dgxi.depositDgx(3e9, accounts[0]);
      assert.equal(await dgxi.balanceOf.call(accounts[0]), beforeBalances[0].add(3e9).toNumber());
      assert.equal(await testToken.balanceOf.call(accounts[0]), beforeBalances[1].sub(3e9).toNumber());
      await dgxi.redeemDgxi(1e9, accounts[0]);
      assert.equal(await dgxi.balanceOf.call(accounts[0]), beforeBalances[0].add(2e9).toNumber());
      assert.equal(await testToken.balanceOf.call(accounts[0]), beforeBalances[1].sub(2e9).toNumber());
      await wait(year);
      await dgxi.redeemDgxi(1e9, accounts[0]);
      assert.equal(await dgxi.balanceOf.call(accounts[0]), beforeBalances[0].add(1e9).toNumber());
      assert.equal(await testToken.balanceOf.call(accounts[0]), beforeBalances[1].sub(1e9).sub(oneDgxYearFee).toNumber());
    });
  });
});
