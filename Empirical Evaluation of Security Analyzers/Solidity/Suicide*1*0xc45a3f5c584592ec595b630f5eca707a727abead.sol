pragma solidity >=0.7.0 <0.9.0;

contract WillstDuMeinTrauzeugeSein {

    bool private antwort;  
    bytes32 private hash = 0x44cb61ba64c1b4708acd17c0bc86a0a4eec01308bb674b33ef8d477a5831831a;

    function ja (string calldata geheimnis) public {
        require(sha256(bytes(geheimnis)) == hash);
        antwort = true;
    }
    
    function nein (string calldata geheimnis) public {
        require(sha256(bytes(geheimnis)) == hash);
        require(!antwort);
        selfdestruct(payable(msg.sender));
    }

}