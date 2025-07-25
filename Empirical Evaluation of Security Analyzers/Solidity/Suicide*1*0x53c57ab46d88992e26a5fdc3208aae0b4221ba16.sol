interface IMVDFunctionalitiesManager {

    function getProxy() external view returns (address);
    function setProxy() external;

    function init(address sourceLocation,
        uint256 getMinimumBlockNumberSourceLocationId, address getMinimumBlockNumberFunctionalityAddress,
        uint256 getEmergencyMinimumBlockNumberSourceLocationId, address getEmergencyMinimumBlockNumberFunctionalityAddress,
        uint256 getEmergencySurveyStakingSourceLocationId, address getEmergencySurveyStakingFunctionalityAddress,
        uint256 checkVoteResultSourceLocationId, address checkVoteResultFunctionalityAddress) external;

    function addFunctionality(string calldata codeName, address sourceLocation, uint256 sourceLocationId, address location, bool submitable, string calldata methodSignature, string calldata returnAbiParametersArray, bool isInternal, bool needsSender) external;
    function addFunctionality(string calldata codeName, address sourceLocation, uint256 sourceLocationId, address location, bool submitable, string calldata methodSignature, string calldata returnAbiParametersArray, bool isInternal, bool needsSender, uint256 position) external;
    function removeFunctionality(string calldata codeName) external returns(bool removed, uint256 position);
    function isValidFunctionality(address functionality) external view returns(bool);
    function isAuthorizedFunctionality(address functionality) external view returns(bool);
    function setCallingContext(address location) external returns(bool);
    function clearCallingContext() external;
    function getFunctionalityData(string calldata codeName) external view returns(address, uint256, string memory, address, uint256);
    function hasFunctionality(string calldata codeName) external view returns(bool);
    function getFunctionalitiesAmount() external view returns(uint256);
    function functionalitiesToJSON() external view returns(string memory);
    function functionalitiesToJSON(uint256 start, uint256 l) external view returns(string memory functionsJSONArray);
    function functionalityNames() external view returns(string memory);
    function functionalityNames(uint256 start, uint256 l) external view returns(string memory functionsJSONArray);
    function functionalityToJSON(string calldata codeName) external view returns(string memory);

    function preConditionCheck(string calldata codeName, bytes calldata data, uint8 submitable, address sender, uint256 value) external view returns(address location, bytes memory payload);

    function setupFunctionality(address proposalAddress) external returns (bool);
}







interface IDoubleProxy {
    function init(address[] calldata proxyList, address currentProxy) external;
    function proxy() external view returns(address);
    function setProxy() external;
    function isProxy(address) external view returns(bool);
    function proxiesLength() external view returns(uint256);
    function proxies(uint256 start, uint256 offset) external view returns(address[] memory);
    function proxies() external view returns(address[] memory);
}







interface IMVDProxy {

    function init(address votingTokenAddress, address functionalityProposalManagerAddress, address stateHolderAddress, address functionalityModelsManagerAddress, address functionalitiesManagerAddress, address walletAddress, address doubleProxyAddress) external;

    function getDelegates() external view returns(address[] memory);
    function getToken() external view returns(address);
    function getMVDFunctionalityProposalManagerAddress() external view returns(address);
    function getStateHolderAddress() external view returns(address);
    function getMVDFunctionalityModelsManagerAddress() external view returns(address);
    function getMVDFunctionalitiesManagerAddress() external view returns(address);
    function getMVDWalletAddress() external view returns(address);
    function getDoubleProxyAddress() external view returns(address);
    function setDelegate(uint256 position, address newAddress) external returns(address oldAddress);
    function changeProxy(address newAddress, bytes calldata initPayload) external;
    function isValidProposal(address proposal) external view returns (bool);
    function isAuthorizedFunctionality(address functionality) external view returns(bool);
    function newProposal(string calldata codeName, bool emergency, address sourceLocation, uint256 sourceLocationId, address location, bool submitable, string calldata methodSignature, string calldata returnParametersJSONArray, bool isInternal, bool needsSender, string calldata replaces) external returns(address proposalAddress);
    function startProposal(address proposalAddress) external;
    function disableProposal(address proposalAddress) external;
    function transfer(address receiver, uint256 value, address token) external;
    function transfer721(address receiver, uint256 tokenId, bytes calldata data, bool safe, address token) external;
    function flushToWallet(address tokenAddress, bool is721, uint256 tokenId) external;
    function setProposal() external;
    function read(string calldata codeName, bytes calldata data) external view returns(bytes memory returnData);
    function submit(string calldata codeName, bytes calldata data) external payable returns(bytes memory returnData);
    function callFromManager(address location, bytes calldata payload) external returns(bool, bytes memory);
    function emitFromManager(string calldata codeName, address proposal, string calldata replaced, address replacedSourceLocation, uint256 replacedSourceLocationId, address location, bool submitable, string calldata methodSignature, bool isInternal, bool needsSender, address proposalAddress) external;

    function emitEvent(string calldata eventSignature, bytes calldata firstIndex, bytes calldata secondIndex, bytes calldata data) external;

    event ProxyChanged(address indexed newAddress);
    event DelegateChanged(uint256 position, address indexed oldAddress, address indexed newAddress);

    event Proposal(address proposal);
    event ProposalCheck(address indexed proposal);
    event ProposalSet(address indexed proposal, bool success);
    event FunctionalitySet(string codeName, address indexed proposal, string replaced, address replacedSourceLocation, uint256 replacedSourceLocationId, address indexed replacedLocation, bool replacedWasSubmitable, string replacedMethodSignature, bool replacedWasInternal, bool replacedNeededSender, address indexed replacedProposal);

    event Event(string indexed key, bytes32 indexed firstIndex, bytes32 indexed secondIndex, bytes data);
}









interface IERC165 {
    
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}








interface IERC1155Receiver {

    
    function onERC1155Received(
        address operator,
        address from,
        uint256 id,
        uint256 value,
        bytes calldata data
    )
        external
        returns(bytes4);

    
    function onERC1155BatchReceived(
        address operator,
        address from,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata data
    )
        external
        returns(bytes4);
}






interface IMateriaFactory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function init(address _feeToSetter) external;

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;

    function setDefaultFees(uint, uint) external;

    function setFees(address, uint, uint) external;
    
    function transferOwnership(address newOwner) external;
    
    function owner() external view returns (address);
}







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








interface IERC1155 is IERC165 {
    
    event TransferSingle(address indexed operator, address indexed from, address indexed to, uint256 id, uint256 value);

    
    event TransferBatch(address indexed operator, address indexed from, address indexed to, uint256[] ids, uint256[] values);

    
    event ApprovalForAll(address indexed account, address indexed operator, bool approved);

    
    event URI(string value, uint256 indexed id);

    
    function balanceOf(address account, uint256 id) external view returns (uint256);

    
    function balanceOfBatch(address[] calldata accounts, uint256[] calldata ids) external view returns (uint256[] memory);

    
    function setApprovalForAll(address operator, bool approved) external;

    
    function isApprovedForAll(address account, address operator) external view returns (bool);

    
    function safeTransferFrom(address from, address to, uint256 id, uint256 amount, bytes calldata data) external;

    
    function safeBatchTransferFrom(address from, address to, uint256[] calldata ids, uint256[] calldata amounts, bytes calldata data) external;
}







