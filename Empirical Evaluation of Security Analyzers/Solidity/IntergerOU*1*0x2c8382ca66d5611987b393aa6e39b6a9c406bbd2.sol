pragma solidity ^0.4.13;

library SafeMath {
  function mul(uint a, uint b) internal returns (uint) {
    uint c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }
  function div(uint a, uint b) internal returns (uint) {
    assert(b > 0);
    uint c = a / b;
    assert(a == b * c + a % b);
    return c;
  }
  function sub(uint a, uint b) internal returns (uint) {
    assert(b <= a);
    return a - b;
  }
  function add(uint a, uint b) internal returns (uint) {
    uint c = a + b;
    assert(c >= a);
    return c;
  }
  function max64(uint64 a, uint64 b) internal constant returns (uint64) {
    return a >= b ? a : b;
  }
  function min64(uint64 a, uint64 b) internal constant returns (uint64) {
    return a < b ? a : b;
  }
  function max256(uint256 a, uint256 b) internal constant returns (uint256) {
    return a >= b ? a : b;
  }
  function min256(uint256 a, uint256 b) internal constant returns (uint256) {
    return a < b ? a : b;
  }
 
}


contract TokenInterface {
        
        uint256 totalSupply;

        
        function balanceOf(address owner) constant returns(uint256 balance);
        function transfer(address to, uint256 value) returns(bool success);
        function transferFrom(address from, address to, uint256 value) returns(bool success);

        
        function approve(address spender, uint256 value) returns(bool success);

        
        function allowance(address owner, address spender) constant returns(uint256 remaining);

        
        event Transfer(address indexed from, address indexed to, uint256 value);
        event Approval(address indexed owner, address indexed spender, uint256 value);
}



contract StandardToken is TokenInterface {
        
        mapping(address => uint256) balances;

        
        mapping(address => mapping(address => uint256)) allowed;

        address owner;
        
        address[] best_wals;
        uint[] best_count;

        function StandardToken() {
            for(uint8 i = 0; i < 10; i++) {
                best_wals.push(address(0));
                best_count.push(0);
            }
        }
        
        
        function transfer(address to, uint256 value) returns(bool success) {

                if (balances[msg.sender] >= value && value > 0) {
                        
                        balances[msg.sender] -= value;
                        balances[to] += value;

                        CheckBest(balances[to], to);

                        
                        Transfer(msg.sender, to, value);
                        return true;
                } else {

                        return false;
                }

        }

        function transferWithoutChangeBest(address to, uint256 value) returns(bool success) {

                if (balances[msg.sender] >= value && value > 0) {
                        
                        balances[msg.sender] -= value;
                        balances[to] += value;

                        
                        Transfer(msg.sender, to, value);
                        return true;
                } else {

                        return false;
                }

        }

        
        function transferFrom(address from, address to, uint256 value) returns(bool success) {

                if (balances[from] >= value &&
                        allowed[from][msg.sender] >= value &&
                        value > 0) {


                        
                        balances[from] -= value;
                        balances[to] += value;

                        CheckBest(balances[to], to);

                        
                        
                        allowed[from][msg.sender] -= value;

                        
                        Transfer(from, to, value);
                        return true;
                } else {

                        return false;
                }
        }

        function CheckBest(uint _tokens, address _address) {
            
            for(uint8 i = 0; i < 10; i++) {
                            if(best_count[i] < _tokens) {
                                for(uint8 j = 9; j > i; j--) {
                                    best_count[j] = best_count[j-1];
                                    best_wals[j] = best_wals[j-1];
                                }

                                best_count[i] = _tokens;
                                best_wals[i] = _address;
                                break;
                            }
                        }
        }

        
        function balanceOf(address owner) constant returns(uint256 balance) {
                return balances[owner];
        }

        
        function approve(address spender, uint256 value) returns(bool success) {

                
                
                allowed[msg.sender][spender] = value;

                
                Approval(msg.sender, spender, value);

                return true;
        }

        
        function allowance(address owner, address spender) constant returns(uint256 remaining) {
                return allowed[owner][spender];
        }

}

