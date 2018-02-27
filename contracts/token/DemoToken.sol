pragma solidity ^0.4.15;

import "./ERC20Token.sol";
import "./abstract/TokenReceiver.sol";
import "./abstract/Burnable.sol";
import "zeppelin-solidity/contracts/ownership/Ownable.sol";
import "zeppelin-solidity/contracts/math/SafeMath.sol";


contract DemoToken is ERC20Token, Ownable, Burnable {

    using SafeMath for uint;

    string public name = "DEMO TOKEN";          // Original name
    string public symbol = "DT";                // Token identifier
    uint8 public decimals = 4;                  // How many decimals to show
    bool public mintingFinished = false;        // Status of minting

    event Transfer(address indexed _from, address indexed _to, uint _value, bytes _data);

    function DemoToken() public {
        balances[this] = 0;
        totalSupply = 0;
    }

    /**
     * @dev Function to mint tokens
     * @param target The address that will receive the minted tokens
     * @param mintedAmount The amount of tokens to mint
     * @return A boolean that indicates if the operation was successful
     */
    function mintTokens(address target, uint mintedAmount) public onlyOwner returns (bool success) {
        require(!mintingFinished); // Can minting
        totalSupply = totalSupply.add(mintedAmount);
        balances[target] = balances[target].add(mintedAmount);
        Mint(target, mintedAmount);
        return true;
    }

    /**
     * @dev Function to stop minting new tokens
     * @return A boolean that indicates if the operation was successful
     */
    function finishMinting() public onlyOwner returns (bool success) {
        mintingFinished = true;
        MintFinished();
        return true;
    }

    /**
    * @dev Function that is called when a user or another contract wants
    *  to transfer funds .
    * @return A boolean that indicates if the operation was successful
    */
    function transfer(address _to, uint _value) public onlyPayloadSize(2) returns (bool success) {
        if (isContract(_to)) {
            return _transferToContract(msg.sender, _to, _value);
        } else {
            _transferFrom(msg.sender, _to, _value);
            return true;
        }
    }

    /**
     * @dev Function to burns a specific amount of tokens.
     * @param _value The amount of token to be burned.
     * @return A boolean that indicates if the operation was successful
     */
    function burnTokens(uint _value) public returns (bool success) {
        require(balances[msg.sender] >= _value);
        totalSupply = totalSupply.sub(_value);
        balances[msg.sender] = balances[msg.sender].sub(_value);
        Burn(msg.sender, _value);
        return true;
    }

    /**
     * @dev Function to burns a specific amount of tokens from another account that `msg.sender`
     * was approved to burn tokens for using `approve` earlier.
     * @param _from The address to burn tokens from.
     * @param _value The amount of token to be burned.
     * @return A boolean that indicates if the operation was successful
     */
    function burnFrom(address _from, uint _value) public returns (bool success) {
        require(_value > 0);
        require(_value <= balances[_from]);
        require(_value <= allowed[_from][msg.sender]);

        balances[_from] = balances[_from].sub(_value);
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
        totalSupply = totalSupply.sub(_value);

        Burn(_from, _value);
    }

    //assemble the given address bytecode. If bytecode exists then the _addr is a contract.
    function isContract(address _addr) private returns (bool is_contract) {
        uint length;
        assembly {
             //retrieve the size of the code on target address, this needs assembly
             length := extcodesize(_addr)
        }
        return (length > 0);
     }

   /**
    * @dev Function that is called when a user or another contract wants
    *  to transfer funds to smart-contract
    * @return A boolean that indicates if the operation was successful
    */
    function _transferToContract(address _from, address _to, uint _value) private onlyPayloadSize(2) returns (bool success) {
        _transferFrom(msg.sender, _to, _value);
        TokenReceiver receiver = TokenReceiver(_to);
        receiver.tokenFallback(msg.sender, this, _value);
        return true;
    }
}
