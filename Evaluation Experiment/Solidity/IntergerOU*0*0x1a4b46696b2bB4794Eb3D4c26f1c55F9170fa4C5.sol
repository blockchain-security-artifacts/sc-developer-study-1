library SafeMath {
    
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        uint256 c = a + b;
        if (c < a) return (false, 0);
        return (true, c);
    }

    
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b > a) return (false, 0);
        return (true, a - b);
    }

    
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        
        
        
        if (a == 0) return (true, 0);
        uint256 c = a * b;
        if (c / a != b) return (false, 0);
        return (true, c);
    }

    
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b == 0) return (false, 0);
        return (true, a / b);
    }

    
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b == 0) return (false, 0);
        return (true, a % b);
    }

    
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        return a - b;
    }

    
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) return 0;
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: division by zero");
        return a / b;
    }

    
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: modulo by zero");
        return a % b;
    }

    
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        return a - b;
    }

    
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        return a / b;
    }

    
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        return a % b;
    }
}








library Math {
    
    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a : b;
    }

    
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    
    function average(uint256 a, uint256 b) internal pure returns (uint256) {
        
        return (a / 2) + (b / 2) + ((a % 2 + b % 2) / 2);
    }
}










library Arrays {
   
    function findUpperBound(uint256[] storage array, uint256 element) internal view returns (uint256) {
        if (array.length == 0) {
            return 0;
        }

        uint256 low = 0;
        uint256 high = array.length;

        while (low < high) {
            uint256 mid = Math.average(low, high);

            
            
            if (array[mid] > element) {
                high = mid;
            } else {
                low = mid + 1;
            }
        }

        
        if (low > 0 && array[low - 1] == element) {
            return low - 1;
        } else {
            return low;
        }
    }
}










library Counters {
    using SafeMath for uint256;

    struct Counter {
        
        
        
        uint256 _value; 
    }

    function current(Counter storage counter) internal view returns (uint256) {
        return counter._value;
    }

    function increment(Counter storage counter) internal {
        
        counter._value += 1;
    }

    function decrement(Counter storage counter) internal {
        counter._value = counter._value.sub(1);
    }
}








abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; 
        return msg.data;
    }
}








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












contract ERC20 is Context, IERC20 {
    using SafeMath for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    
    constructor (string memory name_, string memory symbol_) public {
        _name = name_;
        _symbol = symbol_;
        _decimals = 18;
    }

    
    function name() public view virtual returns (string memory) {
        return _name;
    }

    
    function symbol() public view virtual returns (string memory) {
        return _symbol;
    }

    
    function decimals() public view virtual returns (uint8) {
        return _decimals;
    }

    
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    
    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    
    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    
    function _transfer(address sender, address recipient, uint256 amount) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    
    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    
    function _setupDecimals(uint8 decimals_) internal virtual {
        _decimals = decimals_;
    }

    
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }
}




pragma solidity >=0.6.5 <0.8.0;






