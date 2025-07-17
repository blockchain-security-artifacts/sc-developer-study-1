pragma solidity 0.6.0;



contract Log {
    
    struct Message {
        address sender; 
        uint amount; 
        uint time; 
        string operation; 
    }
    
    Message[] public history; 
    Message lastMsg; 
    
    
    function register(address sender, uint amount, string memory operation) public {
        history.push(Message(sender, amount, now, operation));
    }
}


contract SafeBank {
    uint public constant minDeposit = 300 finney; 

    mapping (address => uint) public balances; 
    Log transferLog; 
    
    constructor(address _log) public payable {
        transferLog = Log(_log);
    }
    
    
    function deposit() public payable {
        require(msg.value >= minDeposit, "Minimum deposit not met."); 

        balances[msg.sender] += msg.value; 
        transferLog.register(msg.sender, msg.value, "Deposit"); 
    }
    
    
    function withdraw(uint amount) public {
        require(amount <= balances[msg.sender], "Insufficient funds"); 

        (bool success,) = msg.sender.call.value(amount)(""); 
        if(success) { 
            balances[msg.sender] -= amount; 
            transferLog.register(msg.sender, amount, "Withdraw"); 
        }
    }
    
    
    receive() external payable {
        
    }
}