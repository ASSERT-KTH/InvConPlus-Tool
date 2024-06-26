pragma solidity ^0.5.10;

import "./VeriSolContracts.sol";

contract FilxToken {
    event Transfer(address indexed _from, address indexed _to, uint256 _value);

    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

    string public name = "FILX Token";
    string public symbol = "FILX";
    uint256 public totalSupply;
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    constructor(uint256 _initialSupply) public {
        balanceOf[msg.sender] = _initialSupply;
        totalSupply = _initialSupply;
    }

    function transfer(address _to, uint256 _value) public returns (bool success) {
        //Begin of assumptions
        VeriSol.AssumesBeginningOfFunction(msg.sender != address(0));
        //End of assumptions
        //Begin of invariants
        VeriSol.Ensures(msg.sender != address(0));
        VeriSol.Ensures(_value <= VeriSol.Old(balanceOf[msg.sender]));
        VeriSol.Ensures(balanceOf[_to] >= VeriSol.Old(balanceOf[_to]));
        VeriSol.Ensures(VeriSol.Old(totalSupply) == totalSupply);
        VeriSol.Ensures(VeriSol.Old(balanceOf[msg.sender]) >= balanceOf[msg.sender]);
        VeriSol.Ensures(VeriSol.SumMapping(balanceOf) == VeriSol.Old(VeriSol.SumMapping(balanceOf)));
        //End of invariants
        require(_value >= balanceOf[msg.sender], "Not enough balance");
        balanceOf[msg.sender] -= _value;
        balanceOf[_to] += _value;
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    function approve(address _spender, uint256 _value) public returns (bool success) {
        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(balanceOf[_from] >= _value, "_from does not have enough tokens");
        require(allowance[_from][msg.sender] >= _value, "Spender limit exceeded");
        balanceOf[_from] -= _value;
        balanceOf[_to] += _value;
        allowance[_from][msg.sender] -= _value;
        emit Transfer(_from, _to, _value);
        return true;
    }

    function contractInvariant() private view {
        VeriSol.ContractInvariant(totalSupply == VeriSol.SumMapping(balanceOf));
    }
}