contract BitDAO is ERC20 {
	using SafeMath for uint256;
	using Arrays for uint256[];
	using Counters for Counters.Counter;

	uint256 public MAX_SUPPLY = 1e28; 

	address public admin;

	address public pendingAdmin;

	mapping(address => address) public delegates;

	struct Checkpoint {
		uint256 fromBlock;
		uint256 votes;
	}

	mapping(address => mapping(uint256 => Checkpoint)) public checkpoints;

	mapping(address => uint256) public numCheckpoints;

	bytes32 public constant DOMAIN_TYPEHASH =
		keccak256('EIP712Domain(string name,uint256 chainId,address verifyingContract)');

	bytes32 public constant DELEGATION_TYPEHASH =
		keccak256('Delegation(address delegatee,uint256 nonce,uint256 expiry)');

	mapping(address => uint256) public nonces;

	struct Snapshots {
		uint256[] ids;
		uint256[] values;
	}

	mapping(address => Snapshots) private _accountBalanceSnapshots;

	Snapshots private _totalSupplySnapshots;

	Counters.Counter private _currentSnapshotId;

	event Snapshot(uint256 id);

	event DelegateChanged(address indexed delegator, address indexed fromDelegate, address indexed toDelegate);

	event DelegateVotesChanged(address indexed delegate, uint256 previousBalance, uint256 newBalance);

	event NewPendingAdmin(address indexed oldPendingAdmin, address indexed newPendingAdmin);

	event NewAdmin(address indexed oldAdmin, address indexed newAdmin);

	modifier onlyAdmin {
		require(msg.sender == admin, 'Caller is not a admin');
		_;
	}

	constructor(address _admin) ERC20('BitDAO', 'BIT') {
		admin = _admin;
		_mint(_admin, MAX_SUPPLY);
	}

	function setPendingAdmin(address newPendingAdmin) external returns (bool) {
		if (msg.sender != admin) {
			revert('BitDAO:setPendingAdmin:illegal address');
		}
		address oldPendingAdmin = pendingAdmin;
		pendingAdmin = newPendingAdmin;

		emit NewPendingAdmin(oldPendingAdmin, newPendingAdmin);

		return true;
	}

	function acceptAdmin() external returns (bool) {
		if (msg.sender != pendingAdmin || msg.sender == address(0)) {
			revert('BitDAO:acceptAdmin:illegal address');
		}
		address oldAdmin = admin;
		address oldPendingAdmin = pendingAdmin;
		admin = pendingAdmin;
		pendingAdmin = address(0);

		emit NewAdmin(oldAdmin, admin);
		emit NewPendingAdmin(oldPendingAdmin, pendingAdmin);

		return true;
	}

	function snapshot() external virtual onlyAdmin returns (uint256) {
		_currentSnapshotId.increment();

		uint256 currentId = _currentSnapshotId.current();
		emit Snapshot(currentId);
		return currentId;
	}

	function balanceOfAt(address account, uint256 snapshotId) public view virtual returns (uint256) {
		(bool snapshotted, uint256 value) = _valueAt(snapshotId, _accountBalanceSnapshots[account]);

		return snapshotted ? value : balanceOf(account);
	}

	function totalSupplyAt(uint256 snapshotId) public view virtual returns (uint256) {
		(bool snapshotted, uint256 value) = _valueAt(snapshotId, _totalSupplySnapshots);

		return snapshotted ? value : totalSupply();
	}

	function _beforeTokenTransfer(
		address from,
		address to,
		uint256 amount
	) internal virtual override {
		super._beforeTokenTransfer(from, to, amount);
		if (from == address(0)) {
			
			_updateAccountSnapshot(to);
			_updateTotalSupplySnapshot();
		} else if (to == address(0)) {
			
			_updateAccountSnapshot(from);
			_updateTotalSupplySnapshot();
		} else {
			
			_updateAccountSnapshot(from);
			_updateAccountSnapshot(to);
		}
	}

	function _valueAt(uint256 snapshotId, Snapshots storage snapshots) private view returns (bool, uint256) {
		require(snapshotId > 0, 'ERC20Snapshot: id is 0');
		require(snapshotId <= _currentSnapshotId.current(), 'ERC20Snapshot: nonexistent id');

		uint256 index = snapshots.ids.findUpperBound(snapshotId);

		if (index == snapshots.ids.length) {
			return (false, 0);
		} else {
			return (true, snapshots.values[index]);
		}
	}

	function _updateAccountSnapshot(address account) private {
		_updateSnapshot(_accountBalanceSnapshots[account], balanceOf(account));
	}

	function _updateTotalSupplySnapshot() private {
		_updateSnapshot(_totalSupplySnapshots, totalSupply());
	}

	function _updateSnapshot(Snapshots storage snapshots, uint256 currentValue) private {
		uint256 currentId = _currentSnapshotId.current();
		if (_lastSnapshotId(snapshots.ids) < currentId) {
			snapshots.ids.push(currentId);
			snapshots.values.push(currentValue);
		}
	}

	function _lastSnapshotId(uint256[] storage ids) private view returns (uint256) {
		if (ids.length == 0) {
			return 0;
		} else {
			return ids[ids.length - 1];
		}
	}

	function delegate(address delegatee) external {
		return _delegate(msg.sender, delegatee);
	}

	function delegateBySig(
		address delegatee,
		uint256 nonce,
		uint256 expiry,
		uint8 v,
		bytes32 r,
		bytes32 s
	) external {
		bytes32 domainSeparator =
			keccak256(abi.encode(DOMAIN_TYPEHASH, keccak256(bytes(name())), getChainId(), address(this)));
		bytes32 structHash = keccak256(abi.encode(DELEGATION_TYPEHASH, delegatee, nonce, expiry));
		bytes32 digest = keccak256(abi.encodePacked('\x19\x01', domainSeparator, structHash));
		address signatory = ecrecover(digest, v, r, s);
		require(signatory != address(0), 'BitDAO::delegateBySig: invalid signature');
		require(nonce == nonces[signatory]++, 'BitDAO::delegateBySig: invalid nonce');
		require(block.timestamp <= expiry, 'BitDAO::delegateBySig: signature expired');
		return _delegate(signatory, delegatee);
	}

	function getCurrentVotes(address account) external view returns (uint256) {
		uint256 nCheckpoints = numCheckpoints[account];
		return nCheckpoints > 0 ? checkpoints[account][nCheckpoints - 1].votes : 0;
	}

	function getPriorVotes(address account, uint256 blockNumber) public view returns (uint256) {
		require(blockNumber < block.number, 'BitDAO::getPriorVotes: not yet determined');

		uint256 nCheckpoints = numCheckpoints[account];
		if (nCheckpoints == 0) {
			return 0;
		}

		if (checkpoints[account][nCheckpoints - 1].fromBlock <= blockNumber) {
			return checkpoints[account][nCheckpoints - 1].votes;
		}

		if (checkpoints[account][0].fromBlock > blockNumber) {
			return 0;
		}

		uint256 lower = 0;
		uint256 upper = nCheckpoints - 1;
		while (upper > lower) {
			uint256 center = upper - (upper - lower) / 2;
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

	function _delegate(address delegator, address delegatee) internal {
		address currentDelegate = delegates[delegator];
		uint256 delegatorBalance = balanceOf(delegator);
		delegates[delegator] = delegatee;

		emit DelegateChanged(delegator, currentDelegate, delegatee);

		_moveDelegates(currentDelegate, delegatee, delegatorBalance);
	}

	function _transfer(
		address sender,
		address recipient,
		uint256 amount
	) internal virtual override {
		super._transfer(sender, recipient, amount);
		_moveDelegates(delegates[sender], delegates[recipient], amount);
	}

	function _moveDelegates(
		address srcRep,
		address dstRep,
		uint256 amount
	) internal {
		if (srcRep != dstRep && amount > 0) {
			if (srcRep != address(0)) {
				uint256 srcRepNum = numCheckpoints[srcRep];
				uint256 srcRepOld = srcRepNum > 0 ? checkpoints[srcRep][srcRepNum - 1].votes : 0;
				uint256 srcRepNew = srcRepOld.sub(amount);
				_writeCheckpoint(srcRep, srcRepNum, srcRepOld, srcRepNew);
			}

			if (dstRep != address(0)) {
				uint256 dstRepNum = numCheckpoints[dstRep];
				uint256 dstRepOld = dstRepNum > 0 ? checkpoints[dstRep][dstRepNum - 1].votes : 0;
				uint256 dstRepNew = dstRepOld.add(amount);
				_writeCheckpoint(dstRep, dstRepNum, dstRepOld, dstRepNew);
			}
		}
	}

	function _writeCheckpoint(
		address delegatee,
		uint256 nCheckpoints,
		uint256 oldVotes,
		uint256 newVotes
	) internal {
		uint256 blockNumber = safe32(block.number, 'BitDAO::_writeCheckpoint: block number exceeds 32 bits');

		if (nCheckpoints > 0 && checkpoints[delegatee][nCheckpoints - 1].fromBlock == blockNumber) {
			checkpoints[delegatee][nCheckpoints - 1].votes = newVotes;
		} else {
			checkpoints[delegatee][nCheckpoints] = Checkpoint(blockNumber, newVotes);
			numCheckpoints[delegatee] = nCheckpoints + 1;
		}

		emit DelegateVotesChanged(delegatee, oldVotes, newVotes);
	}

	function safe32(uint256 n, string memory errorMessage) internal pure returns (uint256) {
		require(n < 2**32, errorMessage);
		return uint256(n);
	}

	function getChainId() internal pure returns (uint256) {
		uint256 chainId;
		assembly {
			chainId := chainid()
		}
		return chainId;
	}
}