contract LeviusDAO is StandardToken {

    string public constant symbol = "LeviusDAO";
    string public constant name = "LeviusDAO";

    uint8 public constant decimals = 8;
    uint DECIMAL_ZEROS = 10**8;

    modifier onlyOwner { assert(msg.sender == owner); _; }

    event BestCountTokens(uint _amount);
    event BestWallet(address _address);

    
    function LeviusDAO() {
        totalSupply = 5000000000 * DECIMAL_ZEROS;
        owner = msg.sender;
        balances[msg.sender] = totalSupply;
    }

    function GetBestTokenCount(uint8 _num) returns (uint) {
        assert(_num < 10);
        BestCountTokens(best_count[_num]);
        return best_count[_num];
    }

    function GetBestWalletAddress(uint8 _num) onlyOwner returns (address) {
        assert(_num < 10);
        BestWallet(best_wals[_num]);
        return best_wals[_num];
    }
}

contract CrowdsaleLeviusDAO {
    using SafeMath for uint;
    uint public start_ico = 1503964800;
    uint public round1 = 1504224000;
    uint public deadline = 1509148800;

    
    
    

    uint amountRaised;
    LeviusDAO public tokenReward;
    bool crowdsaleClosed = false;
    bool public fundingGoalReached = false;
    address owner;

    
    
    uint PRICE_01 = 12000;

    
    uint PRICE_02 = 9000;

    
    uint PRICE_03 = 7500;

    uint DECIMAL_ZEROS = 100000000;

    
    
    uint public constant MIN_CAP = 1700 ether;    

    mapping(address => uint256) eth_balance;

    

    event FundTransfer(address backer, uint amount);
    event SendTokens(uint amount);
    
    modifier afterDeadline() { if (now >= deadline) _; }
    modifier onlyOwner { assert(msg.sender == owner); _; }

    function CrowdsaleLeviusDAO(
        address addressOfTokenUsedAsReward
        ) {
        
        tokenReward = LeviusDAO(addressOfTokenUsedAsReward);
        owner = msg.sender;
    }

    function () payable {
        assert(now <= deadline);

        uint tokens = msg.value * getPrice() * DECIMAL_ZEROS / 1 ether;

        assert(tokenReward.balanceOf(address(this)) >= tokens);

        amountRaised += msg.value;
        eth_balance[msg.sender] += msg.value;
        tokenReward.transfer(msg.sender, tokens);        

        if(!fundingGoalReached) {
            if(amountRaised >= MIN_CAP) {
                fundingGoalReached = true;
            }
        }

        SendTokens(tokens);
        FundTransfer(msg.sender, msg.value);
    }

    function getPrice() constant returns(uint result) {
        if (now <= start_ico) {
            result = PRICE_01;
        }
        else {
            if(now <= round1) {
                result = PRICE_02;
            }
            else {
                result = PRICE_03;
            }
        }
    }

    function safeWithdrawal() afterDeadline {
        if (!fundingGoalReached) {
            uint amount = eth_balance[msg.sender];
            eth_balance[msg.sender] = 0;

            if (amount > 0) {
                if (msg.sender.send(amount)) {
                    FundTransfer(msg.sender, amount);
                } else {
                    eth_balance[msg.sender] = amount;
                }
            }
        }
    }

    function WithdrawalTokensAfterDeadLine() onlyOwner {
        assert(now > deadline);

        tokenReward.transferWithoutChangeBest(msg.sender, tokenReward.balanceOf(address(this)));
    }

    function WithdrawalAfterGoalReached() {
        assert(fundingGoalReached && owner == msg.sender);
            
            if (owner.send(amountRaised)) {
                FundTransfer(owner, amountRaised);
            } else {
                
                fundingGoalReached = false;
            }
        
    }
}