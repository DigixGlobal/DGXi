pragma solidity ^0.4.8;

import 'zeppelin-solidity/contracts/SafeMath.sol';
import 'zeppelin-solidity/contracts/token/StandardToken.sol';

/// @title Inflationary ERC20 Wrapper Contract
/// @author Hitchcott

/*
demurrage calculation

b = (a / m) * (r * t)

Where:
b = Effective DGX balance in nanograms (return value of ERC-20     balanceOf(account))
a = Actual DGX balance in nanograms on the ledger (withdraw amount)
m = Minimum balance for demurrage calculation (constant value at 1 milligram or 1000000 nanograms)
t = Number of days since last demurrage deduction
r = Daily demurrage per 1 milligram (16.6666666666 rounded up to 17)
*/


contract DGXi is StandardToken {

  string public name = "Digix Gold Inflationary Fee Token";
  string public symbol = "DGXi";
  uint public decimals = 9;
  uint public INITIAL_SUPPLY = 0;

  StandardToken dgxContract;

  uint public startingDate;
  address public dgxAddress;
  uint public dailyDemurragePerMg;

  event Deposit(address indexed from, address indexed to, uint dgx, uint dgxi);
  event Withdraw(address indexed from, address indexed to, uint dgx, uint dgxi);

  function DGXi(address _dgxAddress, uint _dailyDemurrage) {
    totalSupply = INITIAL_SUPPLY;
    dgxAddress = _dgxAddress;
    dgxContract = StandardToken(dgxAddress);
    dailyDemurragePerMg = _dailyDemurrage;
    startingDate = block.timestamp;
  }

  function calculateDemurrageFee(uint _dgxiValue) returns (uint _dgxValue) {
    var preiodSeconds = SafeMath.sub(block.timestamp, startingDate);
    var preiodDays = SafeMath.div(preiodSeconds, 1 days);
    var fee = SafeMath.mul(SafeMath.div(_dgxiValue, 1000000), SafeMath.mul(dailyDemurragePerMg, preiodDays));
    return fee;
  }

  function dgxiToDgx(uint _dgxiValue) returns (uint _dgxValue) {
    return SafeMath.sub(_dgxiValue, calculateDemurrageFee(_dgxiValue));
  }

  function dgxToDgxi(uint _dgxValue) returns (uint _dgxiValue) {
    return SafeMath.add(_dgxValue, calculateDemurrageFee(_dgxValue));
  }

  function depositDgx(uint _dgxValue, address _recipient) {
    // calculate the rate from DGX into DGXi
    var dgxiValue = dgxToDgxi(_dgxValue);
    // transfer dgx from other contract
    dgxContract.transferFrom(msg.sender, address(this), _dgxValue);
    // emit event
    Deposit(msg.sender, _recipient, _dgxValue, dgxiValue);
    // update the balance of the recipient
    balances[_recipient] = SafeMath.add(balances[_recipient], dgxiValue);
  }

  function redeemDgxi(uint _dgxiValue, address _recipient) {
    // throw if sender does not have enough lanace
    if (balances[msg.sender] < _dgxiValue) { throw; }
    // calculate the rate from DGX into DGXi
    var dgxValue = dgxiToDgx(_dgxiValue);
    // call the other contract send it
    dgxContract.transfer(_recipient, dgxValue);
    // emit event
    Withdraw(msg.sender, _recipient, dgxValue, _dgxiValue);
    // update the balance of the recipient
    balances[msg.sender] = SafeMath.sub(balances[msg.sender], _dgxiValue);
  }
}