interface IERC1155Views {

    
    function totalSupply(uint256 objectId) external view returns (uint256);

    
    function name(uint256 objectId) external view returns (string memory);

    
    function symbol(uint256 objectId) external view returns (string memory);

    
    function decimals(uint256 objectId) external view returns (uint256);

    
    function uri(uint256 objectId) external view returns (string memory);
}






interface IBaseTokenData {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);
}









interface IERC20Data is IBaseTokenData, IERC20 {
    function decimals() external view returns (uint256);
}









interface IEthItemInteroperableInterface is IERC20, IERC20Data {

    function init(uint256 id, string calldata name, string calldata symbol, uint256 decimals) external;

    function mainInterface() external view returns (address);

    function objectId() external view returns (uint256);

    function mint(address owner, uint256 amount) external;

    function burn(address owner, uint256 amount) external;

    function permitNonce(address sender) external view returns(uint256);

    function permit(address owner, address spender, uint value, uint8 v, bytes32 r, bytes32 s) external;

    function interoperableInterfaceVersion() external pure returns(uint256 ethItemInteroperableInterfaceVersion);
}












interface IEthItemMainInterface is IERC1155, IERC1155Views, IBaseTokenData {

    function init(
        address interfaceModel,
        string calldata name,
        string calldata symbol
    ) external;

    function mainInterfaceVersion() external pure returns(uint256 ethItemInteroperableVersion);

    function toInteroperableInterfaceAmount(uint256 objectId, uint256 ethItemAmount) external view returns (uint256 interoperableInterfaceAmount);

    function toMainInterfaceAmount(uint256 objectId, uint256 erc20WrapperAmount) external view returns (uint256 mainInterfaceAmount);

    function interoperableInterfaceModel() external view returns (address, uint256);

    function asInteroperable(uint256 objectId) external view returns (IEthItemInteroperableInterface);

    function emitTransferSingleEvent(address sender, address from, address to, uint256 objectId, uint256 amount) external;

    function mint(uint256 amount, string calldata partialUri)
        external
        returns (uint256, address);

    function burn(
        uint256 objectId,
        uint256 amount
    ) external;

    function burnBatch(
        uint256[] calldata objectIds,
        uint256[] calldata amounts
    ) external;

    event NewItem(uint256 indexed objectId, address indexed tokenAddress);
    event Mint(uint256 objectId, address tokenAddress, uint256 amount);
}










interface IEthItemModelBase is IEthItemMainInterface {

    
    function init(string calldata name, string calldata symbol) external;

    
    function modelVersion() external pure returns(uint256 modelVersionNumber);

    
    function factory() external view returns(address factoryAddress);
}









interface IERC20WrapperV1 is IEthItemModelBase {

    
    function source(uint256 objectId) external view returns (address erc20TokenAddress);

     
    function object(address erc20TokenAddress) external view returns (uint256 objectId);

    
    function mint(address erc20TokenAddress, uint256 amount) external returns (uint256 objectId, address wrapperAddress);

    function mintETH() external payable returns (uint256 objectId, address wrapperAddress);
}










interface IMateriaOperator is IERC1155Receiver, IERC165 {
 
    function orchestrator() external view returns(IMateriaOrchestrator);

    function setOrchestrator(address newOrchestrator) external;
    
    function destroy(address receiver) external;
    
}














interface IMateriaOrchestrator is IERC1155Receiver  {
    function setDoubleProxy(
        address newDoubleProxy
    ) external;
    
    function setBridgeToken(
        address newBridgeToken
    ) external;
    
    function setErc20Wrapper(
        address newErc20Wrapper
    ) external;
    
    function setFactory(
        address newFactory
    ) external;
    
    function setEthereumObjectId(
        uint newEthereumObjectId
    ) external;
    
    function setSwapper(
        address _swapper,
        bool destroyOld
    ) external;
    
    function setLiquidityAdder(
        address _adder,
        bool destroyOld
    ) external;
    
    function setLiquidityRemover(
        address _remover,
        bool destroyOld
    ) external;
    
    function retire(
        address newOrchestrator,
        bool destroyOld,
        address receiver
    ) external;
    
    function setFees(address token, uint materiaFee, uint swapFee) external;
    function setDefaultFees(uint materiaFee, uint swapFee) external;
    function getCrumbs(
        address token,
        uint amount,
        address receiver
    ) external;

    function factory() external view returns(IMateriaFactory);
    function bridgeToken() external view returns(IERC20);
    function erc20Wrapper() external view returns(IERC20WrapperV1);
    function ETHEREUM_OBJECT_ID() external view returns(uint);
    function swapper() external view returns(IMateriaOperator);
    function liquidityAdder() external view returns(IMateriaOperator);
    function liquidityRemover() external view returns(IMateriaOperator);
    function doubleProxy() external view returns(IDoubleProxy);


    
    
    
    
    
    
    function addLiquidity(
        address token,
        uint tokenAmountDesired,
        uint bridgeAmountDesired,
        uint tokenAmountMin,
        uint bridgeAmountMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);
    
