pragma solidity ^0.4.15;

/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */

contract ERC20Interface {

    /* This is a slight change to the ERC20 base standard.
    function totalSupply() constant returns (uint totalSupply);
    is replaced with:
    uint public totalSupply;
    This automatically creates a getter function for the totalSupply.
    This is moved to the base contract since public getter functions are not
    currently recognised as an implementation of the matching abstract
    function by the compiler.
    */
    /// Total amount of tokens
    uint public totalSupply;

    /**
     * @dev Get the account balance of another account with address _owner
     * @param _owner address The address from which the balance will be retrieved
     * @return uint The balance
     */
    function balanceOf(address _owner) public constant returns (uint balance);

    /**
     * @dev Send _value amount of tokens to address _to from `msg.sender`
     * @param _to The address of the recipient
     * @param _value The amount of token to be transferred
     * @return Whether the transfer was successful or not
     */
    function transfer(address _to, uint _value) public returns (bool success);

    /**
     * @dev Send _value amount of tokens from address _from to address _to
     * @param _from address The address which you want to send tokens from
     * @param _to address The address which you want to transfer to
     * @param _value uint the amount of tokens to be transferred
     * @return Whether the transfer was successful or not
     */
    function transferFrom(address _from, address _to, uint _value) public returns (bool success);

    /**
     * @dev Allow _spender to withdraw from your account, multiple times, up to the _value amount
     * If this function is called again it overwrites the current allowance with _value.
     * this function is required for some DEX functionality
     *
     * @param _spender The address of the account able to transfer the tokens
     * @param _value The amount of tokens to be approved for transfer
     */
    function approve(address _spender, uint _value) public returns (bool success);

    /**
     * @dev Returns the amount which _spender is still allowed to withdraw from _owner
     * @param _owner The address of the account owning tokens
     * @param _spender The address of the account able to transfer the tokens
     * @return A uint specifying the amount of tokens still available for the spender.
     */
    function allowance(address _owner, address _spender) public constant returns (uint remaining);

    /// Triggered when tokens are transferred.
    event Transfer(address indexed _from, address indexed _to, uint _value);
    /// Triggered whenever approve(address _spender, uint _value) is called.
    event Approval(address indexed _owner, address indexed _spender, uint _value);
    /// Triggered when _value of tokens are minted for _owner
    event Mint(address _owner, uint _value);
    /// Triggered when mint finished
    event MintFinished();
    /// This notifies clients about the amount burnt
    event Burn(address indexed _from, uint _value);
}
