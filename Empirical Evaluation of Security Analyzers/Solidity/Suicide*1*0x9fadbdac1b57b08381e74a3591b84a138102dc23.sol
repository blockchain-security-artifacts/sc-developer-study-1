pragma solidity ^0.4.0;

contract Ethraffle {
    struct Contestant {
        address addr;
        uint raffleId;
    }

    event RaffleResult(
        uint indexed raffleId,
        uint winningNumber,
        address winningAddress,
        uint blockTimestamp,
        uint blockNumber,
        uint gasLimit,
        uint difficulty,
        uint gas,
        uint value,
        address msgSender,
        address blockCoinbase,
        bytes32 sha
    );

    event TicketPurchase(
        uint indexed raffleId,
        address contestant,
        uint number
    );

    event TicketRefund(
        uint indexed raffleId,
        address contestant,
        uint number
    );

    
    address public rakeAddress;
    uint constant public prize = 0.1 ether;
    uint constant public rake = 0.02 ether;
    uint constant public totalTickets = 6;
    uint constant public pricePerTicket = (prize + rake) / totalTickets;

    
    uint public raffleId = 1;
    uint public nextTicket = 1;
    mapping (uint => Contestant) public contestants;
    uint[] public gaps;
    bool public paused = false;

    
    function Ethraffle() public {
        rakeAddress = msg.sender;
    }

    
    function () payable public {
        buyTickets();
    }

    function buyTickets() payable public {
        if (paused) {
            msg.sender.transfer(msg.value);
            return;
        }

        uint moneySent = msg.value;

        while (moneySent >= pricePerTicket && nextTicket <= totalTickets) {
            uint currTicket = 0;
            if (gaps.length > 0) {
                currTicket = gaps[gaps.length-1];
                gaps.length--;
            } else {
                currTicket = nextTicket++;
            }

            contestants[currTicket] = Contestant(msg.sender, raffleId);
            TicketPurchase(raffleId, msg.sender, currTicket);
            moneySent -= pricePerTicket;
        }

        
        if (nextTicket > totalTickets) {
            chooseWinner();
        }

        
        if (moneySent > 0) {
            msg.sender.transfer(moneySent);
        }
    }

    function chooseWinner() private {
        
        bytes32 sha = sha3(
            block.timestamp,
            block.number,
            block.gaslimit,
            block.difficulty,
            msg.gas,
            msg.value,
            msg.sender,
            block.coinbase
        );

        uint winningNumber = (uint(sha) % totalTickets) + 1;
        address winningAddress = contestants[winningNumber].addr;
        RaffleResult(
            raffleId, winningNumber, winningAddress, block.timestamp,
            block.number, block.gaslimit, block.difficulty, msg.gas,
            msg.value, msg.sender, block.coinbase, sha
        );

        
        raffleId++;
        nextTicket = 1;
        winningAddress.transfer(prize);
        rakeAddress.transfer(rake);
    }

    
    function getRefund() public {
        uint refunds = 0;
        for (uint i = 1; i <= totalTickets; i++) {
            if (msg.sender == contestants[i].addr && raffleId == contestants[i].raffleId) {
                refunds++;
                contestants[i] = Contestant(address(0), 0);
                gaps.push(i);
                TicketRefund(raffleId, msg.sender, i);
            }
        }

        if (refunds > 0) {
            msg.sender.transfer(refunds * pricePerTicket);
        }
    }

    
    function endRaffle() public {
        if (msg.sender == rakeAddress) {
            paused = true;

            for (uint i = 1; i <= totalTickets; i++) {
                if (raffleId == contestants[i].raffleId) {
                    TicketRefund(raffleId, contestants[i].addr, i);
                    contestants[i].addr.transfer(pricePerTicket);
                }
            }

            RaffleResult(raffleId, 0, address(0), 0, 0, 0, 0, 0, 0, address(0), address(0), 0);
            raffleId++;
            nextTicket = 1;
            gaps.length = 0;
        }
    }

    function togglePause() public {
        if (msg.sender == rakeAddress) {
            paused = !paused;
        }
    }

    function kill() public {
        if (msg.sender == rakeAddress) {
            selfdestruct(rakeAddress);
        }
    }
}