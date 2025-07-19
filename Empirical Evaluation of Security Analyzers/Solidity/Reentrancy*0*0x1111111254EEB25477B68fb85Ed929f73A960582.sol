pragma solidity 0.8.17;


interface IClipperExchangeInterface {
    struct Signature {
        uint8 v;
        bytes32 r;
        bytes32 s;
    }

    function sellEthForToken(address outputToken, uint256 inputAmount, uint256 outputAmount, uint256 goodUntil, address destinationAddress, Signature calldata theSignature, bytes calldata auxiliaryData) external payable;
    function sellTokenForEth(address inputToken, uint256 inputAmount, uint256 outputAmount, uint256 goodUntil, address destinationAddress, Signature calldata theSignature, bytes calldata auxiliaryData) external;
    function swap(address inputToken, address outputToken, uint256 inputAmount, uint256 outputAmount, uint256 goodUntil, address destinationAddress, Signature calldata theSignature, bytes calldata auxiliaryData) external;
}





pragma solidity 0.8.17;

library RouterErrors {
    error ReturnAmountIsNotEnough();
    error InvalidMsgValue();
    error ERC20TransferFailed();
}





pragma solidity ^0.8.0;

abstract contract EthReceiver {
    error EthDepositRejected();

    receive() external payable {
        _receive();
    }

    function _receive() internal virtual {
        
        if (msg.sender == tx.origin) revert EthDepositRejected();
    }
}






pragma solidity ^0.8.0;


interface IERC20 {
    
    event Transfer(address indexed from, address indexed to, uint256 value);

    
    event Approval(address indexed owner, address indexed spender, uint256 value);

    
    function totalSupply() external view returns (uint256);

    
    function balanceOf(address account) external view returns (uint256);

    
    function transfer(address to, uint256 amount) external returns (bool);

    
    function allowance(address owner, address spender) external view returns (uint256);

    
    function approve(address spender, uint256 amount) external returns (bool);

    
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}





pragma solidity ^0.8.0;


interface IDaiLikePermit {
    function permit(address holder, address spender, uint256 nonce, uint256 expiry, bool allowed, uint8 v, bytes32 r, bytes32 s) external;
}





pragma solidity ^0.8.0;

library RevertReasonForwarder {
    function reRevert() internal pure {
        
        
        assembly { 
            let ptr := mload(0x40)
            returndatacopy(ptr, 0, returndatasize())
            revert(ptr, returndatasize())
        }
    }
}






pragma solidity ^0.8.0;


interface IERC20Permit {
    
    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    
    function nonces(address owner) external view returns (uint256);

    
    
    function DOMAIN_SEPARATOR() external view returns (bytes32);
}





pragma solidity ^0.8.0;




library SafeERC20 {
    error SafeTransferFailed();
    error SafeTransferFromFailed();
    error ForceApproveFailed();
    error SafeIncreaseAllowanceFailed();
    error SafeDecreaseAllowanceFailed();
    error SafePermitBadLength();

    
    function safeTransferFrom(IERC20 token, address from, address to, uint256 amount) internal {
        bytes4 selector = token.transferFrom.selector;
        bool success;
        
        assembly { 
            let data := mload(0x40)

            mstore(data, selector)
            mstore(add(data, 0x04), from)
            mstore(add(data, 0x24), to)
            mstore(add(data, 0x44), amount)
            success := call(gas(), token, 0, data, 100, 0x0, 0x20)
            if success {
                switch returndatasize()
                case 0 { success := gt(extcodesize(token), 0) }
                default { success := and(gt(returndatasize(), 31), eq(mload(0), 1)) }
            }
        }
        if (!success) revert SafeTransferFromFailed();
    }

    
    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        if (!_makeCall(token, token.transfer.selector, to, value)) {
            revert SafeTransferFailed();
        }
    }

    
    function forceApprove(IERC20 token, address spender, uint256 value) internal {
        if (!_makeCall(token, token.approve.selector, spender, value)) {
            if (!_makeCall(token, token.approve.selector, spender, 0) ||
                !_makeCall(token, token.approve.selector, spender, value))
            {
                revert ForceApproveFailed();
            }
        }
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 allowance = token.allowance(address(this), spender);
        if (value > type(uint256).max - allowance) revert SafeIncreaseAllowanceFailed();
        forceApprove(token, spender, allowance + value);
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 allowance = token.allowance(address(this), spender);
        if (value > allowance) revert SafeDecreaseAllowanceFailed();
        forceApprove(token, spender, allowance - value);
    }

    function safePermit(IERC20 token, bytes calldata permit) internal {
        bool success;
        if (permit.length == 32 * 7) {
            success = _makeCalldataCall(token, IERC20Permit.permit.selector, permit);
        } else if (permit.length == 32 * 8) {
            success = _makeCalldataCall(token, IDaiLikePermit.permit.selector, permit);
        } else {
            revert SafePermitBadLength();
        }
        if (!success) RevertReasonForwarder.reRevert();
    }

    function _makeCall(IERC20 token, bytes4 selector, address to, uint256 amount) private returns(bool success) {
        
        assembly { 
            let data := mload(0x40)

            mstore(data, selector)
            mstore(add(data, 0x04), to)
            mstore(add(data, 0x24), amount)
            success := call(gas(), token, 0, data, 0x44, 0x0, 0x20)
            if success {
                switch returndatasize()
                case 0 { success := gt(extcodesize(token), 0) }
                default { success := and(gt(returndatasize(), 31), eq(mload(0), 1)) }
            }
        }
    }

    function _makeCalldataCall(IERC20 token, bytes4 selector, bytes calldata args) private returns(bool success) {
        
        assembly { 
            let len := add(4, args.length)
            let data := mload(0x40)

            mstore(data, selector)
            calldatacopy(add(data, 0x04), args.offset, args.length)
            success := call(gas(), token, 0, data, len, 0x0, 0x20)
            if success {
                switch returndatasize()
                case 0 { success := gt(extcodesize(token), 0) }
                default { success := and(gt(returndatasize(), 31), eq(mload(0), 1)) }
            }
        }
    }
}





pragma solidity ^0.8.0;

interface IWETH is IERC20 {
    function deposit() external payable;
    function withdraw(uint256 amount) external;
}





pragma solidity 0.8.17;







contract ClipperRouter is EthReceiver {
    using SafeERC20 for IERC20;

    uint256 private constant _SIGNATURE_S_MASK = 0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff;
    uint256 private constant _SIGNATURE_V_SHIFT = 255;
    bytes6 private constant _INCH_TAG_WITH_LENGTH_PREFIX = "\x051INCH";
    IERC20 private constant _ETH = IERC20(address(0));
    IWETH private immutable _WETH;  

    constructor(IWETH weth) {
        _WETH = weth;
    }

    
    
    
    
    
    
    
    
    
    
    
    
    
    function clipperSwapToWithPermit(
        IClipperExchangeInterface clipperExchange,
        address payable recipient,
        IERC20 srcToken,
        IERC20 dstToken,
        uint256 inputAmount,
        uint256 outputAmount,
        uint256 goodUntil,
        bytes32 r,
        bytes32 vs,
        bytes calldata permit
    ) external returns(uint256 returnAmount) {
        srcToken.safePermit(permit);
        return clipperSwapTo(clipperExchange, recipient, srcToken, dstToken, inputAmount, outputAmount, goodUntil, r, vs);
    }

    
    
    
    
    
    
    
    
    
    function clipperSwap(
        IClipperExchangeInterface clipperExchange,
        IERC20 srcToken,
        IERC20 dstToken,
        uint256 inputAmount,
        uint256 outputAmount,
        uint256 goodUntil,
        bytes32 r,
        bytes32 vs
    ) external payable returns(uint256 returnAmount) {
        return clipperSwapTo(clipperExchange, payable(msg.sender), srcToken, dstToken, inputAmount, outputAmount, goodUntil, r, vs);
    }

    
    
    
    
    
    
    
    
    
    
    
    function clipperSwapTo(
        IClipperExchangeInterface clipperExchange,
        address payable recipient,
        IERC20 srcToken,
        IERC20 dstToken,
        uint256 inputAmount,
        uint256 outputAmount,
        uint256 goodUntil,
        bytes32 r,
        bytes32 vs
    ) public payable returns(uint256 returnAmount) {
        bool srcETH = srcToken == _ETH;
        if (srcETH) {
            if (msg.value != inputAmount) revert RouterErrors.InvalidMsgValue();
        } else if (srcToken == _WETH) {
            srcETH = true;
            if (msg.value != 0) revert RouterErrors.InvalidMsgValue();
            
            
            address weth = address(_WETH);
            bytes4 transferFromSelector = _WETH.transferFrom.selector;
            bytes4 withdrawSelector = _WETH.withdraw.selector;
            
            assembly { 
                let ptr := mload(0x40)

                mstore(ptr, transferFromSelector)
                mstore(add(ptr, 0x04), caller())
                mstore(add(ptr, 0x24), address())
                mstore(add(ptr, 0x44), inputAmount)
                if iszero(call(gas(), weth, 0, ptr, 0x64, 0, 0)) {
                    returndatacopy(ptr, 0, returndatasize())
                    revert(ptr, returndatasize())
                }

                mstore(ptr, withdrawSelector)
                mstore(add(ptr, 0x04), inputAmount)
                if iszero(call(gas(), weth, 0, ptr, 0x24, 0, 0)) {
                    returndatacopy(ptr, 0, returndatasize())
                    revert(ptr, returndatasize())
                }
            }
        } else {
            if (msg.value != 0) revert RouterErrors.InvalidMsgValue();
            srcToken.safeTransferFrom(msg.sender, address(clipperExchange), inputAmount);
        }

        if (srcETH) {
            
            address clipper = address(clipperExchange);
            bytes4 selector = clipperExchange.sellEthForToken.selector;
            
            assembly { 
                let ptr := mload(0x40)

                mstore(ptr, selector)
                mstore(add(ptr, 0x04), dstToken)
                mstore(add(ptr, 0x24), inputAmount)
                mstore(add(ptr, 0x44), outputAmount)
                mstore(add(ptr, 0x64), goodUntil)
                mstore(add(ptr, 0x84), recipient)
                mstore(add(ptr, 0xa4), add(27, shr(_SIGNATURE_V_SHIFT, vs)))
                mstore(add(ptr, 0xc4), r)
                mstore(add(ptr, 0xe4), and(vs, _SIGNATURE_S_MASK))
                mstore(add(ptr, 0x104), 0x120)
                mstore(add(ptr, 0x143), _INCH_TAG_WITH_LENGTH_PREFIX)
                if iszero(call(gas(), clipper, inputAmount, ptr, 0x149, 0, 0)) {
                    returndatacopy(ptr, 0, returndatasize())
                    revert(ptr, returndatasize())
                }
            }
        } else if (dstToken == _ETH || dstToken == _WETH) {
            
            address clipper = address(clipperExchange);
            bytes4 selector = clipperExchange.sellTokenForEth.selector;
            
            assembly { 
                let ptr := mload(0x40)

                mstore(ptr, selector)
                mstore(add(ptr, 0x04), srcToken)
                mstore(add(ptr, 0x24), inputAmount)
                mstore(add(ptr, 0x44), outputAmount)
                mstore(add(ptr, 0x64), goodUntil)
                switch iszero(dstToken)
                case 1 {
                    mstore(add(ptr, 0x84), recipient)
                }
                default {
                    mstore(add(ptr, 0x84), address())
                }
                mstore(add(ptr, 0xa4), add(27, shr(_SIGNATURE_V_SHIFT, vs)))
                mstore(add(ptr, 0xc4), r)
                mstore(add(ptr, 0xe4), and(vs, _SIGNATURE_S_MASK))
                mstore(add(ptr, 0x104), 0x120)
                mstore(add(ptr, 0x143), _INCH_TAG_WITH_LENGTH_PREFIX)
                if iszero(call(gas(), clipper, 0, ptr, 0x149, 0, 0)) {
                    returndatacopy(ptr, 0, returndatasize())
                    revert(ptr, returndatasize())
                }
            }

            if (dstToken == _WETH) {
                
                
                address weth = address(_WETH);
                bytes4 depositSelector = _WETH.deposit.selector;
                bytes4 transferSelector = _WETH.transfer.selector;
                
                assembly { 
                    let ptr := mload(0x40)

                    mstore(ptr, depositSelector)
                    if iszero(call(gas(), weth, outputAmount, ptr, 0x04, 0, 0)) {
                        returndatacopy(ptr, 0, returndatasize())
                        revert(ptr, returndatasize())
                    }

                    mstore(ptr, transferSelector)
                    mstore(add(ptr, 0x04), recipient)
                    mstore(add(ptr, 0x24), outputAmount)
                    if iszero(call(gas(), weth, 0, ptr, 0x44, 0, 0)) {
                        returndatacopy(ptr, 0, returndatasize())
                        revert(ptr, returndatasize())
                    }
                }
            }
        } else {
            
            address clipper = address(clipperExchange);
            bytes4 selector = clipperExchange.swap.selector;
            
            assembly { 
                let ptr := mload(0x40)

                mstore(ptr, selector)
                mstore(add(ptr, 0x04), srcToken)
                mstore(add(ptr, 0x24), dstToken)
                mstore(add(ptr, 0x44), inputAmount)
                mstore(add(ptr, 0x64), outputAmount)
                mstore(add(ptr, 0x84), goodUntil)
                mstore(add(ptr, 0xa4), recipient)
                mstore(add(ptr, 0xc4), add(27, shr(_SIGNATURE_V_SHIFT, vs)))
                mstore(add(ptr, 0xe4), r)
                mstore(add(ptr, 0x104), and(vs, _SIGNATURE_S_MASK))
                mstore(add(ptr, 0x124), 0x140)
                mstore(add(ptr, 0x163), _INCH_TAG_WITH_LENGTH_PREFIX)
                if iszero(call(gas(), clipper, 0, ptr, 0x169, 0, 0)) {
                    returndatacopy(ptr, 0, returndatasize())
                    revert(ptr, returndatasize())
                }
            }
        }

        return outputAmount;
    }
}





