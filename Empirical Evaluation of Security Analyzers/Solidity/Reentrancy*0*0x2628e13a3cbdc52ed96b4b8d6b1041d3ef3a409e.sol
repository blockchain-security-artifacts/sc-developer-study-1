pragma solidity ^0.4.25;


contract EasySmartolution {

    event ParticipantAdded(address _sender);
    event ParticipantRemoved(address _sender);
    event ReferrerAdded(address _contract, address _sender);

    mapping (address => address) public participants; 
    mapping (address => bool) public referrers;
    
    address private processing;
 
    constructor(address _processing) public {
        processing = _processing;
    }
    
    function () external payable {
        if (participants[msg.sender] == address(0)) {
            addParticipant(msg.sender, address(0));
        } else {
            require(msg.value == 0, "0 ether to manually make a daily payment");

            processPayment(msg.sender);
        }
    }
    
    function addParticipant(address _address, address _referrer) payable public {
        require(participants[_address] == address(0), "This participant is already registered");
        require(msg.value >= 0.45 ether && msg.value <= 225 ether, "Deposit should be between 0.45 ether and 225 ether (45 days)");
        
        participants[_address] = address(new Participant(_address, msg.value / 45));
        processPayment(_address);
        
        processing.send(msg.value / 20);
        if (_referrer != address(0) && referrers[_referrer]) {
            _referrer.send(msg.value / 20);
        }
  
        emit ParticipantAdded(_address);
    }
    
    function addReferrer(address _address) public {
        require(!referrers[_address], "This address is already a referrer");
        
        referrers[_address] = true;
        EasySmartolutionRef refContract = new EasySmartolutionRef(address(this));
        refContract.setReferrer(_address);
        emit ReferrerAdded(address(refContract), _address);
    }

    function processPayment(address _address) public {
        Participant participant = Participant(participants[_address]);

        bool done = participant.processPayment.value(participant.daily())();
        
        if (done) {
            participants[_address] = address(0);
            emit ParticipantRemoved(_address);
        }
    }
}

contract EasySmartolutionRef {
    address public referrer;
    address public smartolution;
    
    constructor (address _smartolution) public {
        smartolution = _smartolution;
    }

    function setReferrer(address _referrer) external {
        require(referrer == address(0), "referrer can only be set once");
        referrer = _referrer;
    }

    function () external payable {
        if (msg.value > 0) {
            EasySmartolution(smartolution).addParticipant.value(msg.value)(msg.sender, referrer);
        } else {
            EasySmartolution(smartolution).processPayment(msg.sender);
        }
    }
}

contract Participant {
    address constant smartolution = 0xe0ae35fe7Df8b86eF08557b535B89bB6cb036C23;

    address public owner;
    uint public daily;
    
    constructor(address _owner, uint _daily) public {
        owner = _owner;
        daily = _daily;
    }
    
    function () external payable {}
    
    function processPayment() external payable returns (bool) {
        require(msg.value == daily, "Invalid value");
        
        uint indexBefore;
        uint index;
        (,indexBefore,) = SmartolutionInterface(smartolution).users(address(this));
        smartolution.call.value(msg.value)();
        (,index,) = SmartolutionInterface(smartolution).users(address(this));

        require(index != indexBefore, "Smartolution rejected that payment, too soon or not enough ether");
    
        owner.send(address(this).balance);

        return index == 45;
    }
}

contract SmartolutionInterface {
    struct User {
        uint value;
        uint index;
        uint atBlock;
    }

    mapping (address => User) public users; 
}