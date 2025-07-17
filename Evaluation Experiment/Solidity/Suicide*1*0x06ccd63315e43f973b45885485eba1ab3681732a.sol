pragma solidity ^0.5.15;


interface IERC20 {
    
    function totalSupply() external view returns (uint256);

    
    function balanceOf(address account) external view returns (uint256);

    
    function transfer(address recipient, uint256 amount) external returns (bool);

    
    function allowance(address owner, address spender) external view returns (uint256);

    
    function approve(address spender, uint256 amount) external returns (bool);

    
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    
    event Transfer(address indexed from, address indexed to, uint256 value);

    
    event Approval(address indexed owner, address indexed spender, uint256 value);
}


library SafeMath {
    
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        
        
        
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        

        return c;
    }

    
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}


library Address {
    
    function isContract(address account) internal view returns (bool) {
        
        
        

        uint256 size;
        
        assembly { size := extcodesize(account) }
        return size > 0;
    }

    
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        
        (bool success, ) = recipient.call.value(amount)("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
      return functionCall(target, data, "Address: low-level call failed");
    }

    
    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        return _functionCallWithValue(target, data, 0, errorMessage);
    }

    
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    
    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(address target, bytes memory data, uint256 weiValue, string memory errorMessage) private returns (bytes memory) {
        require(isContract(target), "Address: call to non-contract");

        
        (bool success, bytes memory returndata) = target.call.value(weiValue)(data);
        if (success) {
            return returndata;
        } else {
            
            if (returndata.length > 0) {
                

                
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}


library SafeERC20 {
    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    
    function safeApprove(IERC20 token, address spender, uint256 value) internal {
        
        
        
        
        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        
        
        

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) { 
            
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}




contract YAMGovernanceStorage {
    
    mapping (address => address) internal _delegates;

    
    struct Checkpoint {
        uint32 fromBlock;
        uint256 votes;
    }

    
    mapping (address => mapping (uint32 => Checkpoint)) public checkpoints;

    
    mapping (address => uint32) public numCheckpoints;

    
    bytes32 public constant DOMAIN_TYPEHASH = keccak256("EIP712Domain(string name,uint256 chainId,address verifyingContract)");

    
    bytes32 public constant DELEGATION_TYPEHASH = keccak256("Delegation(address delegatee,uint256 nonce,uint256 expiry)");

    
    mapping (address => uint) public nonces;
}


contract YAMTokenStorage {

    using SafeMath for uint256;

    
    bool internal _notEntered;

    
    string public name;

    
    string public symbol;

    
    uint8 public decimals;

    
    address public gov;

    
    address public pendingGov;

    
    address public rebaser;

    
    address public migrator;

    
    address public incentivizer;

    
    uint256 public totalSupply;

    
    uint256 public constant internalDecimals = 10**24;

    
    uint256 public constant BASE = 10**18;

    
    uint256 public yamsScalingFactor;

    mapping (address => uint256) internal _yamBalances;

    mapping (address => mapping (address => uint256)) internal _allowedFragments;

    uint256 public initSupply;


    
    bytes32 public constant PERMIT_TYPEHASH = 0x6e71edae12b1b97f4d1f60370fef10105fa2faae0126114a169c64845d6126c9;
    bytes32 public DOMAIN_SEPARATOR;
}

contract YAMTokenInterface is YAMTokenStorage, YAMGovernanceStorage {

    
    event DelegateChanged(address indexed delegator, address indexed fromDelegate, address indexed toDelegate);

    
    event DelegateVotesChanged(address indexed delegate, uint previousBalance, uint newBalance);

    
    event Rebase(uint256 epoch, uint256 prevYamsScalingFactor, uint256 newYamsScalingFactor);

    

    
    event NewPendingGov(address oldPendingGov, address newPendingGov);

    
    event NewGov(address oldGov, address newGov);

    
    event NewRebaser(address oldRebaser, address newRebaser);

    
    event NewMigrator(address oldMigrator, address newMigrator);

    
    event NewIncentivizer(address oldIncentivizer, address newIncentivizer);

    

    
    event Transfer(address indexed from, address indexed to, uint amount);

    
    event Approval(address indexed owner, address indexed spender, uint amount);

    
    
    event Mint(address to, uint256 amount);

    
    function transfer(address to, uint256 value) external returns(bool);
    function transferFrom(address from, address to, uint256 value) external returns(bool);
    function balanceOf(address who) external view returns(uint256);
    function balanceOfUnderlying(address who) external view returns(uint256);
    function allowance(address owner_, address spender) external view returns(uint256);
    function approve(address spender, uint256 value) external returns (bool);
    function increaseAllowance(address spender, uint256 addedValue) external returns (bool);
    function decreaseAllowance(address spender, uint256 subtractedValue) external returns (bool);
    function maxScalingFactor() external view returns (uint256);
    function yamToFragment(uint256 yam) external view returns (uint256);
    function fragmentToYam(uint256 value) external view returns (uint256);

    
    function getPriorVotes(address account, uint blockNumber) external view returns (uint256);
    function delegateBySig(address delegatee, uint nonce, uint expiry, uint8 v, bytes32 r, bytes32 s) external;
    function delegate(address delegatee) external;
    function delegates(address delegator) external view returns (address);
    function getCurrentVotes(address account) external view returns (uint256);

    
    function mint(address to, uint256 amount) external returns (bool);
    function rebase(uint256 epoch, uint256 indexDelta, bool positive) external returns (uint256);
    function _setRebaser(address rebaser_) external;
    function _setIncentivizer(address incentivizer_) external;
    function _setPendingGov(address pendingGov_) external;
    function _acceptGov() external;
}





contract YAMGovernanceToken is YAMTokenInterface {

      
    event DelegateChanged(address indexed delegator, address indexed fromDelegate, address indexed toDelegate);

    
    event DelegateVotesChanged(address indexed delegate, uint previousBalance, uint newBalance);

    
    function delegates(address delegator)
        external
        view
        returns (address)
    {
        return _delegates[delegator];
    }

   
    function delegate(address delegatee) external {
        return _delegate(msg.sender, delegatee);
    }

    
    function delegateBySig(
        address delegatee,
        uint nonce,
        uint expiry,
        uint8 v,
        bytes32 r,
        bytes32 s
    )
        external
    {
        bytes32 structHash = keccak256(
            abi.encode(
                DELEGATION_TYPEHASH,
                delegatee,
                nonce,
                expiry
            )
        );

        bytes32 digest = keccak256(
            abi.encodePacked(
                "\x19\x01",
                DOMAIN_SEPARATOR,
                structHash
            )
        );

        address signatory = ecrecover(digest, v, r, s);
        require(signatory != address(0), "YAM::delegateBySig: invalid signature");
        require(nonce == nonces[signatory]++, "YAM::delegateBySig: invalid nonce");
        require(now <= expiry, "YAM::delegateBySig: signature expired");
        return _delegate(signatory, delegatee);
    }

    
    function getCurrentVotes(address account)
        external
        view
        returns (uint256)
    {
        uint32 nCheckpoints = numCheckpoints[account];
        return nCheckpoints > 0 ? checkpoints[account][nCheckpoints - 1].votes : 0;
    }

    
    function getPriorVotes(address account, uint blockNumber)
        external
        view
        returns (uint256)
    {
        require(blockNumber < block.number, "YAM::getPriorVotes: not yet determined");

        uint32 nCheckpoints = numCheckpoints[account];
        if (nCheckpoints == 0) {
            return 0;
        }

        
        if (checkpoints[account][nCheckpoints - 1].fromBlock <= blockNumber) {
            return checkpoints[account][nCheckpoints - 1].votes;
        }

        
        if (checkpoints[account][0].fromBlock > blockNumber) {
            return 0;
        }

        uint32 lower = 0;
        uint32 upper = nCheckpoints - 1;
        while (upper > lower) {
            uint32 center = upper - (upper - lower) / 2; 
            Checkpoint memory cp = checkpoints[account][center];
            if (cp.fromBlock == blockNumber) {
                return cp.votes;
            } else if (cp.fromBlock < blockNumber) {
                lower = center;
            } else {
                upper = center - 1;
            }
        }
        return checkpoints[account][lower].votes;
    }

    function _delegate(address delegator, address delegatee)
        internal
    {
        address currentDelegate = _delegates[delegator];
        uint256 delegatorBalance = _yamBalances[delegator]; 
        _delegates[delegator] = delegatee;

        emit DelegateChanged(delegator, currentDelegate, delegatee);

        _moveDelegates(currentDelegate, delegatee, delegatorBalance);
    }

    function _moveDelegates(address srcRep, address dstRep, uint256 amount) internal {
        if (srcRep != dstRep && amount > 0) {
            if (srcRep != address(0)) {
                
                uint32 srcRepNum = numCheckpoints[srcRep];
                uint256 srcRepOld = srcRepNum > 0 ? checkpoints[srcRep][srcRepNum - 1].votes : 0;
                uint256 srcRepNew = srcRepOld.sub(amount);
                _writeCheckpoint(srcRep, srcRepNum, srcRepOld, srcRepNew);
            }

            if (dstRep != address(0)) {
                
                uint32 dstRepNum = numCheckpoints[dstRep];
                uint256 dstRepOld = dstRepNum > 0 ? checkpoints[dstRep][dstRepNum - 1].votes : 0;
                uint256 dstRepNew = dstRepOld.add(amount);
                _writeCheckpoint(dstRep, dstRepNum, dstRepOld, dstRepNew);
            }
        }
    }

    function _writeCheckpoint(
        address delegatee,
        uint32 nCheckpoints,
        uint256 oldVotes,
        uint256 newVotes
    )
        internal
    {
        uint32 blockNumber = safe32(block.number, "YAM::_writeCheckpoint: block number exceeds 32 bits");

        if (nCheckpoints > 0 && checkpoints[delegatee][nCheckpoints - 1].fromBlock == blockNumber) {
            checkpoints[delegatee][nCheckpoints - 1].votes = newVotes;
        } else {
            checkpoints[delegatee][nCheckpoints] = Checkpoint(blockNumber, newVotes);
            numCheckpoints[delegatee] = nCheckpoints + 1;
        }

        emit DelegateVotesChanged(delegatee, oldVotes, newVotes);
    }

    function safe32(uint n, string memory errorMessage) internal pure returns (uint32) {
        require(n < 2**32, errorMessage);
        return uint32(n);
    }

    function getChainId() internal pure returns (uint) {
        uint256 chainId;
        assembly { chainId := chainid() }
        return chainId;
    }
}

contract YAMToken is YAMGovernanceToken {
    
    modifier onlyGov() {
        require(msg.sender == gov);
        _;
    }

    modifier onlyRebaser() {
        require(msg.sender == rebaser);
        _;
    }

    modifier onlyMinter() {
        require(
            msg.sender == rebaser
            || msg.sender == gov
            || msg.sender == incentivizer
            || msg.sender == migrator,
            "not minter"
        );
        _;
    }

    modifier validRecipient(address to) {
        require(to != address(0x0));
        require(to != address(this));
        _;
    }

    function initialize(
        string memory name_,
        string memory symbol_,
        uint8 decimals_
    )
        public
    {
        require(yamsScalingFactor == 0, "already initialized");
        name = name_;
        symbol = symbol_;
        decimals = decimals_;
    }


    
    function maxScalingFactor()
        external
        view
        returns (uint256)
    {
        return _maxScalingFactor();
    }

    function _maxScalingFactor()
        internal
        view
        returns (uint256)
    {
        
        
        return uint256(-1) / initSupply;
    }

    
    function mint(address to, uint256 amount)
        external
        returns (bool)
    {
        _mint(to, amount);
        return true;
    }

    function _mint(address to, uint256 amount)
        internal
    {
        
        totalSupply = totalSupply.add(amount);

        
        uint256 yamValue = _fragmentToYam(amount);

        
        initSupply = initSupply.add(yamValue);

        
        require(yamsScalingFactor <= _maxScalingFactor(), "max scaling factor too low");

        
        _yamBalances[to] = _yamBalances[to].add(yamValue);

        
        _moveDelegates(address(0), _delegates[to], yamValue);
        emit Mint(to, amount);
        emit Transfer(address(0), to, amount);
    }

    
    function mintUnderlying(address to, uint256 amount)
        external
        returns (bool)
    {
        _mintUnderlying(to, amount);
        return true;
    }

    function _mintUnderlying(address to, uint256 amount)
        internal
    {

        
        initSupply = initSupply.add(amount);

        
        uint256 scaledAmount = _yamToFragment(amount);

        
        totalSupply = totalSupply.add(scaledAmount);

        
        require(yamsScalingFactor <= _maxScalingFactor(), "max scaling factor too low");

        
        _yamBalances[to] = _yamBalances[to].add(amount);

        
        _moveDelegates(address(0), _delegates[to], amount);
        emit Mint(to, scaledAmount);
        emit Transfer(address(0), to, scaledAmount);
   
    }

    
    function transferUnderlying(address to, uint256 value)
        external
        validRecipient(to)
        returns (bool)
    {
        
        _yamBalances[msg.sender] = _yamBalances[msg.sender].sub(value);

        
        _yamBalances[to] = _yamBalances[to].add(value);
        emit Transfer(msg.sender, to, _yamToFragment(value));

        _moveDelegates(_delegates[msg.sender], _delegates[to], value);
        return true;
    }
    
    

    
    function transfer(address to, uint256 value)
        external
        validRecipient(to)
        returns (bool)
    {
        

        
        

        
        uint256 yamValue = _fragmentToYam(value);

        
        _yamBalances[msg.sender] = _yamBalances[msg.sender].sub(yamValue);

        
        _yamBalances[to] = _yamBalances[to].add(yamValue);
        emit Transfer(msg.sender, to, value);

        _moveDelegates(_delegates[msg.sender], _delegates[to], yamValue);
        return true;
    }

    
    function transferFrom(address from, address to, uint256 value)
        external
        validRecipient(to)
        returns (bool)
    {
        
        _allowedFragments[from][msg.sender] = _allowedFragments[from][msg.sender].sub(value);

        
        uint256 yamValue = _fragmentToYam(value);

        
        _yamBalances[from] = _yamBalances[from].sub(yamValue);
        _yamBalances[to] = _yamBalances[to].add(yamValue);
        emit Transfer(from, to, value);

        _moveDelegates(_delegates[from], _delegates[to], yamValue);
        return true;
    }

    
    function balanceOf(address who)
      external
      view
      returns (uint256)
    {
      return _yamToFragment(_yamBalances[who]);
    }

    
    function balanceOfUnderlying(address who)
      external
      view
      returns (uint256)
    {
      return _yamBalances[who];
    }

    
    function allowance(address owner_, address spender)
        external
        view
        returns (uint256)
    {
        return _allowedFragments[owner_][spender];
    }

    
    function approve(address spender, uint256 value)
        external
        returns (bool)
    {
        _allowedFragments[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    
    function increaseAllowance(address spender, uint256 addedValue)
        external
        returns (bool)
    {
        _allowedFragments[msg.sender][spender] =
            _allowedFragments[msg.sender][spender].add(addedValue);
        emit Approval(msg.sender, spender, _allowedFragments[msg.sender][spender]);
        return true;
    }

    
    function decreaseAllowance(address spender, uint256 subtractedValue)
        external
        returns (bool)
    {
        uint256 oldValue = _allowedFragments[msg.sender][spender];
        if (subtractedValue >= oldValue) {
            _allowedFragments[msg.sender][spender] = 0;
        } else {
            _allowedFragments[msg.sender][spender] = oldValue.sub(subtractedValue);
        }
        emit Approval(msg.sender, spender, _allowedFragments[msg.sender][spender]);
        return true;
    }


    
    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    )
        external
    {
        require(now <= deadline, "YAM/permit-expired");

        bytes32 digest =
            keccak256(
                abi.encodePacked(
                    "\x19\x01",
                    DOMAIN_SEPARATOR,
                    keccak256(
                        abi.encode(
                            PERMIT_TYPEHASH,
                            owner,
                            spender,
                            value,
                            nonces[owner]++,
                            deadline
                        )
                    )
                )
            );

        require(owner != address(0), "YAM/invalid-address-0");
        require(owner == ecrecover(digest, v, r, s), "YAM/invalid-permit");
        _allowedFragments[owner][spender] = value;
        emit Approval(owner, spender, value);
    }

    

    
    function _setRebaser(address rebaser_)
        external
        onlyGov
    {
        address oldRebaser = rebaser;
        rebaser = rebaser_;
        emit NewRebaser(oldRebaser, rebaser_);
    }

    
    function _setMigrator(address migrator_)
        external
        onlyGov
    {
        address oldMigrator = migrator_;
        migrator = migrator_;
        emit NewMigrator(oldMigrator, migrator_);
    }

    
    function _setIncentivizer(address incentivizer_)
        external
        onlyGov
    {
        address oldIncentivizer = incentivizer;
        incentivizer = incentivizer_;
        emit NewIncentivizer(oldIncentivizer, incentivizer_);
    }

    
    function _setPendingGov(address pendingGov_)
        external
        onlyGov
    {
        address oldPendingGov = pendingGov;
        pendingGov = pendingGov_;
        emit NewPendingGov(oldPendingGov, pendingGov_);
    }

    
    function _acceptGov()
        external
    {
        require(msg.sender == pendingGov, "!pending");
        address oldGov = gov;
        gov = pendingGov;
        pendingGov = address(0);
        emit NewGov(oldGov, gov);
    }

    

    
    function rebase(
        uint256 epoch,
        uint256 indexDelta,
        bool positive
    )
        external
        onlyRebaser
        returns (uint256)
    {
        
        if (indexDelta == 0) {
          emit Rebase(epoch, yamsScalingFactor, yamsScalingFactor);
          return totalSupply;
        }

        
        uint256 prevYamsScalingFactor = yamsScalingFactor;


        if (!positive) {
            
            yamsScalingFactor = yamsScalingFactor.mul(BASE.sub(indexDelta)).div(BASE);
        } else {
            
            uint256 newScalingFactor = yamsScalingFactor.mul(BASE.add(indexDelta)).div(BASE);
            if (newScalingFactor < _maxScalingFactor()) {
                yamsScalingFactor = newScalingFactor;
            } else {
                yamsScalingFactor = _maxScalingFactor();
            }
        }

        
        totalSupply = _yamToFragment(initSupply);

        emit Rebase(epoch, prevYamsScalingFactor, yamsScalingFactor);
        return totalSupply;
    }

    function yamToFragment(uint256 yam)
        external
        view
        returns (uint256)
    {
        return _yamToFragment(yam);
    }

    function fragmentToYam(uint256 value)
        external
        view
        returns (uint256)
    {
        return _fragmentToYam(value);
    }

    function _yamToFragment(uint256 yam)
        internal
        view
        returns (uint256)
    {
        return yam.mul(yamsScalingFactor).div(internalDecimals);
    }

    function _fragmentToYam(uint256 value)
        internal
        view
        returns (uint256)
    {
        return value.mul(internalDecimals).div(yamsScalingFactor);
    }

    
    function rescueTokens(
        address token,
        address to,
        uint256 amount
    )
        external
        onlyGov
        returns (bool)
    {
        
        SafeERC20.safeTransfer(IERC20(token), to, amount);
        return true;
    }
}

contract YAMLogic3 is YAMToken {
    
    function initialize(
        string memory name_,
        string memory symbol_,
        uint8 decimals_,
        address initial_owner,
        uint256 initTotalSupply_
    )
        public
    {
        super.initialize(name_, symbol_, decimals_);

        yamsScalingFactor = 2501323450897068507;
        initSupply = _fragmentToYam(initTotalSupply_);
        totalSupply = initTotalSupply_;
        _yamBalances[initial_owner] = initSupply;

        DOMAIN_SEPARATOR = keccak256(
            abi.encode(
                DOMAIN_TYPEHASH,
                keccak256(bytes(name)),
                getChainId(),
                address(this)
            )
        );
    }
}




contract YAMDelegationStorage {
    
    address public implementation;
}

contract YAMDelegatorInterface is YAMDelegationStorage {
    
    event NewImplementation(address oldImplementation, address newImplementation);

    
    function _setImplementation(address implementation_, bool allowResign, bytes memory becomeImplementationData) public;
}

contract YAMDelegateInterface is YAMDelegationStorage {
    
    function _becomeImplementation(bytes memory data) public;

    
    function _resignImplementation() public;
}


contract YAMDelegate3 is YAMLogic3, YAMDelegateInterface {
    
    constructor() public {}

    
    function _becomeImplementation(bytes memory data) public {
        
        data;

        
        if (false) {
            implementation = address(0);
        }

        require(msg.sender == gov, "only the gov may call _becomeImplementation");
    }

    
    function _resignImplementation() public {
        
        if (false) {
            implementation = address(0);
        }

        require(msg.sender == gov, "only the gov may call _resignImplementation");
    }
}

contract VestingPool {
    using SafeMath for uint256;
    using SafeMath for uint128;

    struct Stream {
        address recipient;
        uint128 startTime;
        uint128 length;
        uint256 totalAmount;
        uint256 amountPaidOut;
    }

    
    address public gov;

    
    address public pendingGov;

    
    mapping(address => bool) public isSubGov;

    
    uint256 public totalUnclaimedInStreams;

    
    uint256 public streamCount;

    
    mapping(uint256 => Stream) public streams;

    
    YAMDelegate3 public yam;

    
    event SubGovModified(
        address account, 
        bool isSubGov
    );

    
    event StreamOpened(
        address indexed account,
        uint256 indexed streamId,
        uint256 length,
        uint256 totalAmount
    );

    
    event StreamClosed(uint256 indexed streamId);

    
    event Payout(
        uint256 indexed streamId,
        address indexed recipient,
        uint256 amount
    );

    
    event NewPendingGov(
        address oldPendingGov, 
        address newPendingGov
    );

    
    event NewGov(
        address oldGov, 
        address newGov
    );

    constructor(YAMDelegate3 _yam)
        public
    {
        gov = msg.sender;
        yam = _yam;
    }

    modifier onlyGov() {
        require(msg.sender == gov, "VestingPool::onlyGov: account is not gov");
        _;
    }

    modifier canManageStreams() {
        require(
            isSubGov[msg.sender] || (msg.sender == gov),
            "VestingPool::canManageStreams: account cannot manage streams"
        );
        _;
    }

    
    function setSubGov(address account, bool _isSubGov)
        public
        onlyGov
    {
        isSubGov[account] = _isSubGov;
        emit SubGovModified(account, _isSubGov);
    }

    
    function _setPendingGov(address pendingGov_)
        external
        onlyGov
    {
        address oldPendingGov = pendingGov;
        pendingGov = pendingGov_;
        emit NewPendingGov(oldPendingGov, pendingGov_);
    }

    
    function _acceptGov()
        external
    {
        require(msg.sender == pendingGov, "!pending");
        address oldGov = gov;
        gov = pendingGov;
        pendingGov = address(0);
        emit NewGov(oldGov, gov);
    }

    
    function openStream(
        address recipient,
        uint128 length,
        uint256 totalAmount
    )
        public
        canManageStreams
        returns (uint256 streamIndex)
    {
        streamIndex = streamCount++;
        streams[streamIndex] = Stream({
            recipient: recipient,
            length: length,
            startTime: uint128(block.timestamp),
            totalAmount: totalAmount,
            amountPaidOut: 0
        });
        totalUnclaimedInStreams = totalUnclaimedInStreams.add(totalAmount);
        require(
            totalUnclaimedInStreams <= yam.balanceOfUnderlying(address(this)),
            "VestingPool::payout: Total streaming is greater than pool's YAM balance"
        );
        emit StreamOpened(recipient, streamIndex, length, totalAmount);
    }

    
    function closeStream(uint256 streamId)
        public
        canManageStreams
    {
        payout(streamId);
        streams[streamId] = Stream(
            address(0x0000000000000000000000000000000000000000),
            0,
            0,
            0,
            0
        );
        emit StreamClosed(streamId);
    }

    
    function payout(uint256 streamId)
        public
        returns (uint256 paidOut)
    {
        uint128 currentTime = uint128(block.timestamp);
        Stream memory stream = streams[streamId];
        require(
            stream.startTime <= currentTime,
            "VestingPool::payout: Stream hasn't started yet"
        );
        uint256 claimableUnderlying = _claimable(stream);
        streams[streamId].amountPaidOut = stream.amountPaidOut.add(
            claimableUnderlying
        );

        totalUnclaimedInStreams = totalUnclaimedInStreams.sub(
            claimableUnderlying
        );

        yam.transferUnderlying(stream.recipient, claimableUnderlying);

        emit Payout(streamId, stream.recipient, claimableUnderlying);
        return claimableUnderlying;
    }


    
    function claimable(uint256 streamId)
        external
        view
        returns (uint256 claimableUnderlying)
    {
        Stream memory stream = streams[streamId];
        return _claimable(stream);
    }

    function _claimable(Stream memory stream)
        internal
        view
        returns (uint256 claimableUnderlying)
    {
        uint128 currentTime = uint128(block.timestamp);
        uint128 elapsedTime = currentTime - stream.startTime;
        if (currentTime >= stream.startTime + stream.length) {
            claimableUnderlying = stream.totalAmount - stream.amountPaidOut;
        } else {
            claimableUnderlying = elapsedTime
                .mul(stream.totalAmount)
                .div(stream.length)
                .sub(stream.amountPaidOut);
        }
    }

}


contract MonthlyAllowance {
    using SafeMath for uint256;


    
    uint256 public constant MONTHLY_LIMIT = 100000 ether;

    
    uint256 public constant ONE_MONTH = 30 days;

    
    IERC20 public paymentAsset;

    
    address public reserves;

    
    mapping(uint256 => uint256) public spentPerEpoch;

    
    bool public initialized;

    
    uint256 public timeInitialized;

    
    bool public breaker;

    
    mapping(address => bool) public isSubGov;

    
    address public gov;

    
    address public pendingGov;

    
    event NewPendingGov(
        address oldPendingGov, 
        address newPendingGov
    );

    
    event NewGov(
        address oldGov, 
        address newGov
    );

    
    event SubGovModified(
        address account, 
        bool isSubGov
    );

    
    event Payment(
        address indexed recipient,
        uint256 assetAmount
    );

    modifier onlyGov() {
        require(msg.sender == gov, "MonthlyAllowance::onlyGov: account is not gov");
        _;
    }

    modifier onlyGovOrSubGov() {
        require(msg.sender == gov || isSubGov[msg.sender]);
        _;
    }

    modifier breakerNotSet() {
        require(!breaker, "MonthlyAllowance::breakerNotSet: breaker is set");
        _;
    }
    
    constructor(address _paymentAsset, address _reserves) public {
      gov = msg.sender;
      paymentAsset = IERC20(_paymentAsset);
      reserves = _reserves;
    }

    function initialize()
        public
        onlyGov
    {
        require(!initialized, "MonthlyAllowance::initialize: Contract is already initialized");
        timeInitialized = block.timestamp;
        initialized = true;
    }

    function pay(address recipient, uint256 amount)
        public
        onlyGovOrSubGov
        breakerNotSet
    {
        require(initialized, "MonthlyAllowance::pay: Contract not initialized");
        uint256 epoch = _currentEpoch();
        uint256 newPaidThisEpoch = spentPerEpoch[epoch].add(amount);
        require(newPaidThisEpoch <= MONTHLY_LIMIT, "MonthlyAllowance::pay: Monthly allowance exceeded");
        spentPerEpoch[epoch] = newPaidThisEpoch;
        SafeERC20.safeTransferFrom(paymentAsset, reserves, recipient, amount);
        emit Payment(recipient, amount);
    }

    function currentEpoch()
        public
        returns (uint256)
    {
        return _currentEpoch();
    }

    function _currentEpoch()
        internal
        returns (uint256)
    {
        uint256 timeSinceInitialization = block.timestamp - timeInitialized;
        uint256 epoch = timeSinceInitialization / ONE_MONTH;
        return epoch;
    }

    function flipBreaker()
        public
        onlyGov
        breakerNotSet
    {
        breaker = true;
    }

    function _setPendingGov(address pending)
        public
        onlyGov
    {
        require(pending != address(0));
        address oldPending = pendingGov;
        pendingGov = pending;
        emit NewPendingGov(oldPending, pending);
    }

    function acceptGov()
        public
    {
        require(msg.sender == pendingGov);
        address old = gov;
        gov = pendingGov;
        emit NewGov(old, pendingGov);
    }

    function setIsSubGov(address subGov, bool _isSubGov)
        public
        onlyGov
    {
        isSubGov[subGov] = _isSubGov;
        emit SubGovModified(subGov, _isSubGov);
    }


}

contract StreamManager {
    VestingPool internal constant pool =
        VestingPool(0xDCf613db29E4d0B35e7e15e93BF6cc6315eB0b82);

    MonthlyAllowance internal constant MONTHLY_ALLOWANCE =
        MonthlyAllowance(0x03A882495Bc616D3a1508211312765904Fb062d1);

    function execute() external {
        
        MONTHLY_ALLOWANCE.pay(
            0x8A8acf1cEcC4ed6Fe9c408449164CE2034AdC03f,
            yearlyUSDToMonthlyYUSD(120000 * (10**18))
        );
        MONTHLY_ALLOWANCE.pay(
            0xEC3281124d4c2FCA8A88e3076C1E7749CfEcb7F2,
            yearlyUSDToMonthlyYUSD(105000 * (10**18))
        );
        MONTHLY_ALLOWANCE.pay(
            0xbdac5657eDd13F47C3DD924eAa36Cf1Ec49672cc,
            yearlyUSDToMonthlyYUSD(72000 * (10**18))
        );
        MONTHLY_ALLOWANCE.pay(
            0x01e0C7b70E0E05a06c7cC8deeb97Fa03d6a77c9C,
            yearlyUSDToMonthlyYUSD(84000 * (10**18))
        );
        MONTHLY_ALLOWANCE.pay(
            0xcc506b3c2967022094C3B00276617883167BF32B,
            yearlyUSDToMonthlyYUSD(30000 * (10**18))
        );
        MONTHLY_ALLOWANCE.pay(
            0x3FdcED6B5C1f176b543E5E0b841cB7224596C33C,
            yearlyUSDToMonthlyYUSD(96000 * (10**18))
        );
        MONTHLY_ALLOWANCE.pay(
            0xC45d45b54045074Ed12d1Fe127f714f8aCE46f8c,
            yearlyUSDToMonthlyYUSD(45000 * (10**18))
        );
        MONTHLY_ALLOWANCE.pay(
            0x9098eab0a361D29Ea5c4b5d9d1f50694ac0E9e78,
            yearlyUSDToMonthlyYUSD(36000 * (10**18))
        );
        MONTHLY_ALLOWANCE.pay(
            0xFcB4f3a1710FefA583e7b003F3165f2E142bC725,
            yearlyUSDToMonthlyYUSD(60000 * (10**18))
        );
        MONTHLY_ALLOWANCE.pay(
            0x31920DF2b31B5f7ecf65BDb2c497DE31d299d472,
            yearlyUSDToMonthlyYUSD(60000 * (10**18))
        );

        
        pool.closeStream(22);
        pool.openStream(
            0xf5f1287F7B71381fFB5Caf3b61fA0375112531BC,
            30 days,
            1250 * 3 * (10**24)
        );

        
        pool.closeStream(39);
        pool.openStream(
            0x392027fDc620d397cA27F0c1C3dCB592F27A4dc3,
            30 days,
            256 * 1 * (10**24)
        );

        
        pool.closeStream(41);
        pool.openStream(
            0x0Da87C54F853c2CF1221dbE725018944C83BDA7C,
            90 days,
            1280 * 1 * (10**24)
        );

        
        pool.payout(
            pool.openStream(
                0xeEFA7451c03d52ce909A93654664c46cf81DdD21,
                0 days,
                800 * (10**24)
            )
        );

        
        pool.openStream(
            0x1b5C706296888a9C52f0c6dcF0579b638bA7EF2a,
            90 days,
            536 * 3 * (10**24)
        );

        
        pool.openStream(
            0x31920DF2b31B5f7ecf65BDb2c497DE31d299d472,
            90 days,
            6664 * 3 * (10**23) 
        );

        
        pool.closeStream(35);

        
        pool.payout(
            pool.openStream(
                0x744D16d200175d20E6D8e5f405AEfB4EB7A962d1,
                0 days,
                7995767197891679725573970579 
            )
        );

        selfdestruct(address(0x0));
    }

    function yearlyUSDToMonthlyYUSD(uint256 yearlyUSD)
        internal
        pure
        returns (uint256)
    {
        
        return ((yearlyUSD / uint256(12)) * 100) / uint256(129);
    }
}