pragma solidity 0.8.17;


interface IAggregationExecutor {
    
    function execute(address msgSender) external payable;  
}





pragma solidity ^0.8.0;


interface IERC20MetadataUppercase {
    function NAME() external view returns (string memory);  
    function SYMBOL() external view returns (string memory);  
}





pragma solidity ^0.8.0;


library StringUtil {
    function toHex(uint256 value) internal pure returns (string memory) {
        return toHex(abi.encodePacked(value));
    }

    function toHex(address value) internal pure returns (string memory) {
        return toHex(abi.encodePacked(value));
    }

    function toHex(bytes memory data) internal pure returns (string memory result) {
        
        assembly { 
            function _toHex16(input) -> output {
                output := or(
                    and(input, 0xFFFFFFFFFFFFFFFF000000000000000000000000000000000000000000000000),
                    shr(64, and(input, 0x0000000000000000FFFFFFFFFFFFFFFF00000000000000000000000000000000))
                )
                output := or(
                    and(output, 0xFFFFFFFF000000000000000000000000FFFFFFFF000000000000000000000000),
                    shr(32, and(output, 0x00000000FFFFFFFF000000000000000000000000FFFFFFFF0000000000000000))
                )
                output := or(
                    and(output, 0xFFFF000000000000FFFF000000000000FFFF000000000000FFFF000000000000),
                    shr(16, and(output, 0x0000FFFF000000000000FFFF000000000000FFFF000000000000FFFF00000000))
                )
                output := or(
                    and(output, 0xFF000000FF000000FF000000FF000000FF000000FF000000FF000000FF000000),
                    shr(8, and(output, 0x00FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF0000))
                )
                output := or(
                    shr(4, and(output, 0xF000F000F000F000F000F000F000F000F000F000F000F000F000F000F000F000)),
                    shr(8, and(output, 0x0F000F000F000F000F000F000F000F000F000F000F000F000F000F000F000F00))
                )
                output := add(
                    add(0x3030303030303030303030303030303030303030303030303030303030303030, output),
                    mul(
                        and(
                            shr(4, add(output, 0x0606060606060606060606060606060606060606060606060606060606060606)),
                            0x0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F
                        ),
                        7   
                    )
                )
            }

            result := mload(0x40)
            let length := mload(data)
            let resultLength := shl(1, length)
            let toPtr := add(result, 0x22)          
            mstore(0x40, add(toPtr, resultLength))  
            mstore(add(result, 2), 0x3078)          
                                                    
            mstore(result, add(resultLength, 2))    

            for {
                let fromPtr := add(data, 0x20)
                let endPtr := add(fromPtr, length)
            } lt(fromPtr, endPtr) {
                fromPtr := add(fromPtr, 0x20)
            } {
                let rawData := mload(fromPtr)
                let hexData := _toHex16(rawData)
                mstore(toPtr, hexData)
                toPtr := add(toPtr, 0x20)
                hexData := _toHex16(shl(128, rawData))
                mstore(toPtr, hexData)
                toPtr := add(toPtr, 0x20)
            }
        }
    }
}






pragma solidity ^0.8.0;


interface IERC20Metadata is IERC20 {
    
    function name() external view returns (string memory);

    
    function symbol() external view returns (string memory);

    
    function decimals() external view returns (uint8);
}





pragma solidity ^0.8.0;





library UniERC20 {
    using SafeERC20 for IERC20;

    error InsufficientBalance();
    error ApproveCalledOnETH();
    error NotEnoughValue();
    error FromIsNotSender();
    error ToIsNotThis();
    error ETHTransferFailed();

    uint256 private constant _RAW_CALL_GAS_LIMIT = 5000;
    IERC20 private constant _ETH_ADDRESS = IERC20(0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE);
    IERC20 private constant _ZERO_ADDRESS = IERC20(address(0));

    function isETH(IERC20 token) internal pure returns (bool) {
        return (token == _ZERO_ADDRESS || token == _ETH_ADDRESS);
    }

    function uniBalanceOf(IERC20 token, address account) internal view returns (uint256) {
        if (isETH(token)) {
            return account.balance;
        } else {
            return token.balanceOf(account);
        }
    }

    
    function uniTransfer(IERC20 token, address payable to, uint256 amount) internal {
        if (amount > 0) {
            if (isETH(token)) {
                if (address(this).balance < amount) revert InsufficientBalance();
                
                (bool success, ) = to.call{value: amount, gas: _RAW_CALL_GAS_LIMIT}("");
                if (!success) revert ETHTransferFailed();
            } else {
                token.safeTransfer(to, amount);
            }
        }
    }

    
    function uniTransferFrom(IERC20 token, address payable from, address to, uint256 amount) internal {
        if (amount > 0) {
            if (isETH(token)) {
                if (msg.value < amount) revert NotEnoughValue();
                if (from != msg.sender) revert FromIsNotSender();
                if (to != address(this)) revert ToIsNotThis();
                if (msg.value > amount) {
                    
                    unchecked {
                        
                        (bool success, ) = from.call{value: msg.value - amount, gas: _RAW_CALL_GAS_LIMIT}("");
                        if (!success) revert ETHTransferFailed();
                    }
                }
            } else {
                token.safeTransferFrom(from, to, amount);
            }
        }
    }

    function uniSymbol(IERC20 token) internal view returns(string memory) {
        return _uniDecode(token, IERC20Metadata.symbol.selector, IERC20MetadataUppercase.SYMBOL.selector);
    }

    function uniName(IERC20 token) internal view returns(string memory) {
        return _uniDecode(token, IERC20Metadata.name.selector, IERC20MetadataUppercase.NAME.selector);
    }

    function uniApprove(IERC20 token, address to, uint256 amount) internal {
        if (isETH(token)) revert ApproveCalledOnETH();

        token.forceApprove(to, amount);
    }

    
    
    function _uniDecode(IERC20 token, bytes4 lowerCaseSelector, bytes4 upperCaseSelector) private view returns(string memory result) {
        if (isETH(token)) {
            return "ETH";
        }

        (bool success, bytes memory data) = address(token).staticcall{ gas: 20000 }(
            abi.encodeWithSelector(lowerCaseSelector)
        );
        if (!success) {
            (success, data) = address(token).staticcall{ gas: 20000 }(
                abi.encodeWithSelector(upperCaseSelector)
            );
        }

        if (success && data.length >= 0x40) {
            (uint256 offset, uint256 len) = abi.decode(data, (uint256, uint256));
            if (offset == 0x20 && len > 0 && data.length == 0x40 + len) {
                
                assembly { 
                    result := add(data, 0x20)
                }
                return result;
            }
        }

        if (success && data.length == 32) {
            uint256 len = 0;
            while (len < data.length && data[len] >= 0x20 && data[len] <= 0x7E) {
                unchecked {
                    len++;
                }
            }

            if (len > 0) {
                
                assembly { 
                    mstore(data, len)
                }
                return string(data);
            }
        }

        return StringUtil.toHex(address(token));
    }
}





pragma solidity 0.8.17;





contract GenericRouter is EthReceiver {
    using UniERC20 for IERC20;
    using SafeERC20 for IERC20;

    error ZeroMinReturn();
    error ZeroReturnAmount();

    uint256 private constant _PARTIAL_FILL = 1 << 0;
    uint256 private constant _REQUIRES_EXTRA_ETH = 1 << 1;

    struct SwapDescription {
        IERC20 srcToken;
        IERC20 dstToken;
        address payable srcReceiver;
        address payable dstReceiver;
        uint256 amount;
        uint256 minReturnAmount;
        uint256 flags;
    }

    
    
    
    
    
    
    
    
    function swap(
        IAggregationExecutor executor,
        SwapDescription calldata desc,
        bytes calldata permit,
        bytes calldata data
    )
        external
        payable
        returns (
            uint256 returnAmount,
            uint256 spentAmount
        )
    {
        if (desc.minReturnAmount == 0) revert ZeroMinReturn();

        IERC20 srcToken = desc.srcToken;
        IERC20 dstToken = desc.dstToken;

        bool srcETH = srcToken.isETH();
        if (desc.flags & _REQUIRES_EXTRA_ETH != 0) {
            if (msg.value <= (srcETH ? desc.amount : 0)) revert RouterErrors.InvalidMsgValue();
        } else {
            if (msg.value != (srcETH ? desc.amount : 0)) revert RouterErrors.InvalidMsgValue();
        }

        if (!srcETH) {
            if (permit.length > 0) {
                srcToken.safePermit(permit);
            }
            srcToken.safeTransferFrom(msg.sender, desc.srcReceiver, desc.amount);
        }

        _execute(executor, msg.sender, desc.amount, data);

        spentAmount = desc.amount;
        
        returnAmount = dstToken.uniBalanceOf(address(this));
        if (returnAmount == 0) revert ZeroReturnAmount();
        unchecked { returnAmount--; }

        if (desc.flags & _PARTIAL_FILL != 0) {
            uint256 unspentAmount = srcToken.uniBalanceOf(address(this));
            if (unspentAmount > 1) {
                
                unchecked { unspentAmount--; }
                spentAmount -= unspentAmount;
                srcToken.uniTransfer(payable(msg.sender), unspentAmount);
            }
            if (returnAmount * desc.amount < desc.minReturnAmount * spentAmount) revert RouterErrors.ReturnAmountIsNotEnough();
        } else {
            if (returnAmount < desc.minReturnAmount) revert RouterErrors.ReturnAmountIsNotEnough();
        }

        address payable dstReceiver = (desc.dstReceiver == address(0)) ? payable(msg.sender) : desc.dstReceiver;
        dstToken.uniTransfer(dstReceiver, returnAmount);
    }

    function _execute(
        IAggregationExecutor executor,
        address srcTokenOwner,
        uint256 inputAmount,
        bytes calldata data
    ) private {
        bytes4 executeSelector = executor.execute.selector;
        
        assembly {  
            let ptr := mload(0x40)

            mstore(ptr, executeSelector)
            mstore(add(ptr, 0x04), srcTokenOwner)
            calldatacopy(add(ptr, 0x24), data.offset, data.length)
            mstore(add(add(ptr, 0x24), data.length), inputAmount)

            if iszero(call(gas(), executor, callvalue(), ptr, add(0x44, data.length), 0, 0)) {
                returndatacopy(ptr, 0, returndatasize())
                revert(ptr, returndatasize())
            }
        }
    }
}





pragma solidity 0.8.17;




