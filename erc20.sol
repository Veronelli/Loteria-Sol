// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
pragma experimental ABIEncoderV2;

import "./safe-math.sol";

//Interfaz del token ERC20
interface IERC20{
    //Retorna la cantidad de tokens en existencia
    function totalSupply()external view returns(uint);
    
    //... la cantidad de tokens para una direccion indicada por parámetro
    function balanceOf(address) external view returns(uint);

    //... el numero de tokens que el spender podrá gastar del propietario (owner)
    function allowance(address,address) external view returns(uint);

    //... un valor booleano de la operacion indicada
    function transfer(address,uint) external  returns(bool);

    //... un valor booleano con el resultado de la operacion de gasto
    function approve(address, uint) external returns(bool); 

    //... con el resultado de la operacion
    function transferFrom(address, address, uint) external returns(bool);


}

// Mari ->      0x5B38Da6a701c568545dCfcB03FcB875f56beddC4
// Rona ->      0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2
// Juan ->      0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db
// Luiz ->      0x78731D3Ca6b7E34aC0F824c42a7cC18A495cabaB
// Male ->      0x617F2E2fD72FD9D5503197092aC168c91465E7f2
// Fede ->      0x17F6AD8Ef982297579C203069C1DbfFE4348c372
// Facu ->      0x5c6B0f7Bf3E7ce046039Bd8FABdfD3f9F5021678
// Bart ->      0x03C6FcED478cBbC9a4FAB34eF9f40767739D1Ff7

contract ERC20Basic is IERC20{
    string public constant name = "ERC-20FV";
    string public constant symbol = "FV";
    uint8 public constant decimal = 2;

    event Transfer(address indexed from,address indexed to,uint _amount);
    event Approval(address indexed _owner, address indexed _spender, uint _value);

    using SafeMath for uint;
    mapping(address => uint) balances;
    mapping (address => mapping(address=>uint)) allowed;
    uint totalSupply_;

    constructor(uint _initialSupply)public{
        totalSupply_ = _initialSupply;
        balances[msg.sender] = totalSupply_;
    }

    function myBalance()public view returns(uint){
        return balances[msg.sender];
    }

    function totalSupply()public override view returns(uint){
        return totalSupply_;
    }

    function increaseTotalSupply(uint newTotalAmount)public{
        totalSupply_ += newTotalAmount;
        balances[msg.sender] += newTotalAmount;
    }

    function balanceOf(address _account)public override view returns(uint){
            return balances[_account];
    
    }
    
    function allowance(address _owner,address _spender) public override view returns(uint){
        return allowed[_owner][_spender];
    
    }
    function transfer(address _recipient,uint _tokensNumber) public override returns(bool){
        require(balances[msg.sender] >= _tokensNumber,"Necesitas mas tokens");
        balances[msg.sender] = balances[msg.sender].sub(_tokensNumber);
        balances[_recipient] = balances[_recipient].add(_tokensNumber);
        emit Transfer(msg.sender,_recipient,_tokensNumber);

        return true;
    
    }

    function transferLoteria(address _cliente, address _recipient,uint _tokensNumber) public returns(bool){
        require(balances[_cliente] >= _tokensNumber,"Necesitas mas tokens");
        balances[_cliente] = balances[_cliente].sub(_tokensNumber);
        balances[_recipient] = balances[_recipient].add(_tokensNumber);
        emit Transfer(_cliente,_recipient,_tokensNumber);

        return true;
    
    }
        
    function approve(address _spender/*delegate*/, uint _amount) public override returns(bool){
        require(_amount<=balances[msg.sender],"Necesitas mas tokens");
        allowed[msg.sender][_spender] = _amount;
        emit Approval(msg.sender,_spender,_amount);
        
        return true;
    
    }
    
    function transferFrom(address _owner, address _buyer, uint _amount) public override returns(bool){
        require(_amount <= balances[_owner],"El Owner no tiene suficiente dinero");
        require(_amount <=  allowed[_owner][msg.sender],"El Spender no tiene suficiente dinero");
        
        balances[_owner] = balances[_owner].sub(_amount);
        allowed[_owner][msg.sender] = allowed[_owner][msg.sender].sub(_amount);
        balances[_buyer] = balances[_buyer].add(_amount);
        
        emit Transfer(_owner,_buyer,_amount);

        return true;

    }


}