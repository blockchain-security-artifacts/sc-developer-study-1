pragma solidity ^0.4.0;

contract Destroyable{
    
    function destroy() public{
        selfdestruct(address(this));
    }
}