contract UnoswapRouter is EthReceiver {
    using SafeERC20 for IERC20;

    error ReservesCallFailed();
    error SwapAmountTooLarge();

    bytes4 private constant _TRANSFER_FROM_CALL_SELECTOR = 0x23b872dd;
    bytes4 private constant _WETH_DEPOSIT_CALL_SELECTOR = 0xd0e30db0;
    bytes4 private constant _WETH_WITHDRAW_CALL_SELECTOR = 0x2e1a7d4d;
    bytes4 private constant _ERC20_TRANSFER_CALL_SELECTOR = 0xa9059cbb;
    uint256 private constant _ADDRESS_MASK =   0x000000000000000000000000ffffffffffffffffffffffffffffffffffffffff;
    uint256 private constant _REVERSE_MASK =   0x8000000000000000000000000000000000000000000000000000000000000000;
    uint256 private constant _WETH_MASK =      0x4000000000000000000000000000000000000000000000000000000000000000;
    uint256 private constant _NUMERATOR_MASK = 0x0000000000000000ffffffff0000000000000000000000000000000000000000;
    
    
    address private constant _WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    bytes4 private constant _UNISWAP_PAIR_RESERVES_CALL_SELECTOR = 0x0902f1ac;
    bytes4 private constant _UNISWAP_PAIR_SWAP_CALL_SELECTOR = 0x022c0d9f;
    uint256 private constant _DENOMINATOR = 1e9;
    uint256 private constant _NUMERATOR_OFFSET = 160;
    uint256 private constant _MAX_SWAP_AMOUNT = (1 << 112) - 1;  

    
    
    
    
    
    
    
    
    
    function unoswapToWithPermit(
        address payable recipient,
        IERC20 srcToken,
        uint256 amount,
        uint256 minReturn,
        uint256[] calldata pools,
        bytes calldata permit
    ) external returns(uint256 returnAmount) {
        srcToken.safePermit(permit);
        return _unoswap(recipient, srcToken, amount, minReturn, pools);
    }

    
    
    
    
    
    
    
    function unoswapTo(
        address payable recipient,
        IERC20 srcToken,
        uint256 amount,
        uint256 minReturn,
        uint256[] calldata pools
    ) external payable returns(uint256 returnAmount) {
        return _unoswap(recipient, srcToken, amount, minReturn, pools);
    }

    
    
    
    
    
    
    function unoswap(
        IERC20 srcToken,
        uint256 amount,
        uint256 minReturn,
        uint256[] calldata pools
    ) external payable returns(uint256 returnAmount) {
        return _unoswap(payable(msg.sender), srcToken, amount, minReturn, pools);
    }

    function _unoswap(
        address payable recipient,
        IERC20 srcToken,
        uint256 amount,
        uint256 minReturn,
        uint256[] calldata pools
    ) private returns(uint256 returnAmount) {
        assembly {  
            function reRevert() {
                returndatacopy(0, 0, returndatasize())
                revert(0, returndatasize())
            }

            function validateERC20Transfer(status) {
                if iszero(status) {
                    reRevert()
                }
                let success := or(
                    iszero(returndatasize()),                       
                    and(gt(returndatasize(), 31), eq(mload(0), 1))  
                )
                if iszero(success) {
                    mstore(0, 0xf27f64e400000000000000000000000000000000000000000000000000000000)  
                    revert(0, 4)
                }
            }

            function swap(emptyPtr, swapAmount, pair, reversed, numerator, to) -> ret {
                mstore(emptyPtr, _UNISWAP_PAIR_RESERVES_CALL_SELECTOR)
                if iszero(staticcall(gas(), pair, emptyPtr, 0x4, emptyPtr, 0x40)) {
                    reRevert()
                }
                if iszero(eq(returndatasize(), 0x60)) {
                    mstore(0, 0x85cd58dc00000000000000000000000000000000000000000000000000000000)  
                    revert(0, 4)
                }

                let reserve0 := mload(emptyPtr)
                let reserve1 := mload(add(emptyPtr, 0x20))
                if reversed {
                    let tmp := reserve0
                    reserve0 := reserve1
                    reserve1 := tmp
                }
                
                ret := mul(swapAmount, numerator)
                ret := div(mul(ret, reserve1), add(ret, mul(reserve0, _DENOMINATOR)))

                mstore(emptyPtr, _UNISWAP_PAIR_SWAP_CALL_SELECTOR)
                reversed := iszero(reversed)
                mstore(add(emptyPtr, 0x04), mul(ret, iszero(reversed)))
                mstore(add(emptyPtr, 0x24), mul(ret, reversed))
                mstore(add(emptyPtr, 0x44), to)
                mstore(add(emptyPtr, 0x64), 0x80)
                mstore(add(emptyPtr, 0x84), 0)
                if iszero(call(gas(), pair, 0, emptyPtr, 0xa4, 0, 0)) {
                    reRevert()
                }
            }

            
            if gt(amount, _MAX_SWAP_AMOUNT) {
                mstore(0, 0xcf0b4d3a00000000000000000000000000000000000000000000000000000000)  
                revert(0, 4)
            }

            let emptyPtr := mload(0x40)
            mstore(0x40, add(emptyPtr, 0xc0))

            let poolsEndOffset := add(pools.offset, shl(5, pools.length))
            let rawPair := calldataload(pools.offset)
            switch srcToken
            case 0 {
                if iszero(eq(amount, callvalue())) {
                    mstore(0, 0x1841b4e100000000000000000000000000000000000000000000000000000000)  
                    revert(0, 4)
                }

                mstore(emptyPtr, _WETH_DEPOSIT_CALL_SELECTOR)
                if iszero(call(gas(), _WETH, amount, emptyPtr, 0x4, 0, 0)) {
                    reRevert()
                }

                mstore(emptyPtr, _ERC20_TRANSFER_CALL_SELECTOR)
                mstore(add(emptyPtr, 0x4), and(rawPair, _ADDRESS_MASK))
                mstore(add(emptyPtr, 0x24), amount)
                if iszero(call(gas(), _WETH, 0, emptyPtr, 0x44, 0, 0)) {
                    reRevert()
                }
            }
            default {
                if callvalue() {
                    mstore(0, 0x1841b4e100000000000000000000000000000000000000000000000000000000)  
                    revert(0, 4)
                }

                mstore(emptyPtr, _TRANSFER_FROM_CALL_SELECTOR)
                mstore(add(emptyPtr, 0x4), caller())
                mstore(add(emptyPtr, 0x24), and(rawPair, _ADDRESS_MASK))
                mstore(add(emptyPtr, 0x44), amount)
                validateERC20Transfer(
                    call(gas(), srcToken, 0, emptyPtr, 0x64, 0, 0x20)
                )
            }

            returnAmount := amount

            for {let i := add(pools.offset, 0x20)} lt(i, poolsEndOffset) {i := add(i, 0x20)} {
                let nextRawPair := calldataload(i)

                returnAmount := swap(
                    emptyPtr,
                    returnAmount,
                    and(rawPair, _ADDRESS_MASK),
                    and(rawPair, _REVERSE_MASK),
                    shr(_NUMERATOR_OFFSET, and(rawPair, _NUMERATOR_MASK)),
                    and(nextRawPair, _ADDRESS_MASK)
                )

                rawPair := nextRawPair
            }

            switch and(rawPair, _WETH_MASK)
            case 0 {
                returnAmount := swap(
                    emptyPtr,
                    returnAmount,
                    and(rawPair, _ADDRESS_MASK),
                    and(rawPair, _REVERSE_MASK),
                    shr(_NUMERATOR_OFFSET, and(rawPair, _NUMERATOR_MASK)),
                    recipient
                )
            }
            default {
                returnAmount := swap(
                    emptyPtr,
                    returnAmount,
                    and(rawPair, _ADDRESS_MASK),
                    and(rawPair, _REVERSE_MASK),
                    shr(_NUMERATOR_OFFSET, and(rawPair, _NUMERATOR_MASK)),
                    address()
                )

                mstore(emptyPtr, _WETH_WITHDRAW_CALL_SELECTOR)
                mstore(add(emptyPtr, 0x04), returnAmount)
                if iszero(call(gas(), _WETH, 0, emptyPtr, 0x24, 0, 0)) {
                    reRevert()
                }

                if iszero(call(gas(), recipient, returnAmount, 0, 0, 0, 0)) {
                    reRevert()
                }
            }
        }
        if (returnAmount < minReturn) revert RouterErrors.ReturnAmountIsNotEnough();
    }
}




pragma solidity 0.8.17;

interface IUniswapV3Pool {
    
    
    
    
    
    
    
    
    
    
    function swap(
        address recipient,
        bool zeroForOne,
        int256 amountSpecified,
        uint160 sqrtPriceLimitX96,
        bytes calldata data
    ) external returns (int256 amount0, int256 amount1);

    
    
    function token0() external view returns (address);

    
    
    function token1() external view returns (address);

    
    
    function fee() external view returns (uint24);
}




pragma solidity 0.8.17;



interface IUniswapV3SwapCallback {
    
    
    
    
    
    
    
    
    
    function uniswapV3SwapCallback(
        int256 amount0Delta,
        int256 amount1Delta,
        bytes calldata data
    ) external;
}






pragma solidity ^0.8.1;


library Address {
    
    function isContract(address account) internal view returns (bool) {
        
        
        

        return account.code.length > 0;
    }

    
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }

    
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            
            if (returndata.length > 0) {
                
                
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}






pragma solidity ^0.8.0;


