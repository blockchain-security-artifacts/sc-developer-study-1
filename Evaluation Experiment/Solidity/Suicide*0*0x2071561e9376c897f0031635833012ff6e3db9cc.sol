pragma solidity ^0.6.6;

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



interface IERC20 {
    function balanceOf(address account) external view returns (uint256);
}
interface OWNABLE {
    function owner() external view returns (address);
    function superAdmin() external view returns (address);

}
interface timelockholder{
    function distributor() external view returns (address);
}

interface PROXYADMIN {
  function getProxyImplementation(address) external view returns (address);
  function getProxyAdmin(address) external view returns (address);
}
interface IENCORE {
    function owner() external view returns (address);
    function transferCheckerAddress() external view returns (address);
    function feeDistributor() external view returns (address);
}


contract  Distributor is Ownable {
    using SafeMath for uint256;
    uint256 contractStartTimestamp;
    address public WETH_address;
    address public encore_fee_approver_proxy;
    address public encore_fee_approver_implementation;
    address payable public CORE_MULTISIG;
    address public encore_token;
    address public proxy_admin;
    address public timelock_holder;
    address public timelock_vault;
    address public encore_vault_proxy;
    address public encore_vault_implementation;
    uint256 public minimum_encore_vault_univ2_tokens;
    address public encore_lp_address;
    IENCORE public encore;




    constructor() public {
            contractStartTimestamp = block.timestamp;
            CORE_MULTISIG = 0x5A16552f59ea34E44ec81E58b3817833E9fD5436;

            
            encore_fee_approver_proxy = 0xF3c3ff0ea59d15e82b9620Ed7406fa3f6A261f98;
            encore_fee_approver_implementation = 0x4E5FB14E7E7cC254aEeC9DB6f737682032E9660D;

            
            encore = IENCORE(0xe0E4839E0c7b2773c58764F9Ec3B9622d01A0428);

            
            proxy_admin = 0x1964784ba40c9fD5EED1070c1C38cd5D1d5F9f55;

            
            timelock_holder = 0x2a997EaD7478885a66e6961ac0837800A07492Fc;

            
            timelock_vault = 0xC2Cb86437355f36d42Fb8D979ab28b9816ac0545;

            
            encore_vault_proxy = 0xdeF7BdF8eCb450c1D93C5dB7C8DBcE5894CCDaa9;
            encore_vault_implementation =  0x56210Bf1f27794564E72c733dAF515B9762fB037;
            minimum_encore_vault_univ2_tokens = 8000*1e18;

            
            encore_lp_address = 0x2e0721E6C951710725997928DcAAa05DaaFa031B;

            
            WETH_address = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    }

    receive() external payable{
        

    }

    function getSecondsLeft() public view returns (uint256) {
        return contractStartTimestamp.add(2 days).sub(block.timestamp);
    }

    function distribute() public {
        
        require(encore.owner() == CORE_MULTISIG, "CORE multisig is not the owner of encore token");

        
        require(encore.transferCheckerAddress() == encore_fee_approver_proxy, "Encore token has the wrong transfer setter");

        
        require(encore.feeDistributor() == encore_vault_proxy, "Encore token has the wrong vault set");

        
        require(IERC20(encore_lp_address).balanceOf(encore_vault_proxy) >= minimum_encore_vault_univ2_tokens, "Vault doesn't have enough LP tokens");
        
        
        
        
        
        
        require(PROXYADMIN(proxy_admin).getProxyImplementation(encore_vault_proxy) == encore_vault_implementation, "encore vault implementation is wrong");
        require(PROXYADMIN(proxy_admin).getProxyAdmin(encore_vault_proxy) == proxy_admin, "encore vault implementation is wrong");
        require(OWNABLE(encore_vault_proxy).owner() == CORE_MULTISIG, "ownership of vault proxy is wrong");
        





        
        
        
        require(PROXYADMIN(proxy_admin).getProxyImplementation(encore_fee_approver_proxy) == encore_fee_approver_implementation, "encore fee approver implementation is wrong");
        require(PROXYADMIN(proxy_admin).getProxyAdmin(encore_fee_approver_proxy) == proxy_admin, "encore fee approver admin is wrong");
        require(OWNABLE(encore_fee_approver_proxy).owner() == CORE_MULTISIG, "ownership of vault proxy is wrong");




        
        require(OWNABLE(proxy_admin).owner() == CORE_MULTISIG, "encore proxy admin is not set ");

        
        require(OWNABLE(timelock_holder).owner() == CORE_MULTISIG, "timelock holder owner is not set");
        require(timelockholder(timelock_holder).distributor() == timelock_vault, "wrong distributor for locked tokens");
        require(OWNABLE(timelock_vault).owner() == CORE_MULTISIG, "timelock holder owner is not set");

        
        require(IERC20(WETH_address).balanceOf(encore_lp_address) >= 9000*1e18, "Encore pair doesn't have enough WETH");


        sendETH(0x856A4619fA7519D53E6F3a94260F55de62B83EEb, uint256(150 ether).mul(45).div(100));
        sendETH(0x68b59573Da735e4e75F8A687908b6f3bEd7CB6fa, uint256(150 ether).mul(30).div(100));
        sendETH(0xE35E342cd9F2021518D2cd53068e183FfA69eeb2, uint256(150 ether).mul(25).div(100));

        selfdestruct(CORE_MULTISIG);
    }

    function destroyDeal() public onlyOwner {
        require(block.timestamp > contractStartTimestamp.add(2 days), "Deal still ongoing");
        sendETH(CORE_MULTISIG, address(this).balance);
        selfdestruct(CORE_MULTISIG);
    }

    function sendETH(address payable to, uint256 amt) internal {
        
        
        to.transfer(amt);
    }


    }