pragma solidity ^0.4.16;

contract koth_v1b {
    event NewKoth(
        uint gameId,
        uint betNumber,
        address bettor,
        uint bet,
        uint pot,
        uint lastBlock
    );

    event KothWin(
        uint gameId,
        uint totalBets,
        address winner,
        uint winningBet,
        uint pot,
        uint fee,
        uint firstBlock,
        uint lastBlock
    );

    
    uint public constant minPot = 0.001 ether; 
    uint public constant minRaise = 0.001 ether;
    address feeAddress;

    
    uint public gameId = 0;
    uint public betId;
    uint public highestBet;
    uint public pot;
    uint public firstBlock;
    uint public lastBlock;
    address public koth;
    uint public minBet;
    uint public maxBet;

    
    function koth_v1b() public {
        feeAddress = msg.sender;
        resetKoth();
    }

    function () payable public {
        
        if (msg.sender == koth) {
            return;
        }

        
        if (lastBlock > 0 && block.number > lastBlock) {
            msg.sender.transfer(msg.value);
            return;
        }

        
        if (msg.value < minBet) {
            msg.sender.transfer(msg.value);
            return;
        }

        
        if (msg.value > maxBet) {
            msg.sender.transfer(msg.value);
            return;
        }

        
        betId++;
        highestBet = msg.value;
        koth = msg.sender;
        pot += highestBet;

        
        minBet = highestBet + minRaise;
        if (pot < 1 ether) {
            maxBet = 3 * pot;
        } else {
            maxBet = 5 * pot / 4;
        }

        
        uint potEther = pot/1000000000000000000;
        uint blocksRemaining = (potEther ** 2)/2 - 8*potEther + 37;
        if (blocksRemaining < 6) {
            blocksRemaining = 3;
        }

        lastBlock = block.number + blocksRemaining;

        NewKoth(gameId, betId, koth, highestBet, pot, lastBlock);
    }

    function resetKoth() private {
        gameId++;
        highestBet = 0;
        koth = address(0);
        pot = minPot;
        lastBlock = 0;
        betId = 0;
        firstBlock = block.number;
        minBet = minRaise;
        maxBet = 3 * minPot;
    }

    
    function rewardKoth() public {
        if (msg.sender == feeAddress && lastBlock > 0 && block.number > lastBlock) {
            uint fee = pot / 20; 
            KothWin(gameId, betId, koth, highestBet, pot, fee, firstBlock, lastBlock);

            uint netPot = pot - fee;
            address winner = koth;
            resetKoth();
            winner.transfer(netPot);

            
            if (this.balance - fee >= minPot) {
                feeAddress.transfer(fee);
            }
        }
    }

    function addFunds() payable public {
        if (msg.sender != feeAddress) {
            msg.sender.transfer(msg.value);
        }
    }

    function kill() public {
        if (msg.sender == feeAddress) {
            selfdestruct(feeAddress);
        }
    }
}