    function addLiquidityETH(
        uint bridgeAmountDesired,
        uint EthAmountMin,
        uint bridgeAmountMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    
    
    
     function removeLiquidity(
        address token,
        uint liquidity,
        uint tokenAmountMin,
        uint bridgeAmountMin,
        address to,
        uint deadline
    ) external;
    
    function removeLiquidityETH(
        uint liquidity,
        uint bridgeAmountMin,
        uint EthAmountMin,
        address to,
        uint deadline
    ) external;
    
    function removeLiquidityWithPermit(
        address token,
        uint liquidity,
        uint tokenAmountMin,
        uint bridgeAmountMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external;
    
    function removeLiquidityETHWithPermit(
        uint liquidity,
        uint ethAmountMin,
        uint bridgeAmountMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external;
    
    
    
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] memory path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    
    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] memory path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    
    function swapExactETHForTokens(
        uint amountOutMin,
        address[] memory path,
        address to,
        uint deadline
    ) external payable;
   
    function swapTokensForExactETH(
        uint amountOut,
        uint amountInMax,
        address[] memory path,
        address to,
        uint deadline
    ) external;
    
    function swapExactTokensForETH(
        uint amountIn,
        uint amountOutMin,
        address[] memory path,
        address to,
        uint deadline
    ) external;
    
    function swapETHForExactTokens(
        uint amountOut,
        address[] memory path,
        address to,
        uint deadline
    ) external payable;
    
    
    
    function isEthItem(
        address token
    ) external view returns(address collection, bool ethItem, uint256 itemId);
    
    function quote(
        uint amountA,
        uint reserveA,
        uint reserveB
    ) external pure returns (uint amountB);

    function getAmountOut(
        uint amountIn,
        uint reserveIn,
        uint reserveOut
    ) external pure returns (uint amountOut);

    function getAmountIn(
        uint amountOut, 
        uint reserveIn, 
        uint reserveOut
    ) external pure returns (uint amountIn);

    function getAmountsOut(
        uint amountIn,
        address[] memory path
    ) external view returns (uint[] memory amounts);

    function getAmountsIn(
        uint amountOut,
        address[] memory path
    ) external view returns (uint[] memory amounts);
}








interface IMateriaLiquidityRemover {
    function removeLiquidity(
        address token,
        uint liquidity,
        uint tokenAmountMin,
        uint bridgeAmountMin,
        uint deadline
    ) external returns (uint amountBridge, uint amountToken);
}







library TransferHelper {
    function safeApprove(
        address token,
        address to,
        uint256 value
    ) internal {
        
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x095ea7b3, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: APPROVE_FAILED');
    }

    function safeTransfer(
        address token,
        address to,
        uint256 value
    ) internal {
        
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FAILED');
    }

    function safeTransferFrom(
        address token,
        address from,
        address to,
        uint256 value
    ) internal {
        
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FROM_FAILED');
    }

    function safeTransferETH(address to, uint256 value) internal {
        (bool success, ) = to.call{value: value}(new bytes(0));
        require(success, 'TransferHelper: ETH_TRANSFER_FAILED');
    }
}
















abstract contract MateriaOperator is IMateriaOperator {
    
    IMateriaOrchestrator public override orchestrator;
  
    constructor(address _orchestrator) {
        orchestrator = IMateriaOrchestrator(_orchestrator);
    }
  
    modifier byOrchestrator() {
        require(msg.sender == address(orchestrator), 'Materia: must be called by the orchestrator');
        _;
    }
  
    modifier ensure(uint deadline) {
        require(deadline >= block.timestamp, 'Materia: Expired');
        _;
    }
    
    function setOrchestrator(
        address newOrchestrator
    ) public override byOrchestrator() {
        orchestrator = IMateriaOrchestrator(newOrchestrator);
    }
    
    function destroy(
        address receiver
    ) byOrchestrator override external {
        selfdestruct(payable(receiver));
    }
    
    function _ensure(uint deadline) internal ensure(deadline) {}
    
    function _isEthItem(
        address token,
        address wrapper
    ) internal view returns(bool ethItem, uint id) {
        try IEthItemInteroperableInterface(token).mainInterface() {
            ethItem = true;
        } catch {
            ethItem = false;
            id = IERC20WrapperV1(wrapper).object(token);
        }
    }
    
    function _wrapErc20(
        address token,
        uint amount,
        address wrapper
    ) internal returns(address interoperable, uint newAmount) {
        if (IERC20(token).allowance(address(this), wrapper) < amount) {
            IERC20(token).approve(wrapper, type(uint).max);
        }
        
        (uint id,) = IERC20WrapperV1(wrapper).mint(token, amount);
        
        newAmount = IERC20(interoperable = address(IERC20WrapperV1(wrapper).asInteroperable(id))).balanceOf(address(this));
    }
    
    function _unwrapErc20(
        uint id,
        address tokenOut,
        uint amount,
        address wrapper,
        address to
    ) internal {
        IERC20WrapperV1(wrapper).burn(id, amount);
        TransferHelper.safeTransfer(tokenOut, to, IERC20(tokenOut).balanceOf(address(this)));
    }
    
    function _unwrapEth(
        uint id,
        uint amount,
        address wrapper,
        address to
    ) internal {
        IERC20WrapperV1(wrapper).burn(id, amount);
        TransferHelper.safeTransferETH(to, amount);
    }
    
    function _wrapEth(
        uint amount,
        address wrapper
    ) payable public returns(address interoperable) {
        (, interoperable) = IERC20WrapperV1(wrapper).mintETH{value: amount}();
    }
    
    function _adjustAmount(
        address token,
        uint amount
    ) internal view returns(uint newAmount) {
        newAmount = amount * (10 ** (18 - IERC20Data(token).decimals()));
    }
    
    function _flushBackItem(
        uint itemId,
        address receiver,
        address wrapper
    ) internal returns(uint dust) {
        if ((dust = IERC20WrapperV1(wrapper).asInteroperable(itemId).balanceOf(address(this))) > 0)
            TransferHelper.safeTransfer(address(IERC20WrapperV1(wrapper).asInteroperable(itemId)), receiver, dust);
    }
    
    function _tokenToInteroperable(
        address token,
        address wrapper
    ) internal view returns(address interoperable) {
        if (token == address(0))
            interoperable = address(IERC20WrapperV1(wrapper).asInteroperable(uint(IMateriaOrchestrator(address(this)).ETHEREUM_OBJECT_ID())));
        else {
            (, uint itemId) = _isEthItem(token, wrapper);
            interoperable = address(IERC20WrapperV1(wrapper).asInteroperable(itemId));
        }
    }
}






interface IMateriaPair {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint);

    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;

    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint);
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function price0CumulativeLast() external view returns (uint);
    function price1CumulativeLast() external view returns (uint);
    function kLast() external view returns (uint);

    function mint(address to) external returns (uint liquidity);
    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;

    function initialize(address, address) external;
}









library SafeMath {
    function add(uint x, uint y) internal pure returns (uint z) {
        require((z = x + y) >= x, 'ds-math-add-overflow');
    }

    function sub(uint x, uint y) internal pure returns (uint z) {
        require((z = x - y) <= x, 'ds-math-sub-underflow');
    }

    function mul(uint x, uint y) internal pure returns (uint z) {
        require(y == 0 || (z = x * y) / y == x, 'ds-math-mul-overflow');
    }
}












