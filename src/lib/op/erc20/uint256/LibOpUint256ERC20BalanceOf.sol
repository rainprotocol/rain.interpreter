// SPDX-License-Identifier: CAL
pragma solidity ^0.8.18;

import {IERC20} from "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import {Pointer} from "rain.solmem/lib/LibPointer.sol";
import {IntegrityCheckState} from "../../../integrity/LibIntegrityCheckNP.sol";
import {OperandV2} from "rain.interpreter.interface/interface/unstable/IInterpreterV4.sol";
import {InterpreterState} from "../../../state/LibInterpreterState.sol";

/// @title OpUint256ERC20BalanceOf
/// @notice Opcode for getting the current erc20 balance of an account.
library LibOpUint256ERC20BalanceOf {
    function integrity(IntegrityCheckState memory, OperandV2) internal pure returns (uint256, uint256) {
        // Always 2 inputs, the token and the account.
        // Always 1 output, the balance.
        return (2, 1);
    }

    function run(InterpreterState memory, OperandV2, Pointer stackTop) internal view returns (Pointer) {
        uint256 token;
        uint256 account;
        assembly ("memory-safe") {
            token := mload(stackTop)
            stackTop := add(stackTop, 0x20)
            account := mload(stackTop)
        }
        uint256 tokenBalance = IERC20(address(uint160(token))).balanceOf(address(uint160(account)));
        assembly ("memory-safe") {
            mstore(stackTop, tokenBalance)
        }
        return stackTop;
    }

    function referenceFn(InterpreterState memory, OperandV2, uint256[] memory inputs)
        internal
        view
        returns (uint256[] memory)
    {
        uint256 token = inputs[0];
        uint256 account = inputs[1];
        uint256 tokenBalance = IERC20(address(uint160(token))).balanceOf(address(uint160(account)));
        uint256[] memory outputs = new uint256[](1);
        outputs[0] = tokenBalance;
        return outputs;
    }
}
