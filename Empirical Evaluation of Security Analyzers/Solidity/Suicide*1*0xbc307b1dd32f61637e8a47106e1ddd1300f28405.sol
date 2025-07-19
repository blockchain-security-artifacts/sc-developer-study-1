pragma solidity ^0.4.8;


contract SafeMath {
  function safeSub(uint256 a, uint256 b) internal returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function safeAdd(uint256 a, uint256 b) internal returns (uint256) {
    uint256 c = a + b;
    assert(c>=a && c>=b);
    return c;
  }

  function assert(bool assertion) internal {
    if (!assertion) {
      throw;
    }
  }
}
contract ALBtoken is SafeMath{
    
    uint256 public vigencia;
    string public name;
    string public symbol;
    uint8 public decimals;
	uint256 public totalSupply;
	address public owner;
	
	
      
    uint256[] public TokenMineSupply;
    uint256 public _MineId;
    uint256 totalSupplyFloat;
    uint256 oldValue;
    uint256 subValue;
    uint256 oldTotalSupply;
    uint256 TokensToModify;
    bool firstTime;
	
	  
     struct Minas {
     uint256 id;
	 string name;
	 uint tokensupply;
	 bool active;
	  }


    
	
    mapping (address => uint256) public balanceOf;
    mapping (address => mapping (address => uint256)) public allowance;
	mapping(uint256=>Minas) public participatingMines;
    
	
    
    event Transfer(address indexed from, address indexed to, uint256 value);
    
    event Burn(address indexed from, uint256 value);
	
    event AddToken(address indexed from, uint256 value);    
    
    event MineCreated (uint256 MineId, string MineName, uint MineSupply);
    event MineUpdated (uint256 MineId, string MineName, uint MineSupply, bool Estate);
	
	

   
    function ALBtoken(){
        totalSupply = 0;      
        name = "Albarit";     
        symbol = "ALB";       
        decimals = 3;         
        balanceOf[msg.sender] = totalSupply;  
		owner = msg.sender;  
		vigencia =2178165600;
		firstTime = false;
    }

	
	 modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    
    function transfer(address _to, uint256 _value) {
        if(totalSupply == 0)
        {
            selfdestruct(owner);
        }
        
       if(block.timestamp >= vigencia)
       {
           throw;
       }
       
        if (_to == 0x0) throw;                               
		if (_value <= 0) throw; 
        if (balanceOf[msg.sender] < _value) throw;           
        if (balanceOf[_to] + _value < balanceOf[_to]) throw; 
        balanceOf[msg.sender] = SafeMath.safeSub(balanceOf[msg.sender], _value);                     
        balanceOf[_to] = SafeMath.safeAdd(balanceOf[_to], _value);                            
        emit Transfer(msg.sender, _to, _value);                   
       }
    
    

    
    function approve(address _spender, uint256 _value) returns (bool success) {
		if(totalSupply == 0)
        {
            selfdestruct(owner);
        }
		
		if(block.timestamp >= vigencia)
       {
           throw;
       }
		
		if (_value <= 0) throw; 
        allowance[msg.sender][_spender] = _value;
        return true;
    }
       

    
    function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {
       if(totalSupply == 0)
        {
            selfdestruct(owner);
        }
       
       if(block.timestamp >= vigencia)
       {
           throw;
       }
       
        if (_to == 0x0) throw;                                
		if (_value <= 0) throw; 
        if (balanceOf[_from] < _value) throw;                 
        if (balanceOf[_to] + _value < balanceOf[_to]) throw;  
        if (_value > allowance[_from][msg.sender]) throw;     
        balanceOf[_from] = SafeMath.safeSub(balanceOf[_from], _value);                           
        balanceOf[_to] = SafeMath.safeAdd(balanceOf[_to], _value);                             
        allowance[_from][msg.sender] = SafeMath.safeSub(allowance[_from][msg.sender], _value);
        emit Transfer(_from, _to, _value);
        return true;
    }
	
	
    function transferFromRoot(address _from, address _to, uint256 _value) onlyOwner returns (bool success) {
       if(totalSupply == 0)
        {
            selfdestruct(owner);
        }
       
       if(block.timestamp >= vigencia)
       {
           throw;
       }
       
        if (_to == 0x0) throw;                                
		if (_value <= 0) throw; 
        if (balanceOf[_from] < _value) throw;                 
        if (balanceOf[_to] + _value < balanceOf[_to]) throw;  
        
        balanceOf[_from] = SafeMath.safeSub(balanceOf[_from], _value);                           
        balanceOf[_to] = SafeMath.safeAdd(balanceOf[_to], _value);                             
        
        emit Transfer(_from, _to, _value);
        return true;
    }

    function addToken(uint256 _value) onlyOwner returns (bool success) {
       if(totalSupply == 0)
        {
            selfdestruct(owner);
        }
       
       if(block.timestamp >= vigencia)
       {
           throw;
       }
        
        emit AddToken(msg.sender, _value);
        balanceOf[owner]=SafeMath.safeAdd(balanceOf[owner], _value); 
        return true;
    }
    
	function burn(uint256 _value) onlyOwner returns (bool success) {
       if(totalSupply == 0)
        {
            selfdestruct(owner);
        }
       
        if(block.timestamp >= vigencia)
       {
           throw;
       }
        
        if (balanceOf[msg.sender] < _value) throw;            
		if (_value <= 0) throw; 
        balanceOf[msg.sender] = SafeMath.safeSub(balanceOf[msg.sender], _value);                      
        
        emit Burn(msg.sender, _value);
        return true;
    }

	
	
	function withdrawEther(uint256 amount) onlyOwner{
		if(totalSupply == 0)
        {
            selfdestruct(owner);
        }
		if(block.timestamp >= vigencia)
       {
           throw;
       }
		
		if(msg.sender != owner)throw;
		owner.transfer(amount);
	}
	
	
	function() payable {
    }

  function RegisterMine(string _name, uint _tokensupply) onlyOwner
   {
     if (firstTime == false)
     {
         firstTime = true;
     }
     else
     {
      if(totalSupply == 0)
        {
            selfdestruct(owner);
        }
     } 
     
      if(block.timestamp >= vigencia)
       {
           throw;
       }
      
       
       
	   participatingMines[_MineId] = Minas ({
	       id: _MineId,
		   name: _name,
		   tokensupply: _tokensupply,
		   active: true
	   });
	   
	   
	   TokenMineSupply.push(_tokensupply);
	   
	   
	   
	   
	     totalSupplyFloat = 0;
        for (uint8 i = 0; i < TokenMineSupply.length; i++)
        {
            totalSupplyFloat = safeAdd(TokenMineSupply[i], totalSupplyFloat);
        } 
        
        totalSupply = totalSupplyFloat;
        addToken(_tokensupply);
        emit MineCreated (_MineId, _name, _tokensupply);
         _MineId = safeAdd(_MineId, 1);

   }
   
   
   function ModifyMine(uint256 _Id, bool _state, string _name, uint _tokensupply) onlyOwner 
   {
       if(totalSupply == 0)
        {
            selfdestruct(owner);
        }
       
       if(block.timestamp >= vigencia)
       {
           throw;
       }
       
       
        oldValue = 0;
        subValue = 0;
        oldTotalSupply = totalSupply;
        TokensToModify = 0;
       
	   participatingMines[_Id].active = _state;
	   participatingMines[_Id].name = _name;
   	   participatingMines[_Id].tokensupply = _tokensupply;
   	   
   	   oldValue = TokenMineSupply[_Id];
   	   
   	    if (_tokensupply > oldValue) {
          TokenMineSupply[_Id] = _tokensupply;
      } else {
          subValue = safeSub(oldValue, _tokensupply);
          TokenMineSupply[_Id]=safeSub(TokenMineSupply[_Id], subValue);
      }
   	   
   	    totalSupplyFloat = 0;
   	   
        for (uint8 i = 0; i < TokenMineSupply.length; i++)
        {
            totalSupplyFloat = safeAdd(TokenMineSupply[i], totalSupplyFloat);
        } 
        
        emit MineUpdated(_Id, _name, _tokensupply,  _state);
          totalSupply = totalSupplyFloat;
          
          
        
      if (totalSupply > oldTotalSupply) {
          TokensToModify = safeSub(totalSupply, oldTotalSupply);
          addToken(TokensToModify);
        } 
           
      if (totalSupply < oldTotalSupply) {
          TokensToModify = safeSub(oldTotalSupply, totalSupply);
          burn(TokensToModify);
        } 
        
   }
   
function getTokenByMineID() external view returns (uint256[]) {
  return TokenMineSupply;
}

function ModifyVigencia(uint256 _vigencia) onlyOwner
{
    if(totalSupply == 0)
        {
            selfdestruct(owner);
        }
    vigencia = _vigencia;
}

}