library SafeCast {
    
    function toUint248(uint256 value) internal pure returns (uint248) {
        require(value <= type(uint248).max, "SafeCast: value doesn't fit in 248 bits");
        return uint248(value);
    }

    
    function toUint240(uint256 value) internal pure returns (uint240) {
        require(value <= type(uint240).max, "SafeCast: value doesn't fit in 240 bits");
        return uint240(value);
    }

    
    function toUint232(uint256 value) internal pure returns (uint232) {
        require(value <= type(uint232).max, "SafeCast: value doesn't fit in 232 bits");
        return uint232(value);
    }

    
    function toUint224(uint256 value) internal pure returns (uint224) {
        require(value <= type(uint224).max, "SafeCast: value doesn't fit in 224 bits");
        return uint224(value);
    }

    
    function toUint216(uint256 value) internal pure returns (uint216) {
        require(value <= type(uint216).max, "SafeCast: value doesn't fit in 216 bits");
        return uint216(value);
    }

    
    function toUint208(uint256 value) internal pure returns (uint208) {
        require(value <= type(uint208).max, "SafeCast: value doesn't fit in 208 bits");
        return uint208(value);
    }

    
    function toUint200(uint256 value) internal pure returns (uint200) {
        require(value <= type(uint200).max, "SafeCast: value doesn't fit in 200 bits");
        return uint200(value);
    }

    
    function toUint192(uint256 value) internal pure returns (uint192) {
        require(value <= type(uint192).max, "SafeCast: value doesn't fit in 192 bits");
        return uint192(value);
    }

    
    function toUint184(uint256 value) internal pure returns (uint184) {
        require(value <= type(uint184).max, "SafeCast: value doesn't fit in 184 bits");
        return uint184(value);
    }

    
    function toUint176(uint256 value) internal pure returns (uint176) {
        require(value <= type(uint176).max, "SafeCast: value doesn't fit in 176 bits");
        return uint176(value);
    }

    
    function toUint168(uint256 value) internal pure returns (uint168) {
        require(value <= type(uint168).max, "SafeCast: value doesn't fit in 168 bits");
        return uint168(value);
    }

    
    function toUint160(uint256 value) internal pure returns (uint160) {
        require(value <= type(uint160).max, "SafeCast: value doesn't fit in 160 bits");
        return uint160(value);
    }

    
    function toUint152(uint256 value) internal pure returns (uint152) {
        require(value <= type(uint152).max, "SafeCast: value doesn't fit in 152 bits");
        return uint152(value);
    }

    
    function toUint144(uint256 value) internal pure returns (uint144) {
        require(value <= type(uint144).max, "SafeCast: value doesn't fit in 144 bits");
        return uint144(value);
    }

    
    function toUint136(uint256 value) internal pure returns (uint136) {
        require(value <= type(uint136).max, "SafeCast: value doesn't fit in 136 bits");
        return uint136(value);
    }

    
    function toUint128(uint256 value) internal pure returns (uint128) {
        require(value <= type(uint128).max, "SafeCast: value doesn't fit in 128 bits");
        return uint128(value);
    }

    
    function toUint120(uint256 value) internal pure returns (uint120) {
        require(value <= type(uint120).max, "SafeCast: value doesn't fit in 120 bits");
        return uint120(value);
    }

    
    function toUint112(uint256 value) internal pure returns (uint112) {
        require(value <= type(uint112).max, "SafeCast: value doesn't fit in 112 bits");
        return uint112(value);
    }

    
    function toUint104(uint256 value) internal pure returns (uint104) {
        require(value <= type(uint104).max, "SafeCast: value doesn't fit in 104 bits");
        return uint104(value);
    }

    
    function toUint96(uint256 value) internal pure returns (uint96) {
        require(value <= type(uint96).max, "SafeCast: value doesn't fit in 96 bits");
        return uint96(value);
    }

    
    function toUint88(uint256 value) internal pure returns (uint88) {
        require(value <= type(uint88).max, "SafeCast: value doesn't fit in 88 bits");
        return uint88(value);
    }

    
    function toUint80(uint256 value) internal pure returns (uint80) {
        require(value <= type(uint80).max, "SafeCast: value doesn't fit in 80 bits");
        return uint80(value);
    }

    
    function toUint72(uint256 value) internal pure returns (uint72) {
        require(value <= type(uint72).max, "SafeCast: value doesn't fit in 72 bits");
        return uint72(value);
    }

    
    function toUint64(uint256 value) internal pure returns (uint64) {
        require(value <= type(uint64).max, "SafeCast: value doesn't fit in 64 bits");
        return uint64(value);
    }

    
    function toUint56(uint256 value) internal pure returns (uint56) {
        require(value <= type(uint56).max, "SafeCast: value doesn't fit in 56 bits");
        return uint56(value);
    }

    
    function toUint48(uint256 value) internal pure returns (uint48) {
        require(value <= type(uint48).max, "SafeCast: value doesn't fit in 48 bits");
        return uint48(value);
    }

    
    function toUint40(uint256 value) internal pure returns (uint40) {
        require(value <= type(uint40).max, "SafeCast: value doesn't fit in 40 bits");
        return uint40(value);
    }

    
    function toUint32(uint256 value) internal pure returns (uint32) {
        require(value <= type(uint32).max, "SafeCast: value doesn't fit in 32 bits");
        return uint32(value);
    }

    
    function toUint24(uint256 value) internal pure returns (uint24) {
        require(value <= type(uint24).max, "SafeCast: value doesn't fit in 24 bits");
        return uint24(value);
    }

    
    function toUint16(uint256 value) internal pure returns (uint16) {
        require(value <= type(uint16).max, "SafeCast: value doesn't fit in 16 bits");
        return uint16(value);
    }

    
    function toUint8(uint256 value) internal pure returns (uint8) {
        require(value <= type(uint8).max, "SafeCast: value doesn't fit in 8 bits");
        return uint8(value);
    }

    
    function toUint256(int256 value) internal pure returns (uint256) {
        require(value >= 0, "SafeCast: value must be positive");
        return uint256(value);
    }

    
    function toInt248(int256 value) internal pure returns (int248) {
        require(value >= type(int248).min && value <= type(int248).max, "SafeCast: value doesn't fit in 248 bits");
        return int248(value);
    }

    
    function toInt240(int256 value) internal pure returns (int240) {
        require(value >= type(int240).min && value <= type(int240).max, "SafeCast: value doesn't fit in 240 bits");
        return int240(value);
    }

    
    function toInt232(int256 value) internal pure returns (int232) {
        require(value >= type(int232).min && value <= type(int232).max, "SafeCast: value doesn't fit in 232 bits");
        return int232(value);
    }

    
    function toInt224(int256 value) internal pure returns (int224) {
        require(value >= type(int224).min && value <= type(int224).max, "SafeCast: value doesn't fit in 224 bits");
        return int224(value);
    }

    
    function toInt216(int256 value) internal pure returns (int216) {
        require(value >= type(int216).min && value <= type(int216).max, "SafeCast: value doesn't fit in 216 bits");
        return int216(value);
    }

    
    function toInt208(int256 value) internal pure returns (int208) {
        require(value >= type(int208).min && value <= type(int208).max, "SafeCast: value doesn't fit in 208 bits");
        return int208(value);
    }

    
    function toInt200(int256 value) internal pure returns (int200) {
        require(value >= type(int200).min && value <= type(int200).max, "SafeCast: value doesn't fit in 200 bits");
        return int200(value);
    }

    
    function toInt192(int256 value) internal pure returns (int192) {
        require(value >= type(int192).min && value <= type(int192).max, "SafeCast: value doesn't fit in 192 bits");
        return int192(value);
    }

    
    function toInt184(int256 value) internal pure returns (int184) {
        require(value >= type(int184).min && value <= type(int184).max, "SafeCast: value doesn't fit in 184 bits");
        return int184(value);
    }

    
    function toInt176(int256 value) internal pure returns (int176) {
        require(value >= type(int176).min && value <= type(int176).max, "SafeCast: value doesn't fit in 176 bits");
        return int176(value);
    }

    
    function toInt168(int256 value) internal pure returns (int168) {
        require(value >= type(int168).min && value <= type(int168).max, "SafeCast: value doesn't fit in 168 bits");
        return int168(value);
    }

    
    function toInt160(int256 value) internal pure returns (int160) {
        require(value >= type(int160).min && value <= type(int160).max, "SafeCast: value doesn't fit in 160 bits");
        return int160(value);
    }

    
    function toInt152(int256 value) internal pure returns (int152) {
        require(value >= type(int152).min && value <= type(int152).max, "SafeCast: value doesn't fit in 152 bits");
        return int152(value);
    }

    
    function toInt144(int256 value) internal pure returns (int144) {
        require(value >= type(int144).min && value <= type(int144).max, "SafeCast: value doesn't fit in 144 bits");
        return int144(value);
    }

    
    function toInt136(int256 value) internal pure returns (int136) {
        require(value >= type(int136).min && value <= type(int136).max, "SafeCast: value doesn't fit in 136 bits");
        return int136(value);
    }

    
    function toInt128(int256 value) internal pure returns (int128) {
        require(value >= type(int128).min && value <= type(int128).max, "SafeCast: value doesn't fit in 128 bits");
        return int128(value);
    }

    
    function toInt120(int256 value) internal pure returns (int120) {
        require(value >= type(int120).min && value <= type(int120).max, "SafeCast: value doesn't fit in 120 bits");
        return int120(value);
    }

    
    function toInt112(int256 value) internal pure returns (int112) {
        require(value >= type(int112).min && value <= type(int112).max, "SafeCast: value doesn't fit in 112 bits");
        return int112(value);
    }

    
    function toInt104(int256 value) internal pure returns (int104) {
        require(value >= type(int104).min && value <= type(int104).max, "SafeCast: value doesn't fit in 104 bits");
        return int104(value);
    }

    
    function toInt96(int256 value) internal pure returns (int96) {
        require(value >= type(int96).min && value <= type(int96).max, "SafeCast: value doesn't fit in 96 bits");
        return int96(value);
    }

    
    function toInt88(int256 value) internal pure returns (int88) {
        require(value >= type(int88).min && value <= type(int88).max, "SafeCast: value doesn't fit in 88 bits");
        return int88(value);
    }

    
    function toInt80(int256 value) internal pure returns (int80) {
        require(value >= type(int80).min && value <= type(int80).max, "SafeCast: value doesn't fit in 80 bits");
        return int80(value);
    }

    
    function toInt72(int256 value) internal pure returns (int72) {
        require(value >= type(int72).min && value <= type(int72).max, "SafeCast: value doesn't fit in 72 bits");
        return int72(value);
    }

    
    function toInt64(int256 value) internal pure returns (int64) {
        require(value >= type(int64).min && value <= type(int64).max, "SafeCast: value doesn't fit in 64 bits");
        return int64(value);
    }

    
    function toInt56(int256 value) internal pure returns (int56) {
        require(value >= type(int56).min && value <= type(int56).max, "SafeCast: value doesn't fit in 56 bits");
        return int56(value);
    }

    
    function toInt48(int256 value) internal pure returns (int48) {
        require(value >= type(int48).min && value <= type(int48).max, "SafeCast: value doesn't fit in 48 bits");
        return int48(value);
    }

    
    function toInt40(int256 value) internal pure returns (int40) {
        require(value >= type(int40).min && value <= type(int40).max, "SafeCast: value doesn't fit in 40 bits");
        return int40(value);
    }

    
    function toInt32(int256 value) internal pure returns (int32) {
        require(value >= type(int32).min && value <= type(int32).max, "SafeCast: value doesn't fit in 32 bits");
        return int32(value);
    }

    
    function toInt24(int256 value) internal pure returns (int24) {
        require(value >= type(int24).min && value <= type(int24).max, "SafeCast: value doesn't fit in 24 bits");
        return int24(value);
    }

    
    function toInt16(int256 value) internal pure returns (int16) {
        require(value >= type(int16).min && value <= type(int16).max, "SafeCast: value doesn't fit in 16 bits");
        return int16(value);
    }

    
    function toInt8(int256 value) internal pure returns (int8) {
        require(value >= type(int8).min && value <= type(int8).max, "SafeCast: value doesn't fit in 8 bits");
        return int8(value);
    }

    
    function toInt256(uint256 value) internal pure returns (int256) {
        
        require(value <= uint256(type(int256).max), "SafeCast: value doesn't fit in an int256");
        return int256(value);
    }
}





pragma solidity 0.8.17;









contract UnoswapV3Router is EthReceiver, IUniswapV3SwapCallback {
    using Address for address payable;
    using SafeERC20 for IERC20;

    error EmptyPools();
    error BadPool();

    uint256 private constant _ONE_FOR_ZERO_MASK = 1 << 255;
    uint256 private constant _WETH_UNWRAP_MASK = 1 << 253;
    bytes32 private constant _POOL_INIT_CODE_HASH = 0xe34f199b19b2b4f47f68442619d555527d244f78a3297ea89325f843f87b8b54;
    bytes32 private constant _FF_FACTORY = 0xff1F98431c8aD98523631AE4a59f267346ea31F9840000000000000000000000;
    
    bytes32 private constant _SELECTORS = 0x0dfe1681d21220a7ddca3f43a9059cbb23b872dd000000000000000000000000;
    uint256 private constant _ADDRESS_MASK =   0x000000000000000000000000ffffffffffffffffffffffffffffffffffffffff;
    
    uint160 private constant _MIN_SQRT_RATIO = 4295128739 + 1;
    
    uint160 private constant _MAX_SQRT_RATIO = 1461446703485210103287273052203988822378723970342 - 1;
    IWETH private immutable _WETH;  

    constructor(IWETH weth) {
        _WETH = weth;
    }

    
    
    
    
    
    
    
    
    
    function uniswapV3SwapToWithPermit(
        address payable recipient,
        IERC20 srcToken,
        uint256 amount,
        uint256 minReturn,
        uint256[] calldata pools,
        bytes calldata permit
    ) external returns(uint256 returnAmount) {
        srcToken.safePermit(permit);
        return _uniswapV3Swap(recipient, amount, minReturn, pools);
    }

    
    
    
    
    function uniswapV3Swap(
        uint256 amount,
        uint256 minReturn,
        uint256[] calldata pools
    ) external payable returns(uint256 returnAmount) {
        return _uniswapV3Swap(payable(msg.sender), amount, minReturn, pools);
    }

    
    
    
    
    
    
    function uniswapV3SwapTo(
        address payable recipient,
        uint256 amount,
        uint256 minReturn,
        uint256[] calldata pools
    ) external payable returns(uint256 returnAmount) {
        return _uniswapV3Swap(recipient, amount, minReturn, pools);
    }

    function _uniswapV3Swap(
        address payable recipient,
        uint256 amount,
        uint256 minReturn,
        uint256[] calldata pools
    ) private returns(uint256 returnAmount) {
        unchecked {
            uint256 len = pools.length;
            if (len == 0) revert EmptyPools();
            uint256 lastIndex = len - 1;
            returnAmount = amount;
            bool wrapWeth = msg.value > 0;
            bool unwrapWeth = pools[lastIndex] & _WETH_UNWRAP_MASK > 0;
            if (wrapWeth) {
                if (msg.value != amount) revert RouterErrors.InvalidMsgValue();
                _WETH.deposit{value: amount}();
            }
            if (len > 1) {
                returnAmount = _makeSwap(address(this), wrapWeth ? address(this) : msg.sender, pools[0], returnAmount);

                for (uint256 i = 1; i < lastIndex; i++) {
                    returnAmount = _makeSwap(address(this), address(this), pools[i], returnAmount);
                }
                returnAmount = _makeSwap(unwrapWeth ? address(this) : recipient, address(this), pools[lastIndex], returnAmount);
            } else {
                returnAmount = _makeSwap(unwrapWeth ? address(this) : recipient, wrapWeth ? address(this) : msg.sender, pools[0], returnAmount);
            }

            if (returnAmount < minReturn) revert RouterErrors.ReturnAmountIsNotEnough();

            if (unwrapWeth) {
                _WETH.withdraw(returnAmount);
                recipient.sendValue(returnAmount);
            }
        }
    }

    
    function uniswapV3SwapCallback(
        int256 amount0Delta,
        int256 amount1Delta,
        bytes calldata 
    ) external override {
        assembly {  
            function reRevert() {
                returndatacopy(0, 0, returndatasize())
                revert(0, returndatasize())
            }

            function validateERC20Transfer(status) {
                if iszero(status) {
                    reRevert()
                }
                let success := or(
                    iszero(returndatasize()),                       
                    and(gt(returndatasize(), 31), eq(mload(0), 1))  
                )
                if iszero(success) {
                    mstore(0, 0xf27f64e400000000000000000000000000000000000000000000000000000000)  
                    revert(0, 4)
                }
            }

            let emptyPtr := mload(0x40)
            let resultPtr := add(emptyPtr, 0x15)  

            mstore(emptyPtr, _SELECTORS)
            if iszero(staticcall(gas(), caller(), emptyPtr, 0x4, resultPtr, 0x20)) {
                reRevert()
            }
            if iszero(staticcall(gas(), caller(), add(emptyPtr, 0x4), 0x4, add(resultPtr, 0x20), 0x20)) {
                reRevert()
            }
            if iszero(staticcall(gas(), caller(), add(emptyPtr, 0x8), 0x4, add(resultPtr, 0x40), 0x20)) {
                reRevert()
            }

            let token
            let amount
            switch sgt(amount0Delta, 0)
            case 1 {
                token := mload(resultPtr)
                amount := amount0Delta
            }
            default {
                token := mload(add(resultPtr, 0x20))
                amount := amount1Delta
            }

            mstore(emptyPtr, _FF_FACTORY)
            mstore(resultPtr, keccak256(resultPtr, 0x60)) 
            mstore(add(resultPtr, 0x20), _POOL_INIT_CODE_HASH)
            let pool := and(keccak256(emptyPtr, 0x55), _ADDRESS_MASK)
            if xor(pool, caller()) {
                mstore(0, 0xb2c0272200000000000000000000000000000000000000000000000000000000)  
                revert(0, 4)
            }

            let payer := calldataload(0x84)
            mstore(emptyPtr, _SELECTORS)
            switch eq(payer, address())
            case 1 {
                
                mstore(add(emptyPtr, 0x10), caller())
                mstore(add(emptyPtr, 0x30), amount)
                validateERC20Transfer(
                    call(gas(), token, 0, add(emptyPtr, 0x0c), 0x44, 0, 0x20)
                )
            }
            default {
                
                mstore(add(emptyPtr, 0x14), payer)
                mstore(add(emptyPtr, 0x34), caller())
                mstore(add(emptyPtr, 0x54), amount)
                validateERC20Transfer(
                    call(gas(), token, 0, add(emptyPtr, 0x10), 0x64, 0, 0x20)
                )
            }
        }
    }

    function _makeSwap(address recipient, address payer, uint256 pool, uint256 amount) private returns (uint256) {
        bool zeroForOne = pool & _ONE_FOR_ZERO_MASK == 0;
        if (zeroForOne) {
            (, int256 amount1) = IUniswapV3Pool(address(uint160(pool))).swap(
                recipient,
                zeroForOne,
                SafeCast.toInt256(amount),
                _MIN_SQRT_RATIO,
                abi.encode(payer)
            );
            return SafeCast.toUint256(-amount1);
        } else {
            (int256 amount0,) = IUniswapV3Pool(address(uint160(pool))).swap(
                recipient,
                zeroForOne,
                SafeCast.toInt256(amount),
                _MAX_SQRT_RATIO,
                abi.encode(payer)
            );
            return SafeCast.toUint256(-amount0);
        }
    }
}





