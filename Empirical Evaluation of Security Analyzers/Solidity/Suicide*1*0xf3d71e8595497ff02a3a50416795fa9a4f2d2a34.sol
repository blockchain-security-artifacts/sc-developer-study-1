pragma solidity ^0.4.15;


library SafeMath {
  function mul(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function add(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}

contract Token {

    
    

    
    
    function balanceOf(address _owner) constant returns (uint256 balance);

    
    
    
    
    function transfer(address _to, uint256 _value) returns (bool success);

    
    
    
    
    
    function transferFrom(address _from, address _to, uint256 _value) returns (bool success);

    
    
    
    
    function approve(address _spender, uint256 _value) returns (bool success);

    
    
    
    function allowance(address _owner, address _spender) constant returns (uint256 remaining);

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
    
}



contract StandardToken is Token {

    function transfer(address _to, uint256 _value) returns (bool success) {
        
        
        
        
        if (balances[msg.sender] >= _value && _value > 0) {
            balances[msg.sender] -= _value;
            balances[_to] += _value;
            Transfer(msg.sender, _to, _value);
            return true;
        } else { return false; }
    }

    function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {
        
        
        if (balances[_from] >= _value && allowed[_from][msg.sender] >= _value && _value > 0) {
            balances[_to] += _value;
            balances[_from] -= _value;
            allowed[_from][msg.sender] -= _value;
            Transfer(_from, _to, _value);
            return true;
        } else { return false; }
    }

    function balanceOf(address _owner) constant returns (uint256 balance) {
        return balances[_owner];
    }

    function approve(address _spender, uint256 _value) returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
      return allowed[_owner][_spender];
    }

    mapping (address => uint256) balances;
    mapping (address => mapping (address => uint256)) allowed;
    uint256 public totalSupply;
}



contract MRAToken is StandardToken {

    function () {
        
        revert();
    }

    

    
    string public name;                   
    uint8 public decimals;                
    string public symbol;                 
    string public version = 'H1.0';       







    function MRAToken(
        ) {
        decimals = 18; 
        totalSupply = 100000000 * (10 ** uint256(decimals));                        
        balances[msg.sender] = totalSupply;               
        name = "MRAToken";                                   
        symbol = "MRAT";                               
    }

    
    function approveAndCall(address _spender, uint256 _value, bytes _extraData) returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);

        
        
        
        if(!_spender.call(bytes4(bytes32(sha3("receiveApproval(address,uint256,address,bytes)"))), msg.sender, _value, this, _extraData)) { revert(); }
        return true;
    }
}



contract Ownable {
  address public owner;


  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


  
  function Ownable() {
    owner = msg.sender;
  }


  
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }


  
  function transferOwnership(address newOwner) onlyOwner public {
    require(newOwner != address(0));
    OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

}


contract Crowdsale is Ownable {
  using SafeMath for uint256;

  
  MRAToken public token;

  


  uint256 public startTime = 1510721999;
  uint256 public phase_1_Time = 1512104399;
  uint256 public phase_2_Time = 1513400399;
  uint256 public phase_3_Time = 1514782799;
  uint256 public phase_4_Time = 1516078799;
  uint256 public phase_5_Time = 1517461199;
  uint256 public endTime = 1518757199;
  
  
  
  address public wallet;

  
  uint256 public phase_1_rate = 28900;
  uint256 public phase_2_rate = 1156;
  uint256 public phase_3_rate = 760;
  uint256 public phase_4_rate = 545;
  uint256 public phase_5_rate = 328;
  uint256 public phase_6_rate = 231;
  
  
  uint256 public weiRaised;

  mapping (address => uint256) rates;

  function getRate() constant returns (uint256){
    uint256 current_time = now;

    if(current_time > startTime && current_time < phase_1_Time){
      return phase_1_rate;
    }
    else if(current_time > phase_1_Time && current_time < phase_2_Time){
      return phase_2_rate;
    }
      else if(current_time > phase_2_Time && current_time < phase_3_Time){
      return phase_3_rate;
    }
      else if(current_time > phase_3_Time && current_time < phase_4_Time){
      return phase_4_rate;
      
      }  
      else if(current_time > phase_4_Time && current_time < phase_5_Time){
      return phase_5_rate;
    }else{
      return phase_6_rate;
    }
  }

  
  event TokenPurchase(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);


  function Crowdsale() {
    wallet = msg.sender;
    token = createTokenContract();
  }

  
  
  function createTokenContract() internal returns (MRAToken) {
    return new MRAToken();
  }


  
  function () payable {
    buyTokens(msg.sender);
  }

  
  function buyTokens(address beneficiary) public payable {
    require(beneficiary != 0x0);
    require(validPurchase());

    uint256 weiAmount = msg.value;

    
    uint256 tokens = weiAmount.mul(getRate());

    
    weiRaised = weiRaised.add(weiAmount);

    token.transfer(beneficiary, tokens);
    TokenPurchase(msg.sender, beneficiary, weiAmount, tokens);

    forwardFunds();
  }

  
  
  function forwardFunds() internal {
    wallet.transfer(msg.value);
  }

  
  function validPurchase() internal constant returns (bool) {
    bool withinPeriod = now >= startTime && now <= endTime;
    bool nonZeroPurchase = msg.value != 0;
    return withinPeriod && nonZeroPurchase;
  }

  
  function hasEnded() public constant returns (bool) {
    return now > endTime;
  }
  

 function destroy() onlyOwner {
     
     uint256 balance = token.balanceOf(this);
     assert (balance > 0);
     token.transfer(owner,balance);
     
     
     selfdestruct(owner);
     
 }

}