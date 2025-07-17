pragma solidity 0.6.12;


library MerkleProof {
    
    function verify(bytes32[] memory proof, bytes32 root, bytes32 leaf) internal pure returns (bool) {
        bytes32 computedHash = leaf;

        for (uint256 i = 0; i < proof.length; i++) {
            bytes32 proofElement = proof[i];

            if (computedHash <= proofElement) {
                
                computedHash = keccak256(abi.encodePacked(computedHash, proofElement));
            } else {
                
                computedHash = keccak256(abi.encodePacked(proofElement, computedHash));
            }
        }

        
        return computedHash == root;
    }
}


interface IFlashToken {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    function mint(address to, uint256 value) external returns (bool);

    function burn(uint256 value) external returns (bool);
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


contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    
    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    
    function owner() public view returns (address) {
        return _owner;
    }

    
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}




contract ClaimContract is Ownable{
    using MerkleProof for bytes;
    uint256 public EXPIRY_TIME;
    address public FLASH_CONTRACT;
    bytes32 public merkleRoot;
    mapping(uint256 => uint256) private claimedBitMap;

    event Claimed(uint256 index, address sender, uint256 amount);
    
    constructor(address contractAddress, bytes32 rootHash, uint256 totalDays) public {
        FLASH_CONTRACT = contractAddress;
        merkleRoot = rootHash;
        EXPIRY_TIME = block.timestamp + totalDays;
    }

    function updateRootAndTime(bytes32 rootHash, uint256 totalDays) external onlyOwner {
        merkleRoot = rootHash;
        EXPIRY_TIME = block.timestamp + totalDays;
        renounceOwnership();
    }

    function isClaimed(uint256 index) public view returns (bool) {
        uint256 claimedWordIndex = index / 256;
        uint256 claimedBitIndex = index % 256;
        uint256 claimedWord = claimedBitMap[claimedWordIndex];
        uint256 mask = (1 << claimedBitIndex);
        return claimedWord & mask == mask;
    }

    function _setClaimed(uint256 index) private {
        uint256 claimedWordIndex = index / 256;
        uint256 claimedBitIndex = index % 256;
        claimedBitMap[claimedWordIndex] = claimedBitMap[claimedWordIndex] | (1 << claimedBitIndex);
    }

    function claim(
        uint256 index,
        address account,
        uint256 amount,
        bytes32[] calldata merkleProof
    ) external {
        require(block.timestamp <= EXPIRY_TIME, "MerkleDistributor: Deadline expired");

        require(!isClaimed(index), "MerkleDistributor: Drop already claimed.");

        
        bytes32 node = keccak256(abi.encodePacked(index, account, amount));
        require(MerkleProof.verify(merkleProof, merkleRoot, node), "MerkleDistributor: Invalid proof.");

        
        _setClaimed(index);
        require(IFlashToken(FLASH_CONTRACT).mint(account, amount), "MerkleDistributor: Transfer failed.");

        emit Claimed(index, account, amount);
    }

    function destroy() external {
        require(block.timestamp >= EXPIRY_TIME, "MerkleDistributor: Deadline not expired");
        selfdestruct(address(0));
    }
}