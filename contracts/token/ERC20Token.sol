pragma solidity ^0.4.15;

import "zeppelin-solidity/contracts/math/SafeMath.sol";
import "./abstract/ERC20Interface.sol";


contract ERC20Token is ERC20Interface {

    using SafeMath for uint;

    mapping (address => uint) balances;
    mapping (address => mapping (address => uint)) allowed;

    // Check for 'size' input arguments
    // https://blog.coinfabrik.com/smart-contract-short-address-attack-mitigation-failure/
    modifier onlyPayloadSize(uint size) {
        require(msg.data.length == (size * 32 + 4));
        _;
    }

    function balanceOf(address _owner) public constant returns (uint balance) {
        return balances[_owner];
    }

    function allowance(address _owner, address _spender) public constant returns (uint remaining) {
        return allowed[_owner][_spender];
    }

    function approve(address _spender, uint _value) public returns (bool) {
        require((_value == 0) || (allowed[msg.sender][_spender] == 0));
        require(_value <= balances[msg.sender]);
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }

    function transfer(address _to, uint _value) public onlyPayloadSize(2) returns (bool success) {
        _transferFrom(msg.sender, _to, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint _value) public onlyPayloadSize(3) returns (bool) {
        // TODO: Revert _value if we have some problems with transfer
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
        _transferFrom(_from, _to, _value);
        return true;
    }

    function _transferFrom(address _from, address _to, uint _value) internal {
        require(_to != address(0)); // Use burnTokens for this case
        require(_value > 0);
        balances[_from] = balances[_from].sub(_value);
        balances[_to] = balances[_to].add(_value);
        Transfer(_from, _to, _value);
    }
}