library MateriaLibrary {
    using SafeMath for uint;

    
    function sortTokens(address tokenA, address tokenB) internal pure returns (address token0, address token1) {
        require(tokenA != tokenB, 'MateriaLibrary: IDENTICAL_ADDRESSES');
        (token0, token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        require(token0 != address(0), 'MateriaLibrary: ZERO_ADDRESS');
    }

    
    function pairFor(address factory, address tokenA, address tokenB) internal pure returns (address pair) {
        (address token0, address token1) = sortTokens(tokenA, tokenB);
        pair = address(uint160(uint(keccak256(abi.encodePacked(
                hex'ff',
                factory,
                keccak256(abi.encodePacked(token0, token1)),
                hex'3a1b8c90f0ece2019085f38a482fb7538bb84471f01b56464ac88dd6bece344e' 
            )))));
    }

    
    function getReserves(address factory, address tokenA, address tokenB) internal view returns (uint reserveA, uint reserveB) {
        (address token0,) = sortTokens(tokenA, tokenB);
        (uint reserve0, uint reserve1,) = IMateriaPair(pairFor(factory, tokenA, tokenB)).getReserves();
        (reserveA, reserveB) = tokenA == token0 ? (reserve0, reserve1) : (reserve1, reserve0);
    }

    
    function quote(uint amountA, uint reserveA, uint reserveB) internal pure returns (uint amountB) {
        require(amountA > 0, 'MateriaLibrary: INSUFFICIENT_AMOUNT');
        require(reserveA > 0 && reserveB > 0, 'MateriaLibrary: INSUFFICIENT_LIQUIDITY');
        amountB = amountA.mul(reserveB) / reserveA;
    }

    
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) internal pure returns (uint amountOut) {
        require(amountIn > 0, 'MateriaLibrary: INSUFFICIENT_INPUT_AMOUNT');
        require(reserveIn > 0 && reserveOut > 0, 'MateriaLibrary: INSUFFICIENT_LIQUIDITY');
        uint amountInWithFee = amountIn.mul(997);
        uint numerator = amountInWithFee.mul(reserveOut);
        uint denominator = reserveIn.mul(1000).add(amountInWithFee);
        amountOut = numerator / denominator;
    }

    
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) internal pure returns (uint amountIn) {
        require(amountOut > 0, 'MateriaLibrary: INSUFFICIENT_OUTPUT_AMOUNT');
        require(reserveIn > 0 && reserveOut > 0, 'MateriaLibrary: INSUFFICIENT_LIQUIDITY');
        uint numerator = reserveIn.mul(amountOut).mul(1000);
        uint denominator = reserveOut.sub(amountOut).mul(997);
        amountIn = (numerator / denominator).add(1);
    }

    
    function getAmountsOut(address factory, uint amountIn, address[] memory path) internal view returns (uint[] memory amounts) {
        require(path.length >= 2, 'MateriaLibrary: INVALID_PATH');
        amounts = new uint[](path.length);
        amounts[0] = amountIn;
        for (uint i; i < path.length - 1; i++) {
            (uint reserveIn, uint reserveOut) = getReserves(factory, path[i], path[i + 1]);
            amounts[i + 1] = getAmountOut(amounts[i], reserveIn, reserveOut);
        }
    }

    
    function getAmountsIn(address factory, uint amountOut, address[] memory path) internal view returns (uint[] memory amounts) {
        require(path.length >= 2, 'MateriaLibrary: INVALID_PATH');
        amounts = new uint[](path.length);
        amounts[amounts.length - 1] = amountOut;
        for (uint i = path.length - 1; i > 0; i--) {
            (uint reserveIn, uint reserveOut) = getReserves(factory, path[i - 1], path[i]);
            amounts[i - 1] = getAmountIn(amounts[i], reserveIn, reserveOut);
        }
    }
}


