pragma solidity ^0.8.0;

abstract contract OnlyWethReceiver is EthReceiver {
    address private immutable _WETH;  

    constructor(address weth) {
        _WETH = address(weth);
    }

    function _receive() internal virtual override {
        if (msg.sender != _WETH) revert EthDepositRejected();
    }
}






pragma solidity ^0.8.0;


interface IERC1271 {
    
    function isValidSignature(bytes32 hash, bytes memory signature) external view returns (bytes4 magicValue);
}





pragma solidity ^0.8.0;

library ECDSA {
    
    
    
    
    
    
    
    
    
    uint256 private constant _S_BOUNDARY = 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0 + 1;
    uint256 private constant _COMPACT_S_MASK = 0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff;
    uint256 private constant _COMPACT_V_SHIFT = 255;

    function recover(bytes32 hash, uint8 v, bytes32 r, bytes32 s) internal view returns(address signer) {
        
        assembly { 
            if lt(s, _S_BOUNDARY) {
                let ptr := mload(0x40)

                mstore(ptr, hash)
                mstore(add(ptr, 0x20), v)
                mstore(add(ptr, 0x40), r)
                mstore(add(ptr, 0x60), s)
                mstore(0, 0)
                pop(staticcall(gas(), 0x1, ptr, 0x80, 0, 0x20))
                signer := mload(0)
            }
        }
    }

    function recover(bytes32 hash, bytes32 r, bytes32 vs) internal view returns(address signer) {
        
        assembly { 
            let s := and(vs, _COMPACT_S_MASK)
            if lt(s, _S_BOUNDARY) {
                let ptr := mload(0x40)

                mstore(ptr, hash)
                mstore(add(ptr, 0x20), add(27, shr(_COMPACT_V_SHIFT, vs)))
                mstore(add(ptr, 0x40), r)
                mstore(add(ptr, 0x60), s)
                mstore(0, 0)
                pop(staticcall(gas(), 0x1, ptr, 0x80, 0, 0x20))
                signer := mload(0)
            }
        }
    }

    
    
    
    
    
    
    
    function recover(bytes32 hash, bytes calldata signature) internal view returns(address signer) {
        
        assembly { 
            let ptr := mload(0x40)

            
            switch signature.length
            case 65 {
                
                mstore(add(ptr, 0x20), byte(0, calldataload(add(signature.offset, 0x40))))
                calldatacopy(add(ptr, 0x40), signature.offset, 0x40)
            }
            case 64 {
                
                let vs := calldataload(add(signature.offset, 0x20))
                mstore(add(ptr, 0x20), add(27, shr(_COMPACT_V_SHIFT, vs)))
                calldatacopy(add(ptr, 0x40), signature.offset, 0x20)
                mstore(add(ptr, 0x60), and(vs, _COMPACT_S_MASK))
            }
            default {
                ptr := 0
            }

            if ptr {
                if lt(mload(add(ptr, 0x60)), _S_BOUNDARY) {
                    
                    mstore(ptr, hash)

                    mstore(0, 0)
                    pop(staticcall(gas(), 0x1, ptr, 0x80, 0, 0x20))
                    signer := mload(0)
                }
            }
        }
    }

    function recoverOrIsValidSignature(address signer, bytes32 hash, bytes calldata signature) internal view returns(bool success) {
        if (signer == address(0)) return false;
        if ((signature.length == 64 || signature.length == 65) && recover(hash, signature) == signer) {
            return true;
        }
        return isValidSignature(signer, hash, signature);
    }

    function recoverOrIsValidSignature(address signer, bytes32 hash, uint8 v, bytes32 r, bytes32 s) internal view returns(bool success) {
        if (signer == address(0)) return false;
        if (recover(hash, v, r, s) == signer) {
            return true;
        }
        return isValidSignature(signer, hash, v, r, s);
    }

    function recoverOrIsValidSignature(address signer, bytes32 hash, bytes32 r, bytes32 vs) internal view returns(bool success) {
        if (signer == address(0)) return false;
        if (recover(hash, r, vs) == signer) {
            return true;
        }
        return isValidSignature(signer, hash, r, vs);
    }

    function recoverOrIsValidSignature65(address signer, bytes32 hash, bytes32 r, bytes32 vs) internal view returns(bool success) {
        if (signer == address(0)) return false;
        if (recover(hash, r, vs) == signer) {
            return true;
        }
        return isValidSignature65(signer, hash, r, vs);
    }

    function isValidSignature(address signer, bytes32 hash, bytes calldata signature) internal view returns(bool success) {
        
        
        bytes4 selector = IERC1271.isValidSignature.selector;
        
        assembly { 
            let ptr := mload(0x40)

            mstore(ptr, selector)
            mstore(add(ptr, 0x04), hash)
            mstore(add(ptr, 0x24), 0x40)
            mstore(add(ptr, 0x44), signature.length)
            calldatacopy(add(ptr, 0x64), signature.offset, signature.length)
            if staticcall(gas(), signer, ptr, add(0x64, signature.length), 0, 0x20) {
                success := and(eq(selector, mload(0)), eq(returndatasize(), 0x20))
            }
        }
    }

    function isValidSignature(address signer, bytes32 hash, uint8 v, bytes32 r, bytes32 s) internal view returns(bool success) {
        bytes4 selector = IERC1271.isValidSignature.selector;
        
        assembly { 
            let ptr := mload(0x40)

            mstore(ptr, selector)
            mstore(add(ptr, 0x04), hash)
            mstore(add(ptr, 0x24), 0x40)
            mstore(add(ptr, 0x44), 65)
            mstore(add(ptr, 0x64), r)
            mstore(add(ptr, 0x84), s)
            mstore8(add(ptr, 0xa4), v)
            if staticcall(gas(), signer, ptr, 0xa5, 0, 0x20) {
                success := and(eq(selector, mload(0)), eq(returndatasize(), 0x20))
            }
        }
    }

    function isValidSignature(address signer, bytes32 hash, bytes32 r, bytes32 vs) internal view returns(bool success) {
        
        
        bytes4 selector = IERC1271.isValidSignature.selector;
        
        assembly { 
            let ptr := mload(0x40)

            mstore(ptr, selector)
            mstore(add(ptr, 0x04), hash)
            mstore(add(ptr, 0x24), 0x40)
            mstore(add(ptr, 0x44), 64)
            mstore(add(ptr, 0x64), r)
            mstore(add(ptr, 0x84), vs)
            if staticcall(gas(), signer, ptr, 0xa4, 0, 0x20) {
                success := and(eq(selector, mload(0)), eq(returndatasize(), 0x20))
            }
        }
    }

    function isValidSignature65(address signer, bytes32 hash, bytes32 r, bytes32 vs) internal view returns(bool success) {
        
        
        bytes4 selector = IERC1271.isValidSignature.selector;
        
        assembly { 
            let ptr := mload(0x40)

            mstore(ptr, selector)
            mstore(add(ptr, 0x04), hash)
            mstore(add(ptr, 0x24), 0x40)
            mstore(add(ptr, 0x44), 65)
            mstore(add(ptr, 0x64), r)
            mstore(add(ptr, 0x84), and(vs, _COMPACT_S_MASK))
            mstore8(add(ptr, 0xa4), add(27, shr(_COMPACT_V_SHIFT, vs)))
            if staticcall(gas(), signer, ptr, 0xa5, 0, 0x20) {
                success := and(eq(selector, mload(0)), eq(returndatasize(), 0x20))
            }
        }
    }

    function toEthSignedMessageHash(bytes32 hash) internal pure returns (bytes32 res) {
        
        
        
        assembly { 
            mstore(0, 0x19457468657265756d205369676e6564204d6573736167653a0a333200000000) 
            mstore(28, hash)
            res := keccak256(0, 60)
        }
    }

    function toTypedDataHash(bytes32 domainSeparator, bytes32 structHash) internal pure returns (bytes32 res) {
        
        
        assembly { 
            let ptr := mload(0x40)
            mstore(ptr, 0x1901000000000000000000000000000000000000000000000000000000000000) 
            mstore(add(ptr, 0x02), domainSeparator)
            mstore(add(ptr, 0x22), structHash)
            res := keccak256(ptr, 66)
        }
    }
}





pragma solidity 0.8.17;

library OrderRFQLib {
    struct OrderRFQ {
        uint256 info;  
        address makerAsset;
        address takerAsset;
        address maker;
        address allowedSender;  
        uint256 makingAmount;
        uint256 takingAmount;
    }

    bytes32 constant internal _LIMIT_ORDER_RFQ_TYPEHASH = keccak256(
        "OrderRFQ("
            "uint256 info,"
            "address makerAsset,"
            "address takerAsset,"
            "address maker,"
            "address allowedSender,"
            "uint256 makingAmount,"
            "uint256 takingAmount"
        ")"
    );

    function hash(OrderRFQ memory order, bytes32 domainSeparator) internal pure returns(bytes32 result) {
        bytes32 typehash = _LIMIT_ORDER_RFQ_TYPEHASH;
        bytes32 orderHash;
        
        assembly { 
            let ptr := sub(order, 0x20)

            
            let tmp := mload(ptr)
            mstore(ptr, typehash)
            orderHash := keccak256(ptr, 0x100)
            mstore(ptr, tmp)
        }
        return ECDSA.toTypedDataHash(domainSeparator, orderHash);
    }
}






pragma solidity ^0.8.0;


