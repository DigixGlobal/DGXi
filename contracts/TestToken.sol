pragma solidity ^0.4.8;

import 'zeppelin-solidity/contracts/token/MintableToken.sol';

contract TestToken is MintableToken {
  function TestToken () {
    balances[msg.sender] = 5 ether;
  }
}
