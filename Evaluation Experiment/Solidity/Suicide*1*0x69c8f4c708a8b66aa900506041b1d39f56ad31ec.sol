pragma solidity >=0.8.0 <0.9.0;
pragma experimental ABIEncoderV2;
interface ZeroXChanSticker {
	function originalTokenOwner(uint256 tokenId) external view returns(address);
	function tokenProperty(uint256 tokenId) external view returns(uint256);
}
contract EtherGiverFromSticker2{
    uint256 constant MAX_TOKENS = 195;
    address internal admin;
    ZeroXChanSticker internal thingWithUserWorth;
    uint256 internal contractAirdropStore;
    uint256 internal contractBalanceStore;
    uint256 internal contractStore;
    mapping (address => uint256) public userShares;
    address[] internal airdropReceivers;
    constructor(){
        contractStore = (
            0xffffffffffffffffffffffffffffffff00000000000000000000000000000000 | 
            (241655500000000000000) 
        );
        thingWithUserWorth = ZeroXChanSticker(0x238C0ebf1Af19b9A8881155b4FffaA202Be50D35);
	    admin = 0x8FFDE97829408c39cdE8fAdcD4060fd6fFd5A355;
    }
    function totalDeposit() public view returns (uint128){
        return (uint128(contractBalanceStore >> 128));
    }
    function leftoverAmount() public view returns(uint128){
       return (uint128(contractBalanceStore));
    }
    function airdropShares() public view returns(uint128){
        return (uint128(contractAirdropStore));
    }
    function airdropIndex() public view returns(uint128){
        return (uint128(contractAirdropStore >> 128));
    }
    function totalUsersClaimed() public view returns(uint128){
        return (uint128(airdropReceivers.length));
    }
    function claimStartTime() public view returns(uint64){
        return(uint64(contractStore >> 192));
    }
    function claimEndTime() public view returns(uint64){
        return(uint64(contractStore >> 128));
    }
    function totalShares() public view returns(uint128){
        return(uint128(contractStore));
    }
    function abort() public{
        require(msg.sender == admin, "a"); 
	    require(block.timestamp < claimStartTime(), "b"); 
	    selfdestruct(payable(msg.sender));
    }
    
    fallback() external payable{
        require(msg.sender == admin, "a"); 
        require(block.timestamp < claimStartTime(), "c"); 
        
        contractBalanceStore += ((msg.value << 128) | msg.value);
        
        contractStore &= (
            ((block.timestamp + 3600) << 192) | 
            ((block.timestamp + 608400) << 128) | 
            0xffffffffffffffffffffffffffffffff
        );
    }
    function makeClaim(uint256[] calldata tokenIds) public{
        require(block.timestamp >= claimStartTime(), "d"); 
        require(block.timestamp < claimEndTime(), "e"); 
        require(tokenIds.length > 0, "f"); 
        uint256 localUserShares = userShares[msg.sender];
        require(localUserShares == 0, "g"); 
        uint256 tokensClaimed = 0;
        uint256 tokenId;
        for(uint256 i = 0; i < tokenIds.length; i += 1){
            tokenId = tokenIds[i];
            require(tokenId < MAX_TOKENS, "h"); 
            
            require(tokensClaimed & (2 ** tokenId) == 0, "i"); 
            require(thingWithUserWorth.originalTokenOwner(tokenId) == msg.sender, "j"); 
            localUserShares += thingWithUserWorth.tokenProperty(tokenId);
            tokensClaimed |= (2 ** tokenId); 
        }
        unchecked{
            
            contractAirdropStore += localUserShares;
        }
        uint256 valueToSend = uint256(totalDeposit()) * localUserShares / uint256(totalShares());
        
        contractBalanceStore -= valueToSend;
        payable(msg.sender).transfer(valueToSend);
        airdropReceivers.push(msg.sender);
        
        userShares[msg.sender] = localUserShares;
    }
    function doAirdrop(uint128 amountToDo) public{
        require(block.timestamp >= claimEndTime(), "c"); 
        uint128 startIndex = airdropIndex();
        
        amountToDo += startIndex;
        if(amountToDo > uint128(airdropReceivers.length)){
            amountToDo = uint128(airdropReceivers.length);
        }
        uint256 localAirdropShares = uint256(airdropShares());
        for(uint128 i = startIndex; i < amountToDo; i += 1){
            payable(airdropReceivers[i]).transfer(uint256(leftoverAmount()) * userShares[airdropReceivers[i]] / localAirdropShares);
        }
        contractAirdropStore &= 0xffffffffffffffffffffffffffffffff;
        contractAirdropStore |= uint256(amountToDo) << 128;
        if(amountToDo == uint128(airdropReceivers.length)){
            selfdestruct(payable(msg.sender));
        }
    }
}