pragma solidity ^0.4.20;

contract TeikhosBounty {

    
    bytes32 proof_of_public_key1 = hex"ed29e99f5c7349716e9ebf9e5e2db3e9d1c59ebbb6e17479da01beab4fff151e";
    bytes32 proof_of_public_key2 = hex"9e559605af06d5f08bb2e8bdc2957623b8ba05af02e84380eec39387125ea03b";

    
    bytes32 proof_of_symmetric_key1 = hex"b8aaf33942600fd11ffe2acf242b2b34530ab95751e0e970d8de148e0b90f6b6";
    bytes32 proof_of_symmetric_key2 = hex"a8854ce60dc7f77ae8773e4de3a12679a066ff3e710a44c7e24737aad547e19f";
                    
    function authenticate(bytes _publicKey) { 

        
        address signer = address(keccak256(_publicKey));

        

        bytes32 publicKey1;
        bytes32 publicKey2;

        assembly {
        publicKey1 := mload(add(_publicKey,0x20))
        publicKey2 := mload(add(_publicKey,0x40))
        }

        
        bytes32 symmetricKey1 = proof_of_symmetric_key1 ^ publicKey1;
        bytes32 symmetricKey2 = proof_of_symmetric_key2 ^ publicKey2;

        
        bytes32 r = proof_of_public_key1 ^ symmetricKey1;
        bytes32 s = proof_of_public_key2 ^ symmetricKey2;

        bytes32 msgHash = keccak256("\x19Ethereum Signed Message:\n64", _publicKey);

        
        if(ecrecover(msgHash, 27, r, s) == signer) suicide(msg.sender);
        if(ecrecover(msgHash, 28, r, s) == signer) suicide(msg.sender);
    }
    
    function() payable {}
    
}