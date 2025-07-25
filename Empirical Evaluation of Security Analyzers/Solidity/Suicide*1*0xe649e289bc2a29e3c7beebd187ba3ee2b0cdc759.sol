pragma solidity ^0.4.16;

contract owned {
    address public owner;

    function owned() public {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address newOwner) onlyOwner public {
        owner = newOwner;
    }

    function kill() onlyOwner public {
        selfdestruct(owner);
    }

    function () public payable {}
}

interface tokenRecipient { function receiveApproval(address _from, uint256 _value, address _token, bytes _extraData) external; }

contract TokenERC20 {
    
    string public name;
    string public symbol;
    uint8 public decimals = 18;
    
    uint256 public totalSupply;

    
    mapping (address => uint256) public balanceOf;
    mapping (address => mapping (address => uint256)) public allowance;

    
    event Transfer(address indexed from, address indexed to, uint256 value);

    
    event Burn(address indexed from, uint256 value);

    
    function TokenERC20(
        uint256 initialSupply,
        uint8 initialDecimals,
        string tokenName,
        string tokenSymbol
    ) public {
        decimals = initialDecimals;
        totalSupply = initialSupply * 10 ** uint256(decimals);  
        balanceOf[msg.sender] = totalSupply;                
        name = tokenName;                                   
        symbol = tokenSymbol;                               
    }

    
    function _transfer(address _from, address _to, uint _value) internal {
        
        require(_to != 0x0);
        
        require(balanceOf[_from] >= _value);
        
        require(balanceOf[_to] + _value > balanceOf[_to]);
        
        uint previousBalances = balanceOf[_from] + balanceOf[_to];
        
        balanceOf[_from] -= _value;
        
        balanceOf[_to] += _value;
        emit Transfer(_from, _to, _value);
        
        assert(balanceOf[_from] + balanceOf[_to] == previousBalances);
    }

    
    function transfer(address _to, uint256 _value) public {
        _transfer(msg.sender, _to, _value);
    }

    
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        if (_value <= allowance[_from][msg.sender]) {
          allowance[_from][msg.sender] -= _value;
          _transfer(_from, _to, _value);
          return true;
        }
        else
          return false;
    }

    
    function approve(address _spender, uint256 _value) public
        returns (bool success) {
        allowance[msg.sender][_spender] = _value;
        return true;
    }

    
    function approveAndCall(address _spender, uint256 _value, bytes _extraData)
        public
        returns (bool success) {
        tokenRecipient spender = tokenRecipient(_spender);
        if (approve(_spender, _value)) {
            spender.receiveApproval(msg.sender, _value, this, _extraData);
            return true;
        }
    }

    
    function burn(uint256 _value) public returns (bool success) {
        require(balanceOf[msg.sender] >= _value);   
        balanceOf[msg.sender] -= _value;            
        totalSupply -= _value;                      
        emit Burn(msg.sender, _value);
        return true;
    }

    
    function burnFrom(address _from, uint256 _value) public returns (bool success) {
        require(balanceOf[_from] >= _value);                
        require(_value <= allowance[_from][msg.sender]);    
        balanceOf[_from] -= _value;                         
        allowance[_from][msg.sender] -= _value;             
        totalSupply -= _value;                              
        emit Burn(_from, _value);
        return true;
    }
}





contract JiucaiToken is owned, TokenERC20 {

    uint256 public price;
    uint256 public priceInc;
    uint256 public transferFees;

    mapping (address => bool) public frozenAccount;

    
    event FrozenFunds(address target, bool frozen);

    
    function JiucaiToken (
        uint256 initialSupply,
        uint8 initialDecimals,
        string tokenName,
        string tokenSymbol
    ) TokenERC20(initialSupply, initialDecimals, tokenName, tokenSymbol) public {

        price = 10 finney;
        priceInc = 10 finney;
        transferFees = 20 finney;
    }

    
    function _transfer(address _from, address _to, uint _value) internal {
        require (_to != 0x0);                               
        require (balanceOf[_from] >= _value);               
        require (balanceOf[_to] + _value >= balanceOf[_to]); 
        require(!frozenAccount[_from]);                     
        require(!frozenAccount[_to]);                       
        balanceOf[_from] -= _value;                         
        balanceOf[_to] += _value;                           
        emit Transfer(_from, _to, _value);
    }

    
    
    
    function mintToken(address target, uint256 mintedAmount) onlyOwner public {
        balanceOf[target] += mintedAmount;
        totalSupply += mintedAmount;
        emit Transfer(0, this, mintedAmount);
        emit Transfer(this, target, mintedAmount);
    }

    
    
    
    function freezeAccount(address target, bool freeze) onlyOwner public {
        frozenAccount[target] = freeze;
        emit FrozenFunds(target, freeze);
    }

    
    
    
    
    function setPrices(uint256 newPrice, uint256 newPriceInc, uint256 newTransferFees) onlyOwner public {
        require(newTransferFees > newPriceInc);
        price = newPrice;
        priceInc = newPriceInc;
        transferFees = newTransferFees;
    }

    
    function buy() payable public {
        require(msg.value == price);
        uint amount = msg.value / price;               
        _transfer(this, msg.sender, amount);              

        price += priceInc;
    }

    
    
    function sell(uint256 amount) public {
        require(amount == 1);
        require(address(this).balance >= amount * price);      
        _transfer(msg.sender, this, amount);              
        msg.sender.transfer(amount * price - transferFees);          

        price -= priceInc;
    }
}