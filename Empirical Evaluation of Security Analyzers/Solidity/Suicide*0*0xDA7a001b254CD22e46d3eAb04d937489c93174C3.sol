pragma solidity 0.6.11;
pragma experimental ABIEncoderV2;


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

interface IStdReference {
    
    struct ReferenceData {
        uint256 rate; 
        uint256 lastUpdatedBase; 
        uint256 lastUpdatedQuote; 
    }

    
    function getReferenceData(string memory _base, string memory _quote)
        external
        view
        returns (ReferenceData memory);

    
    function getReferenceDataBulk(string[] memory _bases, string[] memory _quotes)
        external
        view
        returns (ReferenceData[] memory);
}

abstract contract StdReferenceBase is IStdReference {
    function getReferenceData(string memory _base, string memory _quote)
        public
        virtual
        override
        view
        returns (ReferenceData memory);

    function getReferenceDataBulk(string[] memory _bases, string[] memory _quotes)
        public
        override
        view
        returns (ReferenceData[] memory)
    {
        require(_bases.length == _quotes.length, "BAD_INPUT_LENGTH");
        uint256 len = _bases.length;
        ReferenceData[] memory results = new ReferenceData[](len);
        for (uint256 idx = 0; idx < len; idx++) {
            results[idx] = getReferenceData(_bases[idx], _quotes[idx]);
        }
        return results;
    }
}

contract StdReferenceProxy is Ownable, StdReferenceBase {
    IStdReference public ref;

    constructor(IStdReference _ref) public {
        ref = _ref;
    }

    
    function setRef(IStdReference _ref) public onlyOwner {
        ref = _ref;
    }

    
    function getReferenceData(string memory _base, string memory _quote)
        public
        override
        view
        returns (ReferenceData memory)
    {
        return ref.getReferenceData(_base, _quote);
    }
}