contract MateriaSwapper is MateriaOperator {

    constructor(address _orchestrator) MateriaOperator(_orchestrator) {}

    function _swap(address factory, uint[] memory amounts, address[] memory path, address _to) internal virtual {
        for (uint i; i < path.length - 1; i++) {
            (address input, address output) = (path[i], path[i + 1]);
            (address token0,) = MateriaLibrary.sortTokens(input, output);
            uint amountOut = amounts[i + 1];
            (uint amount0Out, uint amount1Out) = input == token0 ? (uint(0), amountOut) : (amountOut, uint(0));
            address to = i < path.length - 2 ? MateriaLibrary.pairFor(factory, output, path[i + 2]) : _to;
            IMateriaPair(MateriaLibrary.pairFor(factory, input, output)).swap(
                amount0Out, amount1Out, to, new bytes(0)
            );
        }
    }
    
 
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] memory path,
        address to,
        uint deadline
    ) public ensure(deadline) returns (uint[] memory amounts) {
        
        address factory = address(IMateriaOrchestrator(address(this)).factory());
        address bridgeToken = address(IMateriaOrchestrator(address(this)).bridgeToken());
        address erc20Wrapper = address(IMateriaOrchestrator(address(this)).erc20Wrapper());

        TransferHelper.safeTransferFrom(path[0], msg.sender, address(this), amountIn);
        
        (path[0], amountIn) = _wrapErc20(path[0], amountIn, erc20Wrapper);
        
        bool ethItemOut;
        uint itemId;
        address tokenOut;
        
        (ethItemOut, itemId) = _isEthItem(path[path.length - 1], erc20Wrapper);
        
        if (!ethItemOut && bridgeToken != path[path.length - 1]) {
            tokenOut = path[path.length - 1];
            amountOutMin = _adjustAmount(tokenOut, amountOutMin);
            path[path.length - 1] = address(IERC20WrapperV1(erc20Wrapper).asInteroperable(itemId));
        }
        
        amounts = MateriaLibrary.getAmountsOut(factory, amountIn, path);
        require(amounts[amounts.length - 1] >= amountOutMin, 'INSUFFICIENT_OUTPUT_AMOUNT');
        
        TransferHelper.safeTransfer(
            path[0], MateriaLibrary.pairFor(factory, path[0], path[1]), amounts[0]
        );
        
        if (ethItemOut) {
            _swap(factory, amounts, path, to);
        } else {
            _swap(factory, amounts, path, address(this));
            _unwrapErc20(itemId, tokenOut, amounts[amounts.length - 1], erc20Wrapper, to);
        }
    }

    event Debug(uint amount);

    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] memory path,
        address to,
        uint deadline
    ) public ensure(deadline) returns (uint[] memory amounts) {
        
        address factory = address(IMateriaOrchestrator(address(this)).factory());
        address erc20Wrapper = address(IMateriaOrchestrator(address(this)).erc20Wrapper());
        
        address tokenIn = path[0];
        path[0] = address(IERC20WrapperV1(erc20Wrapper).asInteroperable(IERC20WrapperV1(erc20Wrapper).object(path[0])));
        
        bool ethItemOut;
        uint itemId;
        (ethItemOut, itemId) = _isEthItem(path[path.length - 1], erc20Wrapper);
        address tokenOut;
        
        if (!ethItemOut && address(IMateriaOrchestrator(address(this)).bridgeToken()) != path[path.length - 1]) {
            tokenOut = path[path.length - 1];
            amountOut =  _adjustAmount(tokenOut, amountOut);
            path[path.length - 1] = address(IERC20WrapperV1(erc20Wrapper).asInteroperable(itemId));
        }

        amounts = MateriaLibrary.getAmountsIn(factory, amountOut, path);
        amounts[0] = amounts[0] / (10**(18 - IERC20Data(tokenIn).decimals())) + 1;

        require(amounts[0] <= amountInMax, 'EXCESSIVE_INPUT_AMOUNT');
        
        TransferHelper.safeTransferFrom(tokenIn, msg.sender, address(this), amounts[0]);
        
        (, amounts[0]) = _wrapErc20(tokenIn, amounts[0], erc20Wrapper);
        
        TransferHelper.safeTransfer(
            path[0], MateriaLibrary.pairFor(factory, path[0], path[1]), amounts[0]
        );
        
        if (ethItemOut) {
            _swap(factory, amounts, path, to);
        } else {
            _swap(factory, amounts, path, address(this));
            _unwrapErc20(itemId, tokenOut, amounts[amounts.length - 1], erc20Wrapper, to);
        }
        
        
    }
    
     function swapExactETHForTokens(
        uint amountOutMin,
        address[] memory path,
        address to,
        uint deadline
    ) public ensure(deadline) payable returns (uint[] memory amounts) {
        address factory = address(IMateriaOrchestrator(address(this)).factory());
        address bridgeToken = address(IMateriaOrchestrator(address(this)).bridgeToken());
        address erc20Wrapper = address(IMateriaOrchestrator(address(this)).erc20Wrapper());

        path[0] = _wrapEth(msg.value, erc20Wrapper);
        
        bool ethItemOut;
        uint itemId;
        address tokenOut;
        
        (ethItemOut, itemId) = _isEthItem(path[path.length - 1], erc20Wrapper);
        
        if (!ethItemOut && bridgeToken != path[path.length - 1]) {
            tokenOut = path[path.length - 1];
            amountOutMin = _adjustAmount(tokenOut, amountOutMin);
            path[path.length - 1] = address(IERC20WrapperV1(erc20Wrapper).asInteroperable(itemId));
        }
        
        amounts = MateriaLibrary.getAmountsOut(factory, msg.value, path);
        require(amounts[amounts.length - 1] >= amountOutMin, 'INSUFFICIENT_OUTPUT_AMOUNT');
        
        TransferHelper.safeTransfer(
            path[0], MateriaLibrary.pairFor(factory, path[0], path[1]), amounts[0]
        );
        
        if (ethItemOut) {
            _swap(factory, amounts, path, to);
        } else {
            _swap(factory, amounts, path, address(this));
            _unwrapErc20(itemId, tokenOut, amounts[amounts.length - 1], erc20Wrapper, to);
        }
    }
   
    function swapTokensForExactETH(
        uint amountOut,
        uint amountInMax,
        address[] memory path,
        address to,
        uint deadline
    ) public ensure(deadline) returns (uint[] memory amounts) {
        address factory = address(IMateriaOrchestrator(address(this)).factory());
        address erc20Wrapper = address(IMateriaOrchestrator(address(this)).erc20Wrapper());
        uint ethId = uint(IMateriaOrchestrator(address(this)).ETHEREUM_OBJECT_ID());
        
        address token = path[0];
        path[0] = address(IERC20WrapperV1(erc20Wrapper).asInteroperable(IERC20WrapperV1(erc20Wrapper).object(path[0])));
        amountOut = amountOut * (10 ** (18 - IERC20Data(path[path.length - 1]).decimals()));

        amountInMax = _adjustAmount(token, amountInMax);
        amounts = MateriaLibrary.getAmountsIn(factory, amountOut, path);
        require(amounts[0] <= amountInMax, 'INSUFFICIENT_INPUT_AMOUNT');

        TransferHelper.safeTransferFrom(token, msg.sender, address(this), amounts[0]);
        
        (path[0], amounts[0]) = _wrapErc20(token, amounts[0], erc20Wrapper);
        
        TransferHelper.safeTransfer(
            path[0], MateriaLibrary.pairFor(factory, path[0], path[1]), amounts[0]
        );
        
        _swap(factory, amounts, path, address(this));
        _unwrapEth(ethId, amounts[amounts.length - 1], erc20Wrapper, to);
    }
    
    function swapExactTokensForETH(
        uint amountIn,
        uint amountOutMin,
        address[] memory path,
        address to,
        uint deadline
    ) public ensure(deadline) returns (uint[] memory amounts) {
        address factory = address(IMateriaOrchestrator(address(this)).factory());
        address erc20Wrapper = address(IMateriaOrchestrator(address(this)).erc20Wrapper());
        uint ethId = uint(IMateriaOrchestrator(address(this)).ETHEREUM_OBJECT_ID());

        TransferHelper.safeTransferFrom(path[0], msg.sender, address(this), amountIn);
        
        (path[0], amountIn) = _wrapErc20(path[0], amountIn, erc20Wrapper);
        
        amounts = MateriaLibrary.getAmountsOut(factory, amountIn, path);
        require(amounts[amounts.length - 1] >= amountOutMin, 'INSUFFICIENT_OUTPUT_AMOUNT');
        
        TransferHelper.safeTransfer(
            path[0], MateriaLibrary.pairFor(factory, path[0], path[1]), amounts[0]
        );
        
        _swap(factory, amounts, path, address(this));
        _unwrapEth(ethId, amounts[amounts.length - 1], erc20Wrapper, to);

    }
    
    function swapETHForExactTokens(
        uint amountOut,
        address[] memory path,
        address to,
        uint deadline
    ) public payable ensure(deadline) returns (uint[] memory amounts) {
        address factory = address(IMateriaOrchestrator(address(this)).factory());
        address erc20Wrapper = address(IMateriaOrchestrator(address(this)).erc20Wrapper());
        address bridgeToken = address(IMateriaOrchestrator(address(this)).bridgeToken());
        
        bool ethItemOut;
        uint itemId;
        address tokenOut;
        
        (ethItemOut, itemId) = _isEthItem(path[path.length - 1], erc20Wrapper);
        
        if (!ethItemOut && bridgeToken != path[path.length - 1]) {
            tokenOut = path[path.length - 1];
            amountOut = _adjustAmount(tokenOut, amountOut);
            path[path.length - 1] = address(IERC20WrapperV1(erc20Wrapper).asInteroperable(itemId));
        }
        
        amounts = MateriaLibrary.getAmountsIn(factory, amountOut, path);
        require(amounts[0] <= msg.value, 'INSUFFICIENT_INPUT_AMOUNT');
        
        path[0] = _wrapEth(amounts[0], erc20Wrapper);
        
        TransferHelper.safeTransfer(
            path[0], MateriaLibrary.pairFor(factory, path[0], path[1]), amounts[0]
        );
        
        if (ethItemOut) {
            _swap(factory, amounts, path, to);
        } else {
            _swap(factory, amounts, path, address(this));
            _unwrapErc20(itemId, tokenOut, amounts[amounts.length - 1], erc20Wrapper, to);
        }
        
        if (msg.value > amounts[0])
            TransferHelper.safeTransferETH(msg.sender, msg.value - amounts[0]);
    }
    
    function swapExactItemsForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] memory path,
        address to,
        uint deadline
    ) private ensure(deadline) {
        address factory = address(IMateriaOrchestrator(address(this)).factory());
        address erc20Wrapper = address(IMateriaOrchestrator(address(this)).erc20Wrapper());

        bool ethItemOut;
        uint itemId;
        address tokenOut;
        
        (ethItemOut, itemId) = _isEthItem(path[path.length - 1], erc20Wrapper);
        
        if (!ethItemOut && address(IMateriaOrchestrator(address(this)).bridgeToken()) != path[path.length - 1]) {
            tokenOut = path[path.length - 1];
            amountOutMin = _adjustAmount(tokenOut, amountOutMin);
            path[path.length - 1] = address(IERC20WrapperV1(erc20Wrapper).asInteroperable(itemId));
        }
        
        uint[] memory amounts = MateriaLibrary.getAmountsOut(factory, amountIn, path);
        require(amounts[amounts.length - 1] >= amountOutMin, 'INSUFFICIENT_OUTPUT_AMOUNT');
        
        TransferHelper.safeTransfer(
            path[0], MateriaLibrary.pairFor(factory, path[0], path[1]), amounts[0]
        );
        
        if (ethItemOut) {
            _swap(factory, amounts, path, to);
        } else {
            _swap(factory, amounts, path, address(this));
            _unwrapErc20(itemId, tokenOut, amounts[amounts.length - 1], erc20Wrapper, to);
        }
    }
    
    function swapItemsForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] memory path,
        address to,
        address from,
        uint deadline
    ) private ensure(deadline) {
        address factory = address(IMateriaOrchestrator(address(this)).factory());
        address erc20Wrapper = address(IMateriaOrchestrator(address(this)).erc20Wrapper());

        bool ethItemOut;
        uint itemId;
        address tokenOut;
        
        (ethItemOut, itemId) = _isEthItem(path[path.length - 1], erc20Wrapper);
        
        if (!ethItemOut && address(IMateriaOrchestrator(address(this)).bridgeToken()) != path[path.length - 1]) {
            tokenOut = path[path.length - 1];
            amountOut = _adjustAmount(tokenOut, amountOut);
            path[path.length - 1] = address(IERC20WrapperV1(erc20Wrapper).asInteroperable(itemId));
        }
        
        uint[] memory amounts = MateriaLibrary.getAmountsIn(factory, amountOut, path);
        require(amounts[0] <= amountInMax, 'INSUFFICIENT_INPUT_AMOUNT');
        
        {
        uint amountBack;
        if ((amountBack = amountInMax - amounts[0]) > 0)
            TransferHelper.safeTransfer(path[0], from, amountBack);
        }
        
        TransferHelper.safeTransfer(
            path[0], MateriaLibrary.pairFor(factory, path[0], path[1]), amounts[0]
        );
        
        if (ethItemOut) {
            _swap(factory, amounts, path, to);
        } else {
            _swap(factory, amounts, path, address(this));
            _unwrapErc20(itemId, tokenOut, amounts[amounts.length - 1], erc20Wrapper, to);
        }
    }
    
    function swapExactItemsForEth(
        uint amountIn,
        uint amountOutMin,
        address[] memory path,
        address to,
        uint deadline
    ) private ensure(deadline) {
        address factory = address(IMateriaOrchestrator(address(this)).factory());
        address erc20Wrapper = address(IMateriaOrchestrator(address(this)).erc20Wrapper());
        uint ethId = uint(IMateriaOrchestrator(address(this)).ETHEREUM_OBJECT_ID());

        uint[] memory amounts = MateriaLibrary.getAmountsOut(factory, amountIn, path);
        require(amounts[amounts.length - 1] >= amountOutMin, 'INSUFFICIENT_OUTPUT_AMOUNT');
        
        TransferHelper.safeTransfer(
            path[0], MateriaLibrary.pairFor(factory, path[0], path[1]), amounts[0]
        );
        
        _swap(factory, amounts, path, address(this));
        
        IERC20WrapperV1(erc20Wrapper).burn(
            ethId,
            amounts[amounts.length - 1]
        );
        
        TransferHelper.safeTransferETH(to, amounts[amounts.length - 1]);
    }
    
    function swapItemsForExactEth(
        uint amountOut,
        uint amountInMax,
        address[] memory path,
        address to,
        address from,
        uint deadline
    ) private ensure(deadline) {
        address factory = address(IMateriaOrchestrator(address(this)).factory());
        address erc20Wrapper = address(IMateriaOrchestrator(address(this)).erc20Wrapper());
        uint ethId = uint(IMateriaOrchestrator(address(this)).ETHEREUM_OBJECT_ID());

        uint[] memory amounts = MateriaLibrary.getAmountsIn(factory, amountOut, path);
        require(amounts[0] <= amountInMax, 'INSUFFICIENT_INPUT_AMOUNT');
        
        {
        uint amountBack;
        if ((amountBack = amountInMax - amounts[0]) > 0)
            TransferHelper.safeTransfer(path[0], from, amountBack);
        }
        
        TransferHelper.safeTransfer(
            path[0], MateriaLibrary.pairFor(factory, path[0], path[1]), amounts[0]
        );
        
        _swap(factory, amounts, path, address(this));
        
        IERC20WrapperV1(erc20Wrapper).burn(
            ethId,
            amounts[amounts.length - 1]
        );
        
        TransferHelper.safeTransferETH(to, amounts[amounts.length - 1]);
    }

    function onERC1155Received(
        address,
        address from,
        uint,
        uint value,
        bytes calldata data
    ) public override returns(bytes4) {
        uint operation;
        uint amount;
        address[] memory path;
        address to;
        uint deadline;
        
        { 
            bytes memory payload;
            (operation, payload) = abi.decode(data, (uint, bytes));
            (amount, path, to, deadline) = abi.decode(payload, (uint, address[], address, uint));
        }
        
        if (operation == 2) swapExactItemsForTokens(value, amount, path, to, deadline);
        else if (operation == 3) swapItemsForExactTokens(amount, value, path, to, from, deadline);
        else if (operation == 4) swapExactItemsForEth(value, amount, path, to, deadline);
        else if (operation == 5) swapItemsForExactEth(amount, value, path, to, from, deadline);
        else revert();
        
        return this.onERC1155Received.selector;
    }

    function onERC1155BatchReceived(
        address,
        address,
        uint256[] calldata,
        uint256[] calldata,
        bytes calldata
    ) public override pure returns(bytes4) {
        revert();
        
    }
    
    function supportsInterface(
        bytes4
    ) public override pure returns (bool) {
        return false;
    }

}