library Strings {
    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";
    uint8 private constant _ADDRESS_LENGTH = 20;

    
    function toString(uint256 value) internal pure returns (string memory) {
        
        

        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

    
    function toHexString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return "0x00";
        }
        uint256 temp = value;
        uint256 length = 0;
        while (temp != 0) {
            length++;
            temp >>= 8;
        }
        return toHexString(value, length);
    }

    
    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _HEX_SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }

    
    function toHexString(address addr) internal pure returns (string memory) {
        return toHexString(uint256(uint160(addr)), _ADDRESS_LENGTH);
    }
}






pragma solidity ^0.8.0;


abstract contract EIP712 {
    
    
    
    bytes32 private immutable _CACHED_DOMAIN_SEPARATOR;
    uint256 private immutable _CACHED_CHAIN_ID;
    address private immutable _CACHED_THIS;

    bytes32 private immutable _HASHED_NAME;
    bytes32 private immutable _HASHED_VERSION;
    bytes32 private immutable _TYPE_HASH;

    

    
    constructor(string memory name, string memory version) {
        bytes32 hashedName = keccak256(bytes(name));
        bytes32 hashedVersion = keccak256(bytes(version));
        bytes32 typeHash = keccak256(
            "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"
        );
        _HASHED_NAME = hashedName;
        _HASHED_VERSION = hashedVersion;
        _CACHED_CHAIN_ID = block.chainid;
        _CACHED_DOMAIN_SEPARATOR = _buildDomainSeparator(typeHash, hashedName, hashedVersion);
        _CACHED_THIS = address(this);
        _TYPE_HASH = typeHash;
    }

    
    function _domainSeparatorV4() internal view returns (bytes32) {
        if (address(this) == _CACHED_THIS && block.chainid == _CACHED_CHAIN_ID) {
            return _CACHED_DOMAIN_SEPARATOR;
        } else {
            return _buildDomainSeparator(_TYPE_HASH, _HASHED_NAME, _HASHED_VERSION);
        }
    }

    function _buildDomainSeparator(
        bytes32 typeHash,
        bytes32 nameHash,
        bytes32 versionHash
    ) private view returns (bytes32) {
        return keccak256(abi.encode(typeHash, nameHash, versionHash, block.chainid, address(this)));
    }

    
    function _hashTypedDataV4(bytes32 structHash) internal view virtual returns (bytes32) {
        return ECDSA.toTypedDataHash(_domainSeparatorV4(), structHash);
    }
}





pragma solidity 0.8.17;

library Errors {
    error InvalidMsgValue();
    error ETHTransferFailed();
}





pragma solidity 0.8.17;


library AmountCalculator {
    
    
    function getMakingAmount(uint256 orderMakerAmount, uint256 orderTakerAmount, uint256 swapTakerAmount) internal pure returns(uint256) {
        return swapTakerAmount * orderMakerAmount / orderTakerAmount;
    }

    
    
    function getTakingAmount(uint256 orderMakerAmount, uint256 orderTakerAmount, uint256 swapMakerAmount) internal pure returns(uint256) {
        return (swapMakerAmount * orderTakerAmount + orderMakerAmount - 1) / orderMakerAmount;
    }
}





pragma solidity 0.8.17;








abstract contract OrderRFQMixin is EIP712, OnlyWethReceiver {
    using SafeERC20 for IERC20;
    using OrderRFQLib for OrderRFQLib.OrderRFQ;

    error RFQZeroTargetIsForbidden();
    error RFQPrivateOrder();
    error RFQBadSignature();
    error OrderExpired();
    error MakingAmountExceeded();
    error TakingAmountExceeded();
    error RFQSwapWithZeroAmount();
    error InvalidatedOrder();

    
    event OrderFilledRFQ(
        bytes32 orderHash,
        uint256 makingAmount
    );

    uint256 private constant _RAW_CALL_GAS_LIMIT = 5000;
    uint256 private constant _MAKER_AMOUNT_FLAG = 1 << 255;
    uint256 private constant _SIGNER_SMART_CONTRACT_HINT = 1 << 254;
    uint256 private constant _IS_VALID_SIGNATURE_65_BYTES = 1 << 253;
    uint256 private constant _UNWRAP_WETH_FLAG = 1 << 252;
    uint256 private constant _AMOUNT_MASK = ~(
        _MAKER_AMOUNT_FLAG |
        _SIGNER_SMART_CONTRACT_HINT |
        _IS_VALID_SIGNATURE_65_BYTES |
        _UNWRAP_WETH_FLAG
    );

    IWETH private immutable _WETH;  
    mapping(address => mapping(uint256 => uint256)) private _invalidator;

    constructor(IWETH weth) OnlyWethReceiver(address(weth)) {
        _WETH = weth;
    }

    
    function invalidatorForOrderRFQ(address maker, uint256 slot) external view returns(uint256 ) {
        return _invalidator[maker][slot];
    }

    
    function cancelOrderRFQ(uint256 orderInfo) external {
        _invalidateOrder(msg.sender, orderInfo, 0);
    }

    
    function cancelOrderRFQ(uint256 orderInfo, uint256 additionalMask) external {
        _invalidateOrder(msg.sender, orderInfo, additionalMask);
    }

    
    function fillOrderRFQ(
        OrderRFQLib.OrderRFQ memory order,
        bytes calldata signature,
        uint256 flagsAndAmount
    ) external payable returns(uint256 , uint256 , bytes32 ) {
        return fillOrderRFQTo(order, signature, flagsAndAmount, msg.sender);
    }

    
    function fillOrderRFQCompact(
        OrderRFQLib.OrderRFQ memory order,
        bytes32 r,
        bytes32 vs,
        uint256 flagsAndAmount
    ) external payable returns(uint256 filledMakingAmount, uint256 filledTakingAmount, bytes32 orderHash) {
        orderHash = order.hash(_domainSeparatorV4());
        if (flagsAndAmount & _SIGNER_SMART_CONTRACT_HINT != 0) {
            if (flagsAndAmount & _IS_VALID_SIGNATURE_65_BYTES != 0) {
                if (!ECDSA.isValidSignature65(order.maker, orderHash, r, vs)) revert RFQBadSignature();
            } else {
                if (!ECDSA.isValidSignature(order.maker, orderHash, r, vs)) revert RFQBadSignature();
            }
        } else {
            if(!ECDSA.recoverOrIsValidSignature(order.maker, orderHash, r, vs)) revert RFQBadSignature();
        }

        (filledMakingAmount, filledTakingAmount) = _fillOrderRFQTo(order, flagsAndAmount, msg.sender);
        emit OrderFilledRFQ(orderHash, filledMakingAmount);
    }

    
    function fillOrderRFQToWithPermit(
        OrderRFQLib.OrderRFQ memory order,
        bytes calldata signature,
        uint256 flagsAndAmount,
        address target,
        bytes calldata permit
    ) external returns(uint256 , uint256 , bytes32 ) {
        IERC20(order.takerAsset).safePermit(permit);
        return fillOrderRFQTo(order, signature, flagsAndAmount, target);
    }

    
    function fillOrderRFQTo(
        OrderRFQLib.OrderRFQ memory order,
        bytes calldata signature,
        uint256 flagsAndAmount,
        address target
    ) public payable returns(uint256 filledMakingAmount, uint256 filledTakingAmount, bytes32 orderHash) {
        orderHash = order.hash(_domainSeparatorV4());
        if (flagsAndAmount & _SIGNER_SMART_CONTRACT_HINT != 0) {
            if (flagsAndAmount & _IS_VALID_SIGNATURE_65_BYTES != 0 && signature.length != 65) revert RFQBadSignature();
            if (!ECDSA.isValidSignature(order.maker, orderHash, signature)) revert RFQBadSignature();
        } else {
            if(!ECDSA.recoverOrIsValidSignature(order.maker, orderHash, signature)) revert RFQBadSignature();
        }
        (filledMakingAmount, filledTakingAmount) = _fillOrderRFQTo(order, flagsAndAmount, target);
        emit OrderFilledRFQ(orderHash, filledMakingAmount);
    }

    function _fillOrderRFQTo(
        OrderRFQLib.OrderRFQ memory order,
        uint256 flagsAndAmount,
        address target
    ) private returns(uint256 makingAmount, uint256 takingAmount) {
        if (target == address(0)) revert RFQZeroTargetIsForbidden();

        address maker = order.maker;

        
        if (order.allowedSender != address(0) && order.allowedSender != msg.sender) revert RFQPrivateOrder();

        {  
            uint256 info = order.info;
            
            uint256 expiration = uint128(info) >> 64;
            if (expiration != 0 && block.timestamp > expiration) revert OrderExpired(); 
            _invalidateOrder(maker, info, 0);
        }

        {  
            uint256 orderMakingAmount = order.makingAmount;
            uint256 orderTakingAmount = order.takingAmount;
            uint256 amount = flagsAndAmount & _AMOUNT_MASK;
            
            if (amount == 0) {
                
                makingAmount = orderMakingAmount;
                takingAmount = orderTakingAmount;
            }
            else if (flagsAndAmount & _MAKER_AMOUNT_FLAG != 0) {
                if (amount > orderMakingAmount) revert MakingAmountExceeded();
                makingAmount = amount;
                takingAmount = AmountCalculator.getTakingAmount(orderMakingAmount, orderTakingAmount, makingAmount);
            }
            else {
                if (amount > orderTakingAmount) revert TakingAmountExceeded();
                takingAmount = amount;
                makingAmount = AmountCalculator.getMakingAmount(orderMakingAmount, orderTakingAmount, takingAmount);
            }
        }

        if (makingAmount == 0 || takingAmount == 0) revert RFQSwapWithZeroAmount();

        
        if (order.makerAsset == address(_WETH) && flagsAndAmount & _UNWRAP_WETH_FLAG != 0) {
            _WETH.transferFrom(maker, address(this), makingAmount);
            _WETH.withdraw(makingAmount);
            
            (bool success, ) = target.call{value: makingAmount, gas: _RAW_CALL_GAS_LIMIT}("");
            if (!success) revert Errors.ETHTransferFailed();
        } else {
            IERC20(order.makerAsset).safeTransferFrom(maker, target, makingAmount);
        }

        
        if (order.takerAsset == address(_WETH) && msg.value > 0) {
            if (msg.value != takingAmount) revert Errors.InvalidMsgValue();
            _WETH.deposit{ value: takingAmount }();
            _WETH.transfer(maker, takingAmount);
        } else {
            if (msg.value != 0) revert Errors.InvalidMsgValue();
            IERC20(order.takerAsset).safeTransferFrom(msg.sender, maker, takingAmount);
        }
    }

    function _invalidateOrder(address maker, uint256 orderInfo, uint256 additionalMask) private {
        uint256 invalidatorSlot = uint64(orderInfo) >> 8;
        uint256 invalidatorBits = (1 << uint8(orderInfo)) | additionalMask;
        mapping(uint256 => uint256) storage invalidatorStorage = _invalidator[maker];
        uint256 invalidator = invalidatorStorage[invalidatorSlot];
        if (invalidator & invalidatorBits == invalidatorBits) revert InvalidatedOrder();
        invalidatorStorage[invalidatorSlot] = invalidator | invalidatorBits;
    }
}





pragma solidity 0.8.17;

