const DGXi = artifacts.require('DGXi');
const SafeMath = artifacts.require('zeppelin-solidity/contracts/SafeMath.sol');

module.exports = function (deployer) {
  deployer.deploy(SafeMath);
  deployer.link(SafeMath, DGXi);
  deployer.deploy(DGXi);
};
