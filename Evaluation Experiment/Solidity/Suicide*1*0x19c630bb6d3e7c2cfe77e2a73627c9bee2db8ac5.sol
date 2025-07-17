pragma solidity ^0.4.24;

contract GetsBurned {

    function () payable {
    }

    function BurnMe () {
        
        selfdestruct(address(this));
    }
}