library OrderLib {
    struct Order {
        uint256 salt;
        address makerAsset;
        address takerAsset;
        address maker;
        address receiver;
        address allowedSender;  
        uint256 makingAmount;
        uint256 takingAmount;
        uint256 offsets;
        
        
        
        
        
        
        
        
        bytes interactions; 
    }

    bytes32 constant internal _LIMIT_ORDER_TYPEHASH = keccak256(
        "Order("
            "uint256 salt,"
            "address makerAsset,"
            "address takerAsset,"
            "address maker,"
            "address receiver,"
            "address allowedSender,"
            "uint256 makingAmount,"
            "uint256 takingAmount,"
            "uint256 offsets,"
            "bytes interactions"
        ")"
    );

    enum DynamicField {
        MakerAssetData,
        TakerAssetData,
        GetMakingAmount,
        GetTakingAmount,
        Predicate,
        Permit,
        PreInteraction,
        PostInteraction
    }

    function getterIsFrozen(bytes calldata getter) internal pure returns(bool) {
        return getter.length == 1 && getter[0] == "x";
    }

    function _get(Order calldata order, DynamicField field) private pure returns(bytes calldata) {
        uint256 bitShift = uint256(field) << 5; 
        return order.interactions[
            uint32((order.offsets << 32) >> bitShift):
            uint32(order.offsets >> bitShift)
        ];
    }

    function makerAssetData(Order calldata order) internal pure returns(bytes calldata) {
        return _get(order, DynamicField.MakerAssetData);
    }

    function takerAssetData(Order calldata order) internal pure returns(bytes calldata) {
        return _get(order, DynamicField.TakerAssetData);
    }

    function getMakingAmount(Order calldata order) internal pure returns(bytes calldata) {
        return _get(order, DynamicField.GetMakingAmount);
    }

    function getTakingAmount(Order calldata order) internal pure returns(bytes calldata) {
        return _get(order, DynamicField.GetTakingAmount);
    }

    function predicate(Order calldata order) internal pure returns(bytes calldata) {
        return _get(order, DynamicField.Predicate);
    }

    function permit(Order calldata order) internal pure returns(bytes calldata) {
        return _get(order, DynamicField.Permit);
    }

    function preInteraction(Order calldata order) internal pure returns(bytes calldata) {
        return _get(order, DynamicField.PreInteraction);
    }

    function postInteraction(Order calldata order) internal pure returns(bytes calldata) {
        return _get(order, DynamicField.PostInteraction);
    }

    function hash(Order calldata order, bytes32 domainSeparator) internal pure returns(bytes32 result) {
        bytes calldata interactions = order.interactions;
        bytes32 typehash = _LIMIT_ORDER_TYPEHASH;
        
        assembly { 
            let ptr := mload(0x40)

            
            calldatacopy(ptr, interactions.offset, interactions.length)
            mstore(add(ptr, 0x140), keccak256(ptr, interactions.length))
            calldatacopy(add(ptr, 0x20), order, 0x120)
            mstore(ptr, typehash)
            result := keccak256(ptr, 0x160)
        }
        result = ECDSA.toTypedDataHash(domainSeparator, result);
    }
}





pragma solidity 0.8.17;


library ArgumentsDecoder {
    error IncorrectDataLength();

    function decodeUint256(bytes calldata data, uint256 offset) internal pure returns(uint256 value) {
        unchecked { if (data.length < offset + 32) revert IncorrectDataLength(); }
        
        assembly { 
            value := calldataload(add(data.offset, offset))
        }
    }

    function decodeSelector(bytes calldata data) internal pure returns(bytes4 value) {
        if (data.length < 4) revert IncorrectDataLength();
        
        assembly { 
            value := calldataload(data.offset)
        }
    }

    function decodeTailCalldata(bytes calldata data, uint256 tailOffset) internal pure returns(bytes calldata args) {
        if (data.length < tailOffset) revert IncorrectDataLength();
        
        assembly {  
            args.offset := add(data.offset, tailOffset)
            args.length := sub(data.length, tailOffset)
        }
    }

    function decodeTargetAndCalldata(bytes calldata data) internal pure returns(address target, bytes calldata args) {
        if (data.length < 20) revert IncorrectDataLength();
        
        assembly {  
            target := shr(96, calldataload(data.offset))
            args.offset := add(data.offset, 20)
            args.length := sub(data.length, 20)
        }
    }
}





pragma solidity 0.8.17;


contract NonceManager {
    error AdvanceNonceFailed();
    event NonceIncreased(address indexed maker, uint256 newNonce);

    mapping(address => uint256) public nonce;

    
    function increaseNonce() external {
        advanceNonce(1);
    }

    
    function advanceNonce(uint8 amount) public {
        if (amount == 0) revert AdvanceNonceFailed();
        uint256 newNonce = nonce[msg.sender] + amount;
        nonce[msg.sender] = newNonce;
        emit NonceIncreased(msg.sender, newNonce);
    }

    
    
    function nonceEquals(address makerAddress, uint256 makerNonce) public view returns(bool) {
        return nonce[makerAddress] == makerNonce;
    }
}





pragma solidity 0.8.17;



contract PredicateHelper is NonceManager {
    using ArgumentsDecoder for bytes;

    error ArbitraryStaticCallFailed();

    
    
    function or(uint256 offsets, bytes calldata data) public view returns(bool) {
        uint256 current;
        uint256 previous;
        for (uint256 i = 0; (current = uint32(offsets >> i)) != 0; i += 32) {
            (bool success, uint256 res) = _selfStaticCall(data[previous:current]);
            if (success && res == 1) {
                return true;
            }
            previous = current;
        }
        return false;
    }

    
    
    function and(uint256 offsets, bytes calldata data) public view returns(bool) {
        uint256 current;
        uint256 previous;
        for (uint256 i = 0; (current = uint32(offsets >> i)) != 0; i += 32) {
            (bool success, uint256 res) = _selfStaticCall(data[previous:current]);
            if (!success || res != 1) {
                return false;
            }
            previous = current;
        }
        return true;
    }

    
    
    
    function eq(uint256 value, bytes calldata data) public view returns(bool) {
        (bool success, uint256 res) = _selfStaticCall(data);
        return success && res == value;
    }

    
    
    
    function lt(uint256 value, bytes calldata data) public view returns(bool) {
        (bool success, uint256 res) = _selfStaticCall(data);
        return success && res < value;
    }

    
    
    
    function gt(uint256 value, bytes calldata data) public view returns(bool) {
        (bool success, uint256 res) = _selfStaticCall(data);
        return success && res > value;
    }

    
    
    function timestampBelow(uint256 time) public view returns(bool) {
        return block.timestamp < time;  
    }

    
    
    function arbitraryStaticCall(address target, bytes calldata data) public view returns(uint256) {
        (bool success, uint256 res) = _staticcallForUint(target, data);
        if (!success) revert ArbitraryStaticCallFailed();
        return res;
    }

    function timestampBelowAndNonceEquals(uint256 timeNonceAccount) public view returns(bool) {
        uint256 _time = uint48(timeNonceAccount >> 208);
        uint256 _nonce = uint48(timeNonceAccount >> 160);
        address _account = address(uint160(timeNonceAccount));
        return timestampBelow(_time) && nonceEquals(_account, _nonce);
    }

    function _selfStaticCall(bytes calldata data) internal view returns(bool, uint256) {
        uint256 selector = uint32(data.decodeSelector());
        uint256 arg = data.decodeUint256(4);

        
        if (selector == uint32(this.timestampBelowAndNonceEquals.selector)) {  
            return (true, timestampBelowAndNonceEquals(arg) ? 1 : 0);
        }

        if (selector < uint32(this.arbitraryStaticCall.selector)) {  
            if (selector < uint32(this.eq.selector)) {  
                if (selector == uint32(this.gt.selector)) {  
                    return (true, gt(arg, data.decodeTailCalldata(100)) ? 1 : 0);
                } else if (selector == uint32(this.timestampBelow.selector)) {  
                    return (true, timestampBelow(arg) ? 1 : 0);
                }
            } else {
                if (selector == uint32(this.eq.selector)) {  
                    return (true, eq(arg, data.decodeTailCalldata(100)) ? 1 : 0);
                } else if (selector == uint32(this.or.selector)) {  
                    return (true, or(arg, data.decodeTailCalldata(100)) ? 1 : 0);
                }
            }
        } else {
            if (selector < uint32(this.lt.selector)) {  
                if (selector == uint32(this.arbitraryStaticCall.selector)) {  
                    return (true, arbitraryStaticCall(address(uint160(arg)), data.decodeTailCalldata(100)));
                } else if (selector == uint32(this.and.selector)) {  
                    return (true, and(arg, data.decodeTailCalldata(100)) ? 1 : 0);
                }
            } else {
                if (selector == uint32(this.lt.selector)) {  
                    return (true, lt(arg, data.decodeTailCalldata(100)) ? 1 : 0);
                } else if (selector == uint32(this.nonceEquals.selector)) {  
                    return (true, nonceEquals(address(uint160(arg)), data.decodeUint256(0x24)) ? 1 : 0);
                }
            }
        }

        return _staticcallForUint(address(this), data);
    }

    function _staticcallForUint(address target, bytes calldata input) private view returns(bool success, uint256 res) {
        
        assembly { 
            let data := mload(0x40)

            calldatacopy(data, input.offset, input.length)
            success := staticcall(gas(), target, data, input.length, 0x0, 0x20)
            success := and(success, eq(returndatasize(), 32))
            if success {
                res := mload(0)
            }
        }
    }
}





pragma solidity 0.8.17;

interface IOrderMixin {
    
    function remaining(bytes32 orderHash) external view returns(uint256 amount);

    
    function remainingRaw(bytes32 orderHash) external view returns(uint256 rawAmount);

    
    function remainingsRaw(bytes32[] memory orderHashes) external view returns(uint256[] memory rawAmounts);

    
    function checkPredicate(OrderLib.Order calldata order) external view returns(bool result);

    
    function hashOrder(OrderLib.Order calldata order) external view returns(bytes32);

    
    function simulate(address target, bytes calldata data) external;

    
    function cancelOrder(OrderLib.Order calldata order) external returns(uint256 orderRemaining, bytes32 orderHash);

    
    function fillOrder(
        OrderLib.Order calldata order,
        bytes calldata signature,
        bytes calldata interaction,
        uint256 makingAmount,
        uint256 takingAmount,
        uint256 skipPermitAndThresholdAmount
    ) external payable returns(uint256 actualMakingAmount, uint256 actualTakingAmount, bytes32 orderHash);

    
    function fillOrderToWithPermit(
        OrderLib.Order calldata order,
        bytes calldata signature,
        bytes calldata interaction,
        uint256 makingAmount,
        uint256 takingAmount,
        uint256 skipPermitAndThresholdAmount,
        address target,
        bytes calldata permit
    ) external returns(uint256 actualMakingAmount, uint256 actualTakingAmount, bytes32 orderHash);

    
    function fillOrderTo(
        OrderLib.Order calldata order_,
        bytes calldata signature,
        bytes calldata interaction,
        uint256 makingAmount,
        uint256 takingAmount,
        uint256 skipPermitAndThresholdAmount,
        address target
    ) external payable returns(uint256 actualMakingAmount, uint256 actualTakingAmount, bytes32 orderHash);
}





pragma solidity 0.8.17;


interface PreInteractionNotificationReceiver {
    function fillOrderPreInteraction(
        bytes32 orderHash,
        address maker,
        address taker,
        uint256 makingAmount,
        uint256 takingAmount,
        uint256 remainingAmount,
        bytes memory interactiveData
    ) external;
}

interface PostInteractionNotificationReceiver {
    
    
    function fillOrderPostInteraction(
        bytes32 orderHash,
        address maker,
        address taker,
        uint256 makingAmount,
        uint256 takingAmount,
        uint256 remainingAmount,
        bytes memory interactiveData
    ) external;
}

interface InteractionNotificationReceiver {
    function fillOrderInteraction(
        address taker,
        uint256 makingAmount,
        uint256 takingAmount,
        bytes memory interactiveData
    ) external returns(uint256 offeredTakingAmount);
}





pragma solidity 0.8.17;












