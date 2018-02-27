pragma solidity ^0.4.15;

import "./ERC20Interface.sol";


contract Burnable is ERC20Interface {

  /**
   * @dev Function to burns a specific amount of tokens.
   * @param _value The amount of token to be burned.
   * @return A boolean that indicates if the operation was successful
   */
  function burnTokens(uint _value) public returns (bool success);

  /**
   * @dev Function to burns a specific amount of tokens from another account that `msg.sender`
   * was approved to burn tokens for using `approve` earlier.
   * @param _from The address to burn tokens from.
   * @param _value The amount of token to be burned.
   * @return A boolean that indicates if the operation was successful
   */
  function burnFrom(address _from, uint _value) public returns (bool success);
}
