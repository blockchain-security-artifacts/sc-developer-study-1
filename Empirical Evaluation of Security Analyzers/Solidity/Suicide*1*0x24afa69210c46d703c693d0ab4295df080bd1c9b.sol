pragma solidity ^ 0.4.17;



contract Ownable {
 address public owner;


 event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


 
 function Ownable() public {
   owner = msg.sender;
 }

 
 modifier onlyOwner() {
   require(msg.sender == owner);
   _;
 }

 
 function transferOwnership(address newOwner) public onlyOwner {
   require(newOwner != address(0));
   emit OwnershipTransferred(owner, newOwner);
   owner = newOwner;
 }

}

contract mortal is Ownable{

 function mortal() public {
 }

 function kill() internal {
   selfdestruct(owner);
 }
}



contract Token {
 function transferFrom(address _from, address _to, uint256 _value) public returns(bool success);
}

contract DragonKing is mortal {

 struct Character {
   uint8 characterType;
   uint128 value;
   address owner;
 }

 
 uint32[] public ids;
 
 uint32 public nextId;
 
 uint32 public oldest;
 
 mapping(uint32 => Character) characters;
 
 mapping(uint32 => bool) teleported;
 
 uint128[] public costs;
 
 uint128[] public values;
 
 uint8 fee;
 
 uint8 constant public numDragonTypes = 6;


 
 uint16 public numCharacters;
 
 uint16 public maxCharacters;
 
 mapping(uint8 => uint16) public numCharactersXType;


 
 uint8 public eruptionThreshold;
 
 uint256 public lastEruptionTimestamp;
 
 uint8 public percentageToKill;

 
 mapping(uint32 => uint) public cooldown;
 uint256 public constant CooldownThreshold = 1 days;

 
 Token teleportToken;
 
 uint public teleportPrice;
 
 Token neverdieToken;
 
 uint public protectionPrice;
 
 mapping(uint32 => uint8) public protection;

 

 
 event NewPurchase(address player, uint8 characterType, uint8 amount, uint32 startId);
 
 event NewExit(address player, uint256 totalBalance, uint32[] removedCharacters);
 
 event NewEruption(uint32[] hitCharacters, uint128 value, uint128 gasCost);
 
 event NewSell(uint32 characterId, address player, uint256 value);
 
 event NewFight(uint32 winnerID, uint32 loserID, uint256 value);
 
 event NewTeleport(uint32 characterId);
 
 event NewProtection(uint32 characterId, uint8 lifes);

 
 function DragonKing(address teleportTokenAddress, address neverdieTokenAddress, uint8 eruptionThresholdInHours, uint8 percentageOfCharactersToKill, uint8 characterFee, uint16[] charactersCosts) public onlyOwner {
   fee = characterFee;
   for (uint8 i = 0; i < charactersCosts.length * 2; i++) {
     costs.push(uint128(charactersCosts[i % numDragonTypes]) * 1 finney);
     values.push(costs[i] - costs[i] / 100 * fee);
   }
   eruptionThreshold = eruptionThresholdInHours * 60 * 60; 
   percentageToKill = percentageOfCharactersToKill;
   maxCharacters = 600;
   nextId = 1;
   teleportToken = Token(teleportTokenAddress);
   teleportPrice = 1;
   neverdieToken = Token(neverdieTokenAddress);
   protectionPrice = 1;
 }

 
 function addCharacters(uint8 characterType) payable public {
   uint8 amount = uint8(msg.value / costs[characterType]);
   uint16 nchars = numCharacters;
   if (characterType >= costs.length || msg.value < costs[characterType] || nchars + amount > maxCharacters) revert();
   
   bool isDragon = characterType < numDragonTypes;
   uint32 nid = nextId;
   if (isDragon) {
     
     for (uint8 i = 0; i < amount; i++) {
       addCharacter(nid + i, nchars + i);
       characters[nid + i] = Character(characterType, values[characterType], msg.sender);
     }
     numCharactersXType[characterType] += amount;
     numCharacters += amount;
   }
   else {
     for (uint8 j = 0; j < amount; j++) {
       characters[nid + j] = Character(characterType, values[characterType], msg.sender);
     }
   }
   nextId = nid + amount;
   NewPurchase(msg.sender, characterType, amount, nid);
 }



 
 function addCharacter(uint32 nId, uint16 nchars) internal {
   if (nchars < ids.length)
     ids[nchars] = nId;
   else
     ids.push(nId);
 }

 
 function exit() public {
   uint32[] memory removed = new uint32[](50);
   uint8 count;
   uint32 lastId;
   uint playerBalance;
   uint16 nchars = numCharacters;
   for (uint16 i = 0; i < nchars; i++) {
     if (characters[ids[i]].owner == msg.sender) {
       
       while (nchars > 0 && characters[ids[nchars - 1]].owner == msg.sender) {
         nchars--;
         lastId = ids[nchars];
         numCharactersXType[characters[lastId].characterType]--;
         playerBalance += characters[lastId].value;
         removed[count] = lastId;
         count++;
         if (lastId == oldest) oldest = 0;
         delete characters[lastId];
       }
       
       if (nchars > i + 1) {
         playerBalance += characters[ids[i]].value;
         removed[count] = ids[i];
         count++;
         nchars--;
         replaceCharacter(i, nchars);
       }
     }
   }
   numCharacters = nchars;
   NewExit(msg.sender, playerBalance, removed); 
   msg.sender.transfer(playerBalance);
 }

 
 function replaceCharacter(uint16 index, uint16 nchars) internal {
   uint32 characterId = ids[index];
   numCharactersXType[characters[characterId].characterType]--;
   if (characterId == oldest) oldest = 0;
   delete characters[characterId];
   ids[index] = ids[nchars];
   delete ids[nchars];
 }

 

 function triggerVolcanoEruption() public {
   require(now >= lastEruptionTimestamp + eruptionThreshold);
   require(numCharacters>0);
   lastEruptionTimestamp = now;
   uint128 pot;
   uint128 value;
   uint16 random;
   uint32 nextHitId;
   uint16 nchars = numCharacters;
   uint32 howmany = nchars * percentageToKill / 100;
   uint128 neededGas = 80000 + 10000 * uint32(nchars);
   if(howmany == 0) howmany = 1;
   uint32[] memory hitCharacters = new uint32[](howmany);
   for (uint8 i = 0; i < howmany; i++) {
     random = uint16(generateRandomNumber(lastEruptionTimestamp + i) % nchars);
     nextHitId = ids[random];
     hitCharacters[i] = nextHitId;
     value = hitCharacter(random, nchars);
     if (value > 0) {
       nchars--;
     }
     pot += value;
   }
   uint128 gasCost = uint128(neededGas * tx.gasprice);
   numCharacters = nchars;
   if (pot > gasCost){
     distribute(pot - gasCost); 
     NewEruption(hitCharacters, pot - gasCost, gasCost);
   }
   else
     NewEruption(hitCharacters, 0, gasCost);
 }


 
 function fight(uint32 knightID, uint16 knightIndex) public {
   if (knightID != ids[knightIndex])
     knightID = getCharacterIndex(knightID);
   Character storage knight = characters[knightID];
   require(cooldown[knightID] + CooldownThreshold <= now);
   require(knight.owner == msg.sender);
   require(knight.characterType >= numDragonTypes);
   uint16 dragonIndex = getRandomDragon(knightID);
   assert(dragonIndex < maxCharacters);
   uint32 dragonID = ids[dragonIndex];
   Character storage dragon = characters[dragonID];
   uint16 tieBreaker = uint16(now % 2);
   uint128 value;
   if (knight.characterType - numDragonTypes > dragon.characterType || (knight.characterType - numDragonTypes == dragon.characterType && tieBreaker == 0)) {
     value = hitCharacter(dragonIndex, numCharacters);
     if (value > 0) {
       numCharacters--;
     }
     knight.value += value;
     cooldown[knightID] = now;
     if (oldest == 0) findOldest();
     NewFight(knightID, dragonID, value);
   }
   else {
     value = hitCharacter(knightIndex, numCharacters);
     if (value > 0) {
       numCharacters--;
     }
     dragon.value += value;
     NewFight(dragonID, knightID, value);
   }
 }

 
 function getRandomDragon(uint256 nonce) internal view returns(uint16) {
   uint16 randomIndex = uint16(generateRandomNumber(nonce) % numCharacters);
   
   uint16 stepSize = numCharacters % 7 == 0 ? (numCharacters % 11 == 0 ? 13 : 11) : 7;
   uint16 i = randomIndex;
   
   
   do {
     if (characters[ids[i]].characterType < numDragonTypes && characters[ids[i]].owner != msg.sender) return i;
     i = (i + stepSize) % numCharacters;
   } while (i != randomIndex);
   return maxCharacters + 1; 
 }

 
 function generateRandomNumber(uint256 nonce) internal view returns(uint) {
   return uint(keccak256(block.blockhash(block.number - 1), now, numCharacters, nonce));
 }

 
 function hitCharacter(uint16 index, uint16 nchars) internal returns(uint128 characterValue) {
   uint32 id = ids[index];
   if (protection[id] > 0) {
     protection[id]--;
     return 0;
   }
   characterValue = characters[ids[index]].value;
   nchars--;
   replaceCharacter(index, nchars);
 }

 
 function findOldest() public {
   oldest = ids[0];
   for (uint16 i = 1; i < numCharacters; i++) {
     if (ids[i] < oldest && characters[ids[i]].characterType < numDragonTypes) 
       oldest = ids[i];
   }
 }

 
 function distribute(uint128 totalAmount) internal {
   
   if (oldest == 0)
     findOldest();
   characters[oldest].value += totalAmount / 10;
   uint128 amount = totalAmount / 10 * 9;
   
   uint128 valueSum;
   uint128[] memory shares = new uint128[](values.length);
   for (uint8 v = 0; v < values.length; v++) {
     if (numCharactersXType[v] > 0) valueSum += values[v];
   }
   for (uint8 m = 0; m < values.length; m++) {
     if (numCharactersXType[m] > 0)
       shares[m] = amount * values[m] / valueSum / numCharactersXType[m];
   }
   for (uint16 i = 0; i < numCharacters; i++) {
     characters[ids[i]].value += shares[characters[ids[i]].characterType];
   }
 }

 
 function collectFees(uint128 amount) public onlyOwner {
   uint collectedFees = getFees();
   if (amount + 100 finney < collectedFees) {
     owner.transfer(amount);
   }
 }

 
 function stop() public onlyOwner {
   for (uint16 i = 0; i < numCharacters; i++) {
     if (!characters[ids[i]].owner.send(characters[ids[i]].value)) revert();
   }
   kill();
 }

 
 function sellCharacter(uint32 characterId) public {
   require(msg.sender == characters[characterId].owner);
   uint128 val = characters[characterId].value;
   numCharacters--;
   replaceCharacter(getCharacterIndex(characterId), numCharacters);
   msg.sender.transfer(val);
   NewSell(characterId, msg.sender, val);
 }

 
 function receiveApproval(address sender, uint256 value, address tokenContract, bytes callData) public {
   if (msg.sender == address(teleportToken)) {
     require(value >= teleportPrice);
     assert(teleportToken.transferFrom(sender, this, teleportPrice));
     teleportKnight(toUint32(callData));
   }
   else if (msg.sender == address(neverdieToken)) {
     uint32 id = toUint32(callData);
     
     
     require(characters[id].value == values[characters[id].characterType]);

     
     
     uint256 lifePrice = ((characters[id].characterType % numDragonTypes) + 1) * protectionPrice;
     uint256 price = 0;
     uint8 i = protection[id];
     require(i <= 3);
     for (i; i < 3 && value >= price + lifePrice * (i + 1); i++) {
       price += lifePrice * (i + 1);
     }
     assert(neverdieToken.transferFrom(sender, this, price));
     protectCharacter(id, i);
   }
   else
     revert();
 }

 
 function teleportKnight(uint32 id) internal {
   
   require(teleported[id] == false);
   teleported[id] = true;
   Character storage knight = characters[id];
   assert(knight.characterType >= numDragonTypes); 
   addCharacter(id, numCharacters);
   numCharacters++;
   numCharactersXType[knight.characterType]++;
   NewTeleport(id);
 }

 
 function protectCharacter(uint32 id, uint8 lifes) internal {
   protection[id] = lifes;
   NewProtection(id, lifes);
 }


 

 
 function getCharacter(uint32 characterId) constant public returns(uint8, uint128, address) {
   return (characters[characterId].characterType, characters[characterId].value, characters[characterId].owner);
 }

 
 function getCharacterIndex(uint32 characterId) constant public returns(uint16) {
   for (uint16 i = 0; i < ids.length; i++) {
     if (ids[i] == characterId) {
       return i;
     }
   }
   revert();
 }

 
 function get10Characters(uint16 startIndex) constant public returns(uint32[10] characterIds, uint8[10] types, uint128[10] values, address[10] owners) {
   uint32 endIndex = startIndex + 10 > numCharacters ? numCharacters : startIndex + 10;
   uint8 j = 0;
   uint32 id;
   for (uint16 i = startIndex; i < endIndex; i++) {
     id = ids[i];
     characterIds[j] = id;
     types[j] = characters[id].characterType;
     values[j] = characters[id].value;
     owners[j] = characters[id].owner;
     j++;
   }

 }

 
 function getNumDragons() constant public returns(uint16 numDragons) {
   for (uint8 i = 0; i < numDragonTypes; i++)
     numDragons += numCharactersXType[i];
 }

 
 function getNumKnights() constant public returns(uint16 numKnights) {
   for (uint8 i = numDragonTypes; i < costs.length; i++)
     numKnights += numCharactersXType[i];
 }

 
 function getFees() constant public returns(uint) {
   uint reserved = 0;
   for (uint16 j = 0; j < numCharacters; j++)
     reserved += characters[ids[j]].value;
   return address(this).balance - reserved;
 }


 

 
 function setPrices(uint16[] prices) public onlyOwner {
   for (uint8 i = 0; i < prices.length * 2; i++) {
     costs[i] = uint128(prices[i % numDragonTypes]) * 1 finney;
     values[i] = costs[i] - costs[i] / 100 * fee;
   }
 }

 
 function setFee(uint8 _fee) public onlyOwner {
   fee = _fee;
 }

 
 function setMaxCharacters(uint16 number) public onlyOwner {
   maxCharacters = number;
 }

 
 function setTeleportPrice(uint price) public onlyOwner {
   teleportPrice = price;
 }

 
 function setProtectionPrice(uint price) public onlyOwner {
   protectionPrice = price;
 }


 

 
 function toUint32(bytes b) internal pure returns(uint32) {
   bytes32 newB;
   assembly {
     newB: = mload(0x80)
   }
   return uint32(newB);
 }

}