library Math {
    function min(uint x, uint y) internal pure returns (uint z) {
        z = x < y ? x : y;
    }

    
    function sqrt(uint y) internal pure returns (uint z) {
        if (y > 3) {
            z = y;
            uint x = y / 2 + 1;
            while (x < z) {
                z = x;
                x = (y / x + x) / 2;
            }
        } else if (y != 0) {
            z = 1;
        }
    }
}














library MateriaLiquidityMathLibrary {
    using SafeMath for uint256;

    
    function computeProfitMaximizingTrade(
        uint256 truePriceTokenA,
        uint256 truePriceTokenB,
        uint256 reserveA,
        uint256 reserveB
    ) pure internal returns (bool aToB, uint256 amountIn) {
        aToB = SafeMath.mul(reserveA, truePriceTokenB)/reserveB < truePriceTokenA;

        uint256 invariant = reserveA.mul(reserveB);

        uint256 leftSide = Math.sqrt(
            SafeMath.mul(
                invariant.mul(1000),
                aToB ? truePriceTokenA : truePriceTokenB)/
                (aToB ? truePriceTokenB : truePriceTokenA).mul(997)
            
        );
        uint256 rightSide = (aToB ? reserveA.mul(1000) : reserveB.mul(1000)) / 997;

        if (leftSide < rightSide) return (false, 0);

        
        amountIn = leftSide.sub(rightSide);
    }

    
    function getReservesAfterArbitrage(
        address factory,
        address tokenA,
        address tokenB,
        uint256 truePriceTokenA,
        uint256 truePriceTokenB
    ) view internal returns (uint256 reserveA, uint256 reserveB) {
        
        (reserveA, reserveB) = MateriaLibrary.getReserves(factory, tokenA, tokenB);

        require(reserveA > 0 && reserveB > 0, 'MateriaArbitrageLibrary: ZERO_PAIR_RESERVES');

        
        (bool aToB, uint256 amountIn) = computeProfitMaximizingTrade(truePriceTokenA, truePriceTokenB, reserveA, reserveB);

        if (amountIn == 0) {
            return (reserveA, reserveB);
        }

        
        if (aToB) {
            uint amountOut = MateriaLibrary.getAmountOut(amountIn, reserveA, reserveB);
            reserveA += amountIn;
            reserveB -= amountOut;
        } else {
            uint amountOut = MateriaLibrary.getAmountOut(amountIn, reserveB, reserveA);
            reserveB += amountIn;
            reserveA -= amountOut;
        }
    }

    
    function computeLiquidityValue(
        uint256 reservesA,
        uint256 reservesB,
        uint256 totalSupply,
        uint256 liquidityAmount,
        bool feeOn,
        uint kLast
    ) internal pure returns (uint256 tokenAAmount, uint256 tokenBAmount) {
        if (feeOn && kLast > 0) {
            uint rootK = Math.sqrt(reservesA.mul(reservesB));
            uint rootKLast = Math.sqrt(kLast);
            if (rootK > rootKLast) {
                uint numerator1 = totalSupply;
                uint numerator2 = rootK.sub(rootKLast);
                uint denominator = rootK.mul(5).add(rootKLast);
                uint feeLiquidity = SafeMath.mul(numerator1, numerator2)/ denominator;
                totalSupply = totalSupply.add(feeLiquidity);
            }
        }
        return (reservesA.mul(liquidityAmount) / totalSupply, reservesB.mul(liquidityAmount) / totalSupply);
    }

    
    
    
    function getLiquidityValue(
        address factory,
        address tokenA,
        address tokenB,
        uint256 liquidityAmount
    ) internal view returns (uint256 tokenAAmount, uint256 tokenBAmount) {
        (uint256 reservesA, uint256 reservesB) = MateriaLibrary.getReserves(factory, tokenA, tokenB);
        IMateriaPair pair = IMateriaPair(MateriaLibrary.pairFor(factory, tokenA, tokenB));
        bool feeOn = IMateriaFactory(factory).feeTo() != address(0);
        uint kLast = feeOn ? pair.kLast() : 0;
        uint totalSupply = pair.totalSupply();
        return computeLiquidityValue(reservesA, reservesB, totalSupply, liquidityAmount, feeOn, kLast);
    }

    
    
    function getLiquidityValueAfterArbitrageToPrice(
        address factory,
        address tokenA,
        address tokenB,
        uint256 truePriceTokenA,
        uint256 truePriceTokenB,
        uint256 liquidityAmount
    ) internal view returns (
        uint256 tokenAAmount,
        uint256 tokenBAmount
    ) {
        bool feeOn = IMateriaFactory(factory).feeTo() != address(0);
        IMateriaPair pair = IMateriaPair(MateriaLibrary.pairFor(factory, tokenA, tokenB));
        uint kLast = feeOn ? pair.kLast() : 0;
        uint totalSupply = pair.totalSupply();

        
        require(totalSupply >= liquidityAmount && liquidityAmount > 0, 'ComputeLiquidityValue: LIQUIDITY_AMOUNT');

        (uint reservesA, uint reservesB) = getReservesAfterArbitrage(factory, tokenA, tokenB, truePriceTokenA, truePriceTokenB);

        return computeLiquidityValue(reservesA, reservesB, totalSupply, liquidityAmount, feeOn, kLast);
    }
}





