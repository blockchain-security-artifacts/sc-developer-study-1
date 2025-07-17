pragma solidity ^0.5.12;

contract OddWins {
    address payable owner;
    uint evenOrOdd = 0;

    constructor() public {
        owner = msg.sender;
    }
    
    
    function () external payable {
        require(msg.value == 10**17);
        if (evenOrOdd % 2 > 0) {
            uint balance = address(this).balance;
            uint devFee = balance / 100;
            
            if (owner.send(devFee)) {
                
                if (!msg.sender.send(balance - devFee)) {
                    revert();
                }
            }
        }
        evenOrOdd++;
    }
    
    function shutdown() public {
        selfdestruct(owner);
    }
}