abstract contract OrderMixin is IOrderMixin, EIP712, PredicateHelper {
    using SafeERC20 for IERC20;
    using ArgumentsDecoder for bytes;
    using OrderLib for OrderLib.Order;

    error UnknownOrder();
    error AccessDenied();
    error AlreadyFilled();
    error PermitLengthTooLow();
    error ZeroTargetIsForbidden();
    error RemainingAmountIsZero();
    error PrivateOrder();
    error BadSignature();
    error ReentrancyDetected();
    error PredicateIsNotTrue();
    error OnlyOneAmountShouldBeZero();
    error TakingAmountTooHigh();
    error MakingAmountTooLow();
    error SwapWithZeroAmount();
    error TransferFromMakerToTakerFailed();
    error TransferFromTakerToMakerFailed();
    error WrongAmount();
    error WrongGetter();
    error GetAmountCallFailed();
    error TakingAmountIncreased();
    error SimulationResults(bool success, bytes res);

    
    event OrderFilled(
        address indexed maker,
        bytes32 orderHash,
        uint256 remaining
    );

    
    event OrderCanceled(
        address indexed maker,
        bytes32 orderHash,
        uint256 remainingRaw
    );

    uint256 constant private _ORDER_DOES_NOT_EXIST = 0;
    uint256 constant private _ORDER_FILLED = 1;
    uint256 constant private _SKIP_PERMIT_FLAG = 1 << 255;
    uint256 constant private _THRESHOLD_MASK = ~_SKIP_PERMIT_FLAG;

    IWETH private immutable _WETH;  
    
    
    mapping(bytes32 => uint256) private _remaining;

    constructor(IWETH weth) {
        _WETH = weth;
    }

    
    function remaining(bytes32 orderHash) external view returns(uint256 ) {
        uint256 amount = _remaining[orderHash];
        if (amount == _ORDER_DOES_NOT_EXIST) revert UnknownOrder();
        unchecked { return amount - 1; }
    }

    
    function remainingRaw(bytes32 orderHash) external view returns(uint256 ) {
        return _remaining[orderHash];
    }

    
    function remainingsRaw(bytes32[] memory orderHashes) external view returns(uint256[] memory ) {
        uint256[] memory results = new uint256[](orderHashes.length);
        for (uint256 i = 0; i < orderHashes.length; i++) {
            results[i] = _remaining[orderHashes[i]];
        }
        return results;
    }

    
    function simulate(address target, bytes calldata data) external {
        
        (bool success, bytes memory result) = target.delegatecall(data);
        revert SimulationResults(success, result);
    }

    
    function cancelOrder(OrderLib.Order calldata order) external returns(uint256 orderRemaining, bytes32 orderHash) {
        if (order.maker != msg.sender) revert AccessDenied();

        orderHash = hashOrder(order);
        orderRemaining = _remaining[orderHash];
        if (orderRemaining == _ORDER_FILLED) revert AlreadyFilled();
        emit OrderCanceled(msg.sender, orderHash, orderRemaining);
        _remaining[orderHash] = _ORDER_FILLED;
    }

    
    function fillOrder(
        OrderLib.Order calldata order,
        bytes calldata signature,
        bytes calldata interaction,
        uint256 makingAmount,
        uint256 takingAmount,
        uint256 skipPermitAndThresholdAmount
    ) external payable returns(uint256 , uint256 , bytes32 ) {
        return fillOrderTo(order, signature, interaction, makingAmount, takingAmount, skipPermitAndThresholdAmount, msg.sender);
    }

    
    function fillOrderToWithPermit(
        OrderLib.Order calldata order,
        bytes calldata signature,
        bytes calldata interaction,
        uint256 makingAmount,
        uint256 takingAmount,
        uint256 skipPermitAndThresholdAmount,
        address target,
        bytes calldata permit
    ) external returns(uint256 , uint256 , bytes32 ) {
        if (permit.length < 20) revert PermitLengthTooLow();
        {  
            (address token, bytes calldata permitData) = permit.decodeTargetAndCalldata();
            IERC20(token).safePermit(permitData);
        }
        return fillOrderTo(order, signature, interaction, makingAmount, takingAmount, skipPermitAndThresholdAmount, target);
    }

    
    function fillOrderTo(
        OrderLib.Order calldata order_,
        bytes calldata signature,
        bytes calldata interaction,
        uint256 makingAmount,
        uint256 takingAmount,
        uint256 skipPermitAndThresholdAmount,
        address target
    ) public payable returns(uint256 actualMakingAmount, uint256 actualTakingAmount, bytes32 orderHash) {
        if (target == address(0)) revert ZeroTargetIsForbidden();
        orderHash = hashOrder(order_);

        OrderLib.Order calldata order = order_; 
        actualMakingAmount = makingAmount;
        actualTakingAmount = takingAmount;

        uint256 remainingMakingAmount = _remaining[orderHash];
        if (remainingMakingAmount == _ORDER_FILLED) revert RemainingAmountIsZero();
        if (order.allowedSender != address(0) && order.allowedSender != msg.sender) revert PrivateOrder();
        if (remainingMakingAmount == _ORDER_DOES_NOT_EXIST) {
            
            if (!ECDSA.recoverOrIsValidSignature(order.maker, orderHash, signature)) revert BadSignature();
            remainingMakingAmount = order.makingAmount;

            bytes calldata permit = order.permit();
            if (skipPermitAndThresholdAmount & _SKIP_PERMIT_FLAG == 0 && permit.length >= 20) {
                
                (address token, bytes calldata permitCalldata) = permit.decodeTargetAndCalldata();
                IERC20(token).safePermit(permitCalldata);
                if (_remaining[orderHash] != _ORDER_DOES_NOT_EXIST) revert ReentrancyDetected();
            }
        } else {
            unchecked { remainingMakingAmount -= 1; }
        }

        
        if (order.predicate().length > 0) {
            if (!checkPredicate(order)) revert PredicateIsNotTrue();
        }

        
        if ((actualTakingAmount == 0) == (actualMakingAmount == 0)) {
            revert OnlyOneAmountShouldBeZero();
        } else if (actualTakingAmount == 0) {
            if (actualMakingAmount > remainingMakingAmount) {
                actualMakingAmount = remainingMakingAmount;
            }
            actualTakingAmount = _getTakingAmount(order.getTakingAmount(), order.makingAmount, actualMakingAmount, order.takingAmount, remainingMakingAmount, orderHash);
            uint256 thresholdAmount = skipPermitAndThresholdAmount & _THRESHOLD_MASK;
            
            
            if (actualTakingAmount * makingAmount > thresholdAmount * actualMakingAmount) revert TakingAmountTooHigh();
        } else {
            actualMakingAmount = _getMakingAmount(order.getMakingAmount(), order.takingAmount, actualTakingAmount, order.makingAmount, remainingMakingAmount, orderHash);
            if (actualMakingAmount > remainingMakingAmount) {
                actualMakingAmount = remainingMakingAmount;
                actualTakingAmount = _getTakingAmount(order.getTakingAmount(), order.makingAmount, actualMakingAmount, order.takingAmount, remainingMakingAmount, orderHash);
                if (actualTakingAmount > takingAmount) revert TakingAmountIncreased();
            }
            uint256 thresholdAmount = skipPermitAndThresholdAmount & _THRESHOLD_MASK;
            
            
            if (actualMakingAmount * takingAmount < thresholdAmount * actualTakingAmount) revert MakingAmountTooLow();
        }

        if (actualMakingAmount == 0 || actualTakingAmount == 0) revert SwapWithZeroAmount();

        
        unchecked {
            remainingMakingAmount = remainingMakingAmount - actualMakingAmount;
            _remaining[orderHash] = remainingMakingAmount + 1;
        }
        emit OrderFilled(order_.maker, orderHash, remainingMakingAmount);

        
        if (order.preInteraction().length >= 20) {
            
            (address interactionTarget, bytes calldata interactionData) = order.preInteraction().decodeTargetAndCalldata();
            PreInteractionNotificationReceiver(interactionTarget).fillOrderPreInteraction(
                orderHash, order.maker, msg.sender, actualMakingAmount, actualTakingAmount, remainingMakingAmount, interactionData
            );
        }

        
        if (!_callTransferFrom(
            order.makerAsset,
            order.maker,
            target,
            actualMakingAmount,
            order.makerAssetData()
        )) revert TransferFromMakerToTakerFailed();

        if (interaction.length >= 20) {
            
            (address interactionTarget, bytes calldata interactionData) = interaction.decodeTargetAndCalldata();
            uint256 offeredTakingAmount = InteractionNotificationReceiver(interactionTarget).fillOrderInteraction(
                msg.sender, actualMakingAmount, actualTakingAmount, interactionData
            );

            if (offeredTakingAmount > actualTakingAmount &&
                !OrderLib.getterIsFrozen(order.getMakingAmount()) &&
                !OrderLib.getterIsFrozen(order.getTakingAmount()))
            {
                actualTakingAmount = offeredTakingAmount;
            }
        }

        
        if (order.takerAsset == address(_WETH) && msg.value > 0) {
            if (msg.value < actualTakingAmount) revert Errors.InvalidMsgValue();
            if (msg.value > actualTakingAmount) {
                unchecked {
                    (bool success, ) = msg.sender.call{value: msg.value - actualTakingAmount}("");  
                    if (!success) revert Errors.ETHTransferFailed();
                }
            }
            _WETH.deposit{ value: actualTakingAmount }();
            _WETH.transfer(order.receiver == address(0) ? order.maker : order.receiver, actualTakingAmount);
        } else {
            if (msg.value != 0) revert Errors.InvalidMsgValue();
            if (!_callTransferFrom(
                order.takerAsset,
                msg.sender,
                order.receiver == address(0) ? order.maker : order.receiver,
                actualTakingAmount,
                order.takerAssetData()
            )) revert TransferFromTakerToMakerFailed();
        }

        
        if (order.postInteraction().length >= 20) {
            
            (address interactionTarget, bytes calldata interactionData) = order.postInteraction().decodeTargetAndCalldata();
            PostInteractionNotificationReceiver(interactionTarget).fillOrderPostInteraction(
                 orderHash, order.maker, msg.sender, actualMakingAmount, actualTakingAmount, remainingMakingAmount, interactionData
            );
        }
    }

    
    function checkPredicate(OrderLib.Order calldata order) public view returns(bool) {
        (bool success, uint256 res) = _selfStaticCall(order.predicate());
        return success && res == 1;
    }

    
    function hashOrder(OrderLib.Order calldata order) public view returns(bytes32) {
        return order.hash(_domainSeparatorV4());
    }

    function _callTransferFrom(address asset, address from, address to, uint256 amount, bytes calldata input) private returns(bool success) {
        bytes4 selector = IERC20.transferFrom.selector;
        
        assembly { 
            let data := mload(0x40)

            mstore(data, selector)
            mstore(add(data, 0x04), from)
            mstore(add(data, 0x24), to)
            mstore(add(data, 0x44), amount)
            calldatacopy(add(data, 0x64), input.offset, input.length)
            let status := call(gas(), asset, 0, data, add(0x64, input.length), 0x0, 0x20)
            success := and(status, or(iszero(returndatasize()), and(gt(returndatasize(), 31), eq(mload(0), 1))))
        }
    }

    function _getMakingAmount(
        bytes calldata getter,
        uint256 orderTakingAmount,
        uint256 requestedTakingAmount,
        uint256 orderMakingAmount,
        uint256 remainingMakingAmount,
        bytes32 orderHash
    ) private view returns(uint256) {
        if (getter.length == 0) {
            
            return AmountCalculator.getMakingAmount(orderMakingAmount, orderTakingAmount, requestedTakingAmount);
        }
        return _callGetter(getter, orderTakingAmount, requestedTakingAmount, orderMakingAmount, remainingMakingAmount, orderHash);
    }

    function _getTakingAmount(
        bytes calldata getter,
        uint256 orderMakingAmount,
        uint256 requestedMakingAmount,
        uint256 orderTakingAmount,
        uint256 remainingMakingAmount,
        bytes32 orderHash
    ) private view returns(uint256) {
        if (getter.length == 0) {
            
            return AmountCalculator.getTakingAmount(orderMakingAmount, orderTakingAmount, requestedMakingAmount);
        }
        return _callGetter(getter, orderMakingAmount, requestedMakingAmount, orderTakingAmount, remainingMakingAmount, orderHash);
    }

    function _callGetter(
        bytes calldata getter,
        uint256 orderExpectedAmount,
        uint256 requestedAmount,
        uint256 orderResultAmount,
        uint256 remainingMakingAmount,
        bytes32 orderHash
    ) private view returns(uint256) {
        if (getter.length == 1) {
            if (OrderLib.getterIsFrozen(getter)) {
                
                if (requestedAmount != orderExpectedAmount) revert WrongAmount();
                return orderResultAmount;
            } else {
                revert WrongGetter();
            }
        } else {
            (address target, bytes calldata data) = getter.decodeTargetAndCalldata();
            (bool success, bytes memory result) = target.staticcall(abi.encodePacked(data, requestedAmount, remainingMakingAmount, orderHash));
            if (!success || result.length != 32) revert GetAmountCallFailed();
            return abi.decode(result, (uint256));
        }
    }
}






pragma solidity ^0.8.0;


abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}






pragma solidity ^0.8.0;


abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    
    constructor() {
        _transferOwnership(_msgSender());
    }

    
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    
    function owner() public view virtual returns (address) {
        return _owner;
    }

    
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }

    
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}





pragma solidity 0.8.17;










contract AggregationRouterV5 is EIP712("1inch Aggregation Router", "5"), Ownable,
    ClipperRouter, GenericRouter, UnoswapRouter, UnoswapV3Router, OrderMixin, OrderRFQMixin
{
    using UniERC20 for IERC20;

    error ZeroAddress();

    
    constructor(IWETH weth)
        UnoswapV3Router(weth)
        ClipperRouter(weth)
        OrderMixin(weth)
        OrderRFQMixin(weth)
    {
        if (address(weth) == address(0)) revert ZeroAddress();
    }

    
    function rescueFunds(IERC20 token, uint256 amount) external onlyOwner {
        token.uniTransfer(payable(msg.sender), amount);
    }

    
    function destroy() external onlyOwner {
        selfdestruct(payable(msg.sender));
    }

    function _receive() internal override(EthReceiver, OnlyWethReceiver) {
        EthReceiver._receive();
    }
}