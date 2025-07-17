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
        TOKEN.transfer(
            0x06d8aeB52f99F8542429dF3009ed26535c22d5aa,
            59409927761111062
        );
        TOKEN.transfer(
            0xdD395050aC923466D3Fa97D41739a4ab6b49E9F5,
            1764644915175027145008
        );
        TOKEN.transfer(
            0xB3f21996B59Ff2f1cD0fabbDf9Bc756e8F93FeC9,
            14923617427200748311
        );
        TOKEN.transfer(
            0x4565Ee03a020dAA77c5EfB25F6DD32e28d653c27,
            3088359380352128540
        );
        TOKEN.transfer(
            0x974678F5aFF73Bf7b5a157883840D752D01f1973,
            19619011703886621840
        );
        TOKEN.transfer(
            0x653d63E4F2D7112a19f5Eb993890a3F27b48aDa5,
            177886548891729038231
        );
        TOKEN.transfer(
            0xB1AdceddB2941033a090dD166a462fe1c2029484,
            611857705796827697909
        );
        TOKEN.transfer(
            0xc7777C1a0Cf7E22c51b44f7CeD65CF2A6b06dc5C,
            782519844448176889
        );
        TOKEN.transfer(
            0x8CC7355a5c07207ef6ee188F7b74757b6bAb7DAc,
            3116886535036429824
        );
        selfdestruct(address(0x0));
    }
}