pragma solidity 0.8.0;




















abstract contract Proxy {
    function _delegate(address implementation) internal virtual {
        assembly {
            calldatacopy(0, 0, calldatasize())
            let result := delegatecall(gas(), implementation, 0, calldatasize(), 0, 0)
            returndatacopy(0, 0, returndatasize())
            switch result
            case 0 { revert(0, returndatasize()) }
            default { return(0, returndatasize()) }
        }
    }
}

contract MateriaOrchestrator is Proxy, IMateriaOrchestrator {
    
    IDoubleProxy public override doubleProxy;
    
    IMateriaOperator public override swapper;
    IMateriaOperator public override liquidityAdder;
    IMateriaOperator public override liquidityRemover;
    
    IMateriaFactory public override factory;
    IERC20WrapperV1 public override erc20Wrapper;
    IERC20 public override bridgeToken;
    uint public override ETHEREUM_OBJECT_ID;
    
    constructor(
        address initialFactory,
        address initialBridgeToken,
        address initialErc20Wrapper,
        address initialDoubleProxy
    ) {
        factory = IMateriaFactory(initialFactory);
        bridgeToken = IERC20(initialBridgeToken);
        erc20Wrapper = IERC20WrapperV1(initialErc20Wrapper);
        ETHEREUM_OBJECT_ID = uint(keccak256(bytes("THE ETHEREUM OBJECT IT")));
        doubleProxy = IDoubleProxy(initialDoubleProxy);
    }
    
    function setDoubleProxy(
        address newDoubleProxy
    ) onlyDFO external override {
        doubleProxy = IDoubleProxy(newDoubleProxy);
    }
    
    function setBridgeToken(
        address newBridgeToken
    ) onlyDFO external override {
        bridgeToken = IERC20(newBridgeToken);
    }
    
    function setErc20Wrapper(
        address newErc20Wrapper
    ) onlyDFO external override {
        erc20Wrapper = IERC20WrapperV1(newErc20Wrapper);
    }
    
    function setFactory(
        address newFactory
    ) onlyDFO external override {
        factory = IMateriaFactory(newFactory);
    }
    
    function setEthereumObjectId(
        uint newEthereumObjectId
    ) onlyDFO external override {
        ETHEREUM_OBJECT_ID = newEthereumObjectId;
    }
    
    function setSwapper(
        address _swapper,
        bool destroyOld
    ) external override {
        if (destroyOld)
            IMateriaOperator(swapper).destroy(msg.sender);
        swapper = IMateriaOperator(_swapper);
    }
    
    function setLiquidityAdder(
        address _adder,
        bool destroyOld
    ) external override {
        if (destroyOld)
            IMateriaOperator(liquidityAdder).destroy(msg.sender);
        liquidityAdder = IMateriaOperator(_adder);
    }
    
    function setLiquidityRemover(
        address _remover,
        bool destroyOld
    ) external override {
        if (destroyOld)
            IMateriaOperator(liquidityRemover).destroy(msg.sender);
        liquidityRemover = IMateriaOperator(_remover);
    }
    
    function retire(
        address newOrchestrator,
        bool destroyOld,
        address receiver
    ) onlyDFO external override {
        liquidityAdder.setOrchestrator(newOrchestrator);
        liquidityRemover.setOrchestrator(newOrchestrator);
        swapper.setOrchestrator(newOrchestrator);
        factory.transferOwnership(newOrchestrator);
        if (destroyOld) selfdestruct(payable(receiver));
    }
    
    function setFees(
        address token,
        uint materiaFee,
        uint swapFee
    ) onlyDFO external override {
        factory.setFees(
            MateriaLibrary.pairFor(address(factory), address(bridgeToken), token),
            materiaFee,
            swapFee
        );
    }
    
    function setDefaultFees(
        uint materiaFee,
        uint swapFee
    ) onlyDFO external override {
        factory.setDefaultFees(
            materiaFee,
            swapFee
        );
    }
    
    
    function getCrumbs(
        address token,
        uint amount,
        address receiver
    ) onlyDFO external override {
        TransferHelper.safeTransfer(token, receiver, amount);
    }
    
     modifier onlyDFO() {
        require(IMVDFunctionalitiesManager(IMVDProxy(doubleProxy.proxy()).getMVDFunctionalitiesManagerAddress()).isAuthorizedFunctionality(msg.sender), "Unauthorized");
        _;
    }
    
    receive() external payable {
        require(msg.sender == address(erc20Wrapper),'Only EthItem can send ETH to this contract');
    }

    

    function onERC1155Received(
        address,
        address,
        uint256,
        uint256,
        bytes calldata payload
    ) external override returns(bytes4) {
        (uint operation,) = abi.decode(payload, (uint, bytes));
        if (operation == 1) { 
            _delegate(address(liquidityAdder));
        } else if (operation == 2 || operation == 3 || operation == 4 || operation == 5) {
            _delegate(address(swapper)); 
        } else {
            revert();   
        }
        
        return this.onERC1155Received.selector;
    }

    function onERC1155BatchReceived(
        address,
        address,
        uint256[] calldata,
        uint256[] calldata,
        bytes calldata
    ) external pure override returns(bytes4) {
        revert();
        
    }
    
    
    
    function addLiquidity(
        address token,
        uint tokenAmountDesired,
        uint bridgeAmountDesired,
        uint tokenAmountMin,
        uint bridgeAmountMin,
        address to,
        uint deadline
    ) external override returns (uint amountA, uint amountB, uint liquidity) {
        _delegate(address(liquidityAdder));
    }
    
    function addLiquidityETH(
        uint bridgeAmountDesired,
        uint EthAmountMin,
        uint bridgeAmountMin,
        address to,
        uint deadline
    ) external override payable returns (uint amountToken, uint amountETH, uint liquidity)  {
        _delegate(address(liquidityAdder));
    }
    
    
    
    function removeLiquidity(
        address token,
        uint liquidity,
        uint tokenAmountMin,
        uint bridgeAmountMin,
        address to,
        uint deadline
    ) public override {
        _delegate(address(liquidityRemover));
    }
    
    function removeLiquidityETH(
        uint liquidity,
        uint bridgeAmountMin,
        uint EthAmountMin,
        address to,
        uint deadline
    ) public override {
        _delegate(address(liquidityRemover));
    }
    
    function removeLiquidityWithPermit(
        address token,
        uint liquidity,
        uint tokenAmountMin,
        uint bridgeAmountMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) public override {
        _delegate(address(liquidityRemover));
    }
    
    function removeLiquidityETHWithPermit(
        uint liquidity,
        uint tokenAmountMin,
        uint bridgeAmountMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) public override {
        _delegate(address(liquidityRemover));
    }
    
    
    
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] memory path,
        address to,
        uint deadline
    ) public override returns (uint[] memory amounts) {
        _delegate(address(swapper));
    }
    
    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] memory path,
        address to,
        uint deadline
    ) public override returns (uint[] memory amounts) {
        _delegate(address(swapper));
    }
    
     function swapExactETHForTokens(
        uint amountOutMin,
        address[] memory path,
        address to,
        uint deadline
    ) public override payable {
        _delegate(address(swapper));
    }
   
    function swapTokensForExactETH(
        uint amountOut,
        uint amountInMax,
        address[] memory path,
        address to,
        uint deadline
    ) public override {
        _delegate(address(swapper));
    }
    
    function swapExactTokensForETH(
        uint amountIn,
        uint amountOutMin,
        address[] memory path,
        address to,
        uint deadline
    ) public override {
        _delegate(address(swapper));
    }
    
    function swapETHForExactTokens(
        uint amountOut,
        address[] memory path,
        address to,
        uint deadline
    ) public override payable {
        _delegate(address(swapper));
    }
    
    
    
    function quote(
        uint amountA,
        uint reserveA,
        uint reserveB
    ) public pure override returns (uint amountB) {
        return MateriaLibrary.quote(amountA, reserveA, reserveB);
    }

    function getAmountOut(
        uint amountIn,
        uint reserveIn,
        uint reserveOut
    ) public pure override returns (uint amountOut) {
        return MateriaLibrary.getAmountOut(amountIn, reserveIn, reserveOut);
    }

    function getAmountIn(
        uint amountOut, 
        uint reserveIn, 
        uint reserveOut
    ) public pure override returns (uint amountIn) {
        return MateriaLibrary.getAmountIn(amountOut, reserveIn, reserveOut);
    }

    function getAmountsOut(
        uint amountIn,
        address[] memory path
    ) public view override returns (uint[] memory amounts) {
        return MateriaLibrary.getAmountsOut(address(factory), amountIn, path);
    }

    function getAmountsIn(
        uint amountOut,
        address[] memory path
    ) public view override returns (uint[] memory amounts) {
        return MateriaLibrary.getAmountsIn(address(factory), amountOut, path);
    }
    
    
    
    function isEthItem(
        address token
    ) public view override returns(address collection, bool ethItem, uint256 itemId) {
        if (token == address(0)) {
            return(address(0), false, 0);
        } else {
           try IEthItemInteroperableInterface(token).mainInterface() returns(address mainInterface) {
                return(mainInterface, true, IEthItemInteroperableInterface(token).objectId());
           } catch {
                return(address(0), false, 0);
           }
        }
    }
}