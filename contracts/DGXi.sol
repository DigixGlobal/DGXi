pragma solidity ^0.4.8;

import 'zeppelin-solidity/contracts/SafeMath.sol';
import 'zeppelin-solidity/contracts/token/SimpleToken.sol';
/// @title Extended ERC20 Contract
/// @author Digix Global

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


contract DGXi is SimpleToken {
  // metadata & config
  string public name = "Digix Gold Inflationary Fee Token";
  string public symbol = "DGXi";
  uint public decimals = 9;
  uint public INITIAL_SUPPLY = 0;
  uint public startingDate;

  // demurrage config
  uint public dailyDemurragePerMg = 17;

  function DGXi() {
    startingDate = block.timestamp;
  }

  function calculateDemurrageFee (uint _dgxiAmount) returns (uint _dgxAmount) {
    var preiodSeconds = SafeMath.sub(block.timestamp, startingDate);
    var preiodDays = SafeMath.div(preiodSeconds, 1 days);
    var fee = SafeMath.mul(SafeMath.div(_dgxiAmount, 1000000), SafeMath.mul(dailyDemurragePerMg, preiodDays));
    return fee;
  }

  function withdrawRate (uint _dgxiAmount) returns (uint _dgxAmount) {
    return SafeMath.sub(_dgxiAmount, calculateDemurrageFee(_dgxiAmount));
  }

  function depositRate (uint _dgxAmount) returns (uint _dgxiAmount) {
    return SafeMath.add(_dgxAmount, calculateDemurrageFee(_dgxAmount));
  }

  /// @notice Deposit DGX
  function deposit (address _contract) returns (bool _success) {
    // increase the token supply
  }

}
