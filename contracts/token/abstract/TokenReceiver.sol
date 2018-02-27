pragma solidity ^0.4.15;

contract TokenReceiver {
  function tokenFallback(address _sender, address _origin, uint _value) public returns (bool ok);
}
