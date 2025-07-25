pragma solidity ^0.4.25;


contract FckDice {
    

    
    
    
    uint public HOUSE_EDGE_PERCENT = 1;
    uint public HOUSE_EDGE_MINIMUM_AMOUNT = 0.0003 ether;

    
    
    uint public MIN_JACKPOT_BET = 0.1 ether;

    
    uint public JACKPOT_MODULO = 1000;
    uint public JACKPOT_FEE = 0.001 ether;

    function setHouseEdgePercent(uint _HOUSE_EDGE_PERCENT) external onlyOwner {
        HOUSE_EDGE_PERCENT = _HOUSE_EDGE_PERCENT;
    }

    function setHouseEdgeMinimumAmount(uint _HOUSE_EDGE_MINIMUM_AMOUNT) external onlyOwner {
        HOUSE_EDGE_MINIMUM_AMOUNT = _HOUSE_EDGE_MINIMUM_AMOUNT;
    }

    function setMinJackpotBet(uint _MIN_JACKPOT_BET) external onlyOwner {
        MIN_JACKPOT_BET = _MIN_JACKPOT_BET;
    }

    function setJackpotModulo(uint _JACKPOT_MODULO) external onlyOwner {
        JACKPOT_MODULO = _JACKPOT_MODULO;
    }

    function setJackpotFee(uint _JACKPOT_FEE) external onlyOwner {
        JACKPOT_FEE = _JACKPOT_FEE;
    }

    
    uint constant MIN_BET = 0.01 ether;
    uint constant MAX_AMOUNT = 300000 ether;

    
    
    
    
    
    
    
    
    
    uint constant MAX_MODULO = 100;

    
    
    
    
    
    
    
    
    
    
    uint constant MAX_MASK_MODULO = 40;

    
    uint constant MAX_BET_MASK = 2 ** MAX_MASK_MODULO;

    
    
    
    
    
    
    uint constant BET_EXPIRATION_BLOCKS = 250;

    
    
    

    
    address public owner;
    address private nextOwner;

    
    uint public maxProfit;

    
    address public secretSigner;

    
    uint128 public jackpotSize;

    
    
    uint128 public lockedInBets;

    
    struct Bet {
        
        uint amount;
        
        uint8 modulo;
        
        
        uint8 rollUnder;
        
        uint40 placeBlockNumber;
        
        uint40 mask;
        
        address gambler;
    }

    
    mapping(uint => Bet) bets;

    
    address public croupier;

    
    event FailedPayment(address indexed beneficiary, uint amount);
    event Payment(address indexed beneficiary, uint amount);
    event JackpotPayment(address indexed beneficiary, uint amount);

    
    event Commit(uint commit);

    
    constructor (address _secretSigner, address _croupier, uint _maxProfit) public payable {
        owner = msg.sender;
        secretSigner = _secretSigner;
        croupier = _croupier;
        require(_maxProfit < MAX_AMOUNT, "maxProfit should be a sane number.");
        maxProfit = _maxProfit;
    }

    
    modifier onlyOwner {
        require(msg.sender == owner, "OnlyOwner methods called by non-owner.");
        _;
    }

    
    modifier onlyCroupier {
        require(msg.sender == croupier, "OnlyCroupier methods called by non-croupier.");
        _;
    }

    
    function approveNextOwner(address _nextOwner) external onlyOwner {
        require(_nextOwner != owner, "Cannot approve current owner.");
        nextOwner = _nextOwner;
    }

    function acceptNextOwner() external {
        require(msg.sender == nextOwner, "Can only accept preapproved new owner.");
        owner = nextOwner;
    }

    
    
    function() public payable {
    }

    
    function setSecretSigner(address newSecretSigner) external onlyOwner {
        secretSigner = newSecretSigner;
    }

    
    function setCroupier(address newCroupier) external onlyOwner {
        croupier = newCroupier;
    }

    
    function setMaxProfit(uint _maxProfit) public onlyOwner {
        require(_maxProfit < MAX_AMOUNT, "maxProfit should be a sane number.");
        maxProfit = _maxProfit;
    }

    
    function increaseJackpot(uint increaseAmount) external onlyOwner {
        require(increaseAmount <= address(this).balance, "Increase amount larger than balance.");
        require(jackpotSize + lockedInBets + increaseAmount <= address(this).balance, "Not enough funds.");
        jackpotSize += uint128(increaseAmount);
    }

    
    function withdrawFunds(address beneficiary, uint withdrawAmount) external onlyOwner {
        require(withdrawAmount <= address(this).balance, "Increase amount larger than balance.");
        require(jackpotSize + lockedInBets + withdrawAmount <= address(this).balance, "Not enough funds.");
        sendFunds(beneficiary, withdrawAmount, withdrawAmount);
    }

    
    
    function kill() external onlyOwner {
        
        selfdestruct(owner);
    }

    function getBetInfo(uint commit) external view returns (uint amount, uint8 modulo, uint8 rollUnder, uint40 placeBlockNumber, uint40 mask, address gambler) {
        Bet storage bet = bets[commit];
        amount = bet.amount;
        modulo = bet.modulo;
        rollUnder = bet.rollUnder;
        placeBlockNumber = bet.placeBlockNumber;
        mask = bet.mask;
        gambler = bet.gambler;
    }

    

    
    
    
    
    
    
    

    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    function placeBet(uint betMask, uint modulo, uint commitLastBlock, uint commit, bytes32 r, bytes32 s) external payable {
        
        Bet storage bet = bets[commit];
        require(bet.gambler == address(0), "Bet should be in a 'clean' state.");

        
        uint amount = msg.value;
        require(modulo > 1 && modulo <= MAX_MODULO, "Modulo should be within range.");
        require(amount >= MIN_BET && amount <= MAX_AMOUNT, "Amount should be within range.");
        require(betMask > 0 && betMask < MAX_BET_MASK, "Mask should be within range.");

        
        require(block.number <= commitLastBlock, "Commit has expired.");
        bytes32 signatureHash = keccak256(abi.encodePacked(commitLastBlock, commit));
        require(secretSigner == ecrecover(signatureHash, 27, r, s), "ECDSA signature is not valid.");

        uint rollUnder;
        uint mask;

        if (modulo <= MAX_MASK_MODULO) {
            
            
            
            
            
            rollUnder = ((betMask * POPCNT_MULT) & POPCNT_MASK) % POPCNT_MODULO;
            mask = betMask;
        } else {
            
            
            require(betMask > 0 && betMask <= modulo, "High modulo range, betMask larger than modulo.");
            rollUnder = betMask;
        }

        
        uint possibleWinAmount;
        uint jackpotFee;

        
        (possibleWinAmount, jackpotFee) = getDiceWinAmount(amount, modulo, rollUnder);

        
        require(possibleWinAmount <= amount + maxProfit, "maxProfit limit violation.");

        
        lockedInBets += uint128(possibleWinAmount);
        jackpotSize += uint128(jackpotFee);

        
        require(jackpotSize + lockedInBets <= address(this).balance, "Cannot afford to lose this bet.");

        
        emit Commit(commit);

        
        bet.amount = amount;
        bet.modulo = uint8(modulo);
        bet.rollUnder = uint8(rollUnder);
        bet.placeBlockNumber = uint40(block.number);
        bet.mask = uint40(mask);
        bet.gambler = msg.sender;
        
    }

    
    
    
    
    function settleBet(bytes20 reveal1, bytes20 reveal2, bytes32 blockHash) external onlyCroupier {
        uint commit = uint(keccak256(abi.encodePacked(reveal1, reveal2)));
        
        
        

        Bet storage bet = bets[commit];
        uint placeBlockNumber = bet.placeBlockNumber;

        
        

        
        require(block.number > placeBlockNumber, "settleBet in the same block as placeBet, or before.");
        require(block.number <= placeBlockNumber + BET_EXPIRATION_BLOCKS, "Blockhash can't be queried by EVM.");
        require(blockhash(placeBlockNumber) == blockHash, "blockHash invalid");

        
        settleBetCommon(bet, reveal1, reveal2, blockHash);
    }

    
    
    

    
    function settleBetCommon(Bet storage bet, bytes20 reveal1, bytes20 reveal2, bytes32 entropyBlockHash) private {
        
        uint amount = bet.amount;
        uint modulo = bet.modulo;
        uint rollUnder = bet.rollUnder;
        address gambler = bet.gambler;

        
        require(amount != 0, "Bet should be in an 'active' state");

        
        bet.amount = 0;

        
        
        
        
        bytes32 entropy = keccak256(abi.encodePacked(reveal1, entropyBlockHash, reveal2));
        

        
        uint dice = uint(entropy) % modulo;

        uint diceWinAmount;
        uint _jackpotFee;
        (diceWinAmount, _jackpotFee) = getDiceWinAmount(amount, modulo, rollUnder);

        uint diceWin = 0;
        uint jackpotWin = 0;

        
        if (modulo <= MAX_MASK_MODULO) {
            
            if ((2 ** dice) & bet.mask != 0) {
                diceWin = diceWinAmount;
            }

        } else {
            
            if (dice < rollUnder) {
                diceWin = diceWinAmount;
            }

        }

        
        lockedInBets -= uint128(diceWinAmount);

        
        if (amount >= MIN_JACKPOT_BET) {
            
            
            uint jackpotRng = (uint(entropy) / modulo) % JACKPOT_MODULO;

            
            if (jackpotRng == 0) {
                jackpotWin = jackpotSize;
                jackpotSize = 0;
            }
        }

        
        if (jackpotWin > 0) {
            emit JackpotPayment(gambler, jackpotWin);
        }

        
        sendFunds(gambler, diceWin + jackpotWin == 0 ? 1 wei : diceWin + jackpotWin, diceWin);
    }

    
    
    
    
    
    function refundBet(uint commit) external {
        
        Bet storage bet = bets[commit];
        uint amount = bet.amount;

        require(amount != 0, "Bet should be in an 'active' state");

        
        require(block.number > bet.placeBlockNumber + BET_EXPIRATION_BLOCKS, "Blockhash can't be queried by EVM.");

        
        bet.amount = 0;

        uint diceWinAmount;
        uint jackpotFee;
        (diceWinAmount, jackpotFee) = getDiceWinAmount(amount, bet.modulo, bet.rollUnder);

        lockedInBets -= uint128(diceWinAmount);
        jackpotSize -= uint128(jackpotFee);

        
        sendFunds(bet.gambler, amount, amount);
    }

    
    function getDiceWinAmount(uint amount, uint modulo, uint rollUnder) private view returns (uint winAmount, uint jackpotFee) {
        require(0 < rollUnder && rollUnder <= modulo, "Win probability out of range.");

        jackpotFee = amount >= MIN_JACKPOT_BET ? JACKPOT_FEE : 0;

        uint houseEdge = amount * HOUSE_EDGE_PERCENT / 100;

        if (houseEdge < HOUSE_EDGE_MINIMUM_AMOUNT) {
            houseEdge = HOUSE_EDGE_MINIMUM_AMOUNT;
        }

        require(houseEdge + jackpotFee <= amount, "Bet doesn't even cover house edge.");

        winAmount = (amount - houseEdge - jackpotFee) * modulo / rollUnder;
    }

    
    function sendFunds(address beneficiary, uint amount, uint successLogAmount) private {
        if (beneficiary.send(amount)) {
            emit Payment(beneficiary, successLogAmount);
        } else {
            emit FailedPayment(beneficiary, amount);
        }
    }

    
    
    uint constant POPCNT_MULT = 0x0000000000002000000000100000000008000000000400000000020000000001;
    uint constant POPCNT_MASK = 0x0001041041041041041041041041041041041041041041041041041041041041;
    uint constant POPCNT_MODULO = 0x3F;

}