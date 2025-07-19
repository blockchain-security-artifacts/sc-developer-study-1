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

contract UMADistributor {
    IERC20 private constant TOKEN =
        IERC20(0x04Fa0d235C4abf4BcF4787aF4CF447DE572eF828);

    function execute() external {

        TOKEN.transferFrom(0x97990B693835da58A281636296D2Bf02787DEa17, address(this),405134802037641846232);
        TOKEN.transfer(
            0xdD395050aC923466D3Fa97D41739a4ab6b49E9F5,
            400284278280230651730
        );
        TOKEN.transfer(
            0x4565Ee03a020dAA77c5EfB25F6DD32e28d653c27,
            984436396439672795
        );
        TOKEN.transfer(
            0x974678F5aFF73Bf7b5a157883840D752D01f1973,
            3312978575741423215
        );
        TOKEN.transfer(
            0x8CC7355a5c07207ef6ee188F7b74757b6bAb7DAc,
            553108785230098492
        );
        selfdestruct(address(0x0));
    }
}