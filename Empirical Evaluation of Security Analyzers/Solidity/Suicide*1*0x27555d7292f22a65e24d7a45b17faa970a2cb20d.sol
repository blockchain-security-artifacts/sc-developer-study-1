pragma solidity ^0.4.18;


contract ERC20Basic {
  uint256 public totalSupply;
  function balanceOf(address who) public view returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}


library SafeMath {
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    
    uint256 c = a / b;
    
    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}


contract BasicToken is ERC20Basic {
  using SafeMath for uint256;

  mapping(address => uint256) balances;

  
  function transfer(address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    require(_value <= balances[msg.sender]);

    
    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    Transfer(msg.sender, _to, _value);
    return true;
  }

  
  function balanceOf(address _owner) public view returns (uint256 balance) {
    return balances[_owner];
  }

}


contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) public view returns (uint256);
  function transferFrom(address from, address to, uint256 value) public returns (bool);
  function approve(address spender, uint256 value) public returns (bool);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}


contract StandardToken is ERC20, BasicToken {

  mapping (address => mapping (address => uint256)) internal allowed;


  
  function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    require(_value <= balances[_from]);
    require(_value <= allowed[_from][msg.sender]);

    balances[_from] = balances[_from].sub(_value);
    balances[_to] = balances[_to].add(_value);
    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
    Transfer(_from, _to, _value);
    return true;
  }

  
  function approve(address _spender, uint256 _value) public returns (bool) {
    allowed[msg.sender][_spender] = _value;
    Approval(msg.sender, _spender, _value);
    return true;
  }

  
  function allowance(address _owner, address _spender) public view returns (uint256) {
    return allowed[_owner][_spender];
  }

  
  function increaseApproval(address _spender, uint _addedValue) public returns (bool) {
    allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
    Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

  
  function decreaseApproval(address _spender, uint _subtractedValue) public returns (bool) {
    uint oldValue = allowed[msg.sender][_spender];
    if (_subtractedValue > oldValue) {
      allowed[msg.sender][_spender] = 0;
    } else {
      allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
    }
    Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

}


contract Ownable {
  address public owner;


  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


  
  function Ownable() public {
    owner = msg.sender;
  }


  
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }


  
  function transferOwnership(address newOwner) public onlyOwner {
    require(newOwner != address(0));
    OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

}



contract MintableToken is StandardToken, Ownable {
  event Mint(address indexed to, uint256 amount);
  event MintFinished();

  bool public mintingFinished = false;


  modifier canMint() {
    require(!mintingFinished);
    _;
  }

  
  function mint(address _to, uint256 _amount) onlyOwner canMint public returns (bool) {
    totalSupply = totalSupply.add(_amount);
    balances[_to] = balances[_to].add(_amount);
    Mint(_to, _amount);
    Transfer(address(0), _to, _amount);
    return true;
  }

  
  function finishMinting() onlyOwner canMint public returns (bool) {
    mintingFinished = true;
    MintFinished();
    return true;
  }
}


contract Crowdsale {
  using SafeMath for uint256;

  
  MintableToken public token;

  
  uint256 public startTime;
  uint256 public endTime;

  
  address public wallet;

  
  uint256 public rate;

  
  uint256 public weiRaised;

  
  event TokenPurchase(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);


  function Crowdsale(uint256 _startTime, uint256 _endTime, uint256 _rate, address _wallet) public {
    require(_startTime >= now);
    require(_endTime >= _startTime);
    require(_rate > 0);
    require(_wallet != address(0));

    token = createTokenContract();
    startTime = _startTime;
    endTime = _endTime;
    rate = _rate;
    wallet = _wallet;
  }

  
  
  function createTokenContract() internal returns (MintableToken) {
    return new MintableToken();
  }


  
  function () external payable {
    buyTokens(msg.sender);
  }

  
  function buyTokens(address beneficiary) public payable {
    require(beneficiary != address(0));
    require(validPurchase());

    uint256 weiAmount = msg.value;

    
    uint256 tokens = weiAmount.mul(rate);

    
    weiRaised = weiRaised.add(weiAmount);

    token.mint(beneficiary, tokens);
    TokenPurchase(msg.sender, beneficiary, weiAmount, tokens);

    forwardFunds();
  }

  
  
  function forwardFunds() internal {
    wallet.transfer(msg.value);
  }

  
  function validPurchase() internal view returns (bool) {
    bool withinPeriod = now >= startTime && now <= endTime;
    bool nonZeroPurchase = msg.value != 0;
    return withinPeriod && nonZeroPurchase;
  }

  
  function hasEnded() public view returns (bool) {
    return now > endTime;
  }


}

contract DetailedERC20 is ERC20 {
  string public name;
  string public symbol;
  uint8 public decimals;

  function DetailedERC20(string _name, string _symbol, uint8 _decimals) public {
    name = _name;
    symbol = _symbol;
    decimals = _decimals;
  }
}



contract CappedToken is MintableToken {

  uint256 public cap;

  function CappedToken(uint256 _cap) public {
    require(_cap > 0);
    cap = _cap;
  }

  
  function mint(address _to, uint256 _amount) onlyOwner canMint public returns (bool) {
    require(totalSupply.add(_amount) <= cap);

    return super.mint(_to, _amount);
  }

}


contract BurnableToken is BasicToken {

    event Burn(address indexed burner, uint256 value);

    
    function burn(uint256 _value) public {
        require(_value <= balances[msg.sender]);
        
        

        address burner = msg.sender;
        balances[burner] = balances[burner].sub(_value);
        totalSupply = totalSupply.sub(_value);
        Burn(burner, _value);
    }
}


library SafeERC20 {
  function safeTransfer(ERC20Basic token, address to, uint256 value) internal {
    assert(token.transfer(to, value));
  }

  function safeTransferFrom(ERC20 token, address from, address to, uint256 value) internal {
    assert(token.transferFrom(from, to, value));
  }

  function safeApprove(ERC20 token, address spender, uint256 value) internal {
    assert(token.approve(spender, value));
  }
}



contract HTLC {

    using SafeERC20 for ERC20Basic;

    
    ERC20Basic public token;

    
    address public beneficiary;

    
    uint256 public releaseTime;

    
    bytes32 sha256hash;

    function HTLC(ERC20Basic _token, bytes32 _hash, address _beneficiary, uint256 _releaseTime) public {
        require(_releaseTime > now);
        token = _token;
        beneficiary = _beneficiary;
        releaseTime = _releaseTime;
        sha256hash = _hash;
    }

    
    function redeem(bytes preimage) public {
        require(sha256(preimage) == sha256hash);

        uint256 amount = token.balanceOf(this);
        require(amount > 0);

        token.safeTransfer(beneficiary, amount);
        selfdestruct(msg.sender);
    }

    
    function onTimeout(uint256) internal {
        selfdestruct(msg.sender);
    }

    
    function release() public {
        require(now >= releaseTime);

        uint256 amount = token.balanceOf(this);
        require(amount > 0);

        onTimeout(amount);
    }

}

contract VCBToken is CappedToken, BurnableToken, DetailedERC20 {

    using SafeMath for uint256;

    uint8 constant DECIMALS = 18;
    uint  constant TOTALTOKEN = 1 * 10 ** (8 + uint(DECIMALS));
    string constant NAME = "ValueCyber Token";
    string constant SYM = "VCT";

    address constant PRESALE = 0x638a3C7dF9D1B3A56E19B92bE07eCC84b6475BD6;
    uint  constant PRESALETOKEN = 55 * 10 ** (6 + uint(DECIMALS));

    function VCBToken() CappedToken(TOTALTOKEN) DetailedERC20 (NAME, SYM, DECIMALS) public {
        
        balances[PRESALE] = PRESALETOKEN;
        totalSupply = totalSupply.add(PRESALETOKEN);
    }

}

contract VCBCrowdSale is Crowdsale, Ownable {

    using SafeMath for uint256;

    uint  constant RATIO = 800;
    uint8 constant RATIODENO = 100;
    uint constant SALELASTFOR = 50 days;
    address constant FUNDWALLET = 0x622969e0928fa6bEeda9f26F8a60D0b22Db7E6f1;

    mapping(address => uint8) giftList;

    event CrowdsaleFinalized();
    
    event TokenGift(address indexed beneficiary, uint256 amount);

    function VCBCrowdSale() Crowdsale(now, now + SALELASTFOR, RATIO, FUNDWALLET) public {
    }

    function createTokenContract() internal returns (MintableToken) {
        return new VCBToken();
    }

    
    function finalize(address _finaladdr) onlyOwner public {
        token.finishMinting();
        CrowdsaleFinalized();

        address finaladdr = FUNDWALLET;
        if (_finaladdr != address(0)) {
            finaladdr = _finaladdr;
        }

        selfdestruct(finaladdr);
    }  

    function giftTokens(address beneficiary) internal {
        uint256 weiAmount = msg.value;

        
        uint256 gifttokens = weiAmount.mul(giftList[beneficiary]).mul(rate).div(RATIODENO);
        if (gifttokens > 0) {

            
            token.mint(beneficiary, gifttokens);
            TokenGift(beneficiary, gifttokens);
        }

    }

    
    function buyTokens(address beneficiary) public payable {

        super.buyTokens(beneficiary);

        
        giftTokens(beneficiary);
    }

    function addGift(address beneficiary, uint8 giftratio) onlyOwner public {
        require(giftratio < RATIODENO);
        giftList[beneficiary] = giftratio;
    }

    
    function giftRatioOf(address _owner) public view returns (uint8 ratio) {
        return giftList[_owner];
    }

    
    function preserveTokens(address preservecontract, uint256 amount) onlyOwner public {        
        token.mint(preservecontract, amount);
    }    

}

contract CrowdSaleHTLC is HTLC {
    function CrowdSaleHTLC(ERC20Basic _token, bytes32 _hash, address _beneficiary, uint256 _releaseTime) HTLC(_token, _hash, _beneficiary, _releaseTime) public {
    }

    function onTimeout(uint256 amount) internal {
        BurnableToken t = BurnableToken (token);
        t.burn(amount);
        super.onTimeout(amount);
    }

}