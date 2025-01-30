// SPDX-License-Identifier: CAL
pragma solidity ^0.8.18;

import {IntegrityCheckState} from "../../integrity/LibIntegrityCheckNP.sol";
import {OperandV2, StackItem} from "rain.interpreter.interface/interface/unstable/IInterpreterV4.sol";
import {InterpreterState} from "../../state/LibInterpreterState.sol";
import {Pointer} from "rain.solmem/lib/LibPointer.sol";

/// Thrown when a constant read index is outside the constants array.
error OutOfBoundsConstantRead(uint256 opIndex, uint256 constantsLength, uint256 constantRead);

/// @title LibOpConstantNP
/// Implementation of copying a constant from the constants array to the stack.
/// Integrated deeply into LibParse, which requires this opcode or a variant
/// to be present at a known opcode index.
library LibOpConstantNP {
    function integrity(IntegrityCheckState memory state, OperandV2 operand) internal pure returns (uint256, uint256) {
        // Operand is the index so ensure it doesn't exceed the constants length.
        uint256 constantIndex = uint256(OperandV2.unwrap(operand) & bytes32(uint256(0xFFFF)));
        if (constantIndex >= state.constants.length) {
            revert OutOfBoundsConstantRead(state.opIndex, state.constants.length, constantIndex);
        }
        // As inputs MUST always be 0, we don't have to check the high byte of
        // the operand here, the integrity check will do that for us.
        return (0, 1);
    }

    function run(InterpreterState memory state, OperandV2 operand, Pointer stackTop) internal pure returns (Pointer) {
        bytes32[] memory constants = state.constants;
        // Skip index OOB check and rely on integrity check for that.
        assembly ("memory-safe") {
            let value := mload(add(constants, mul(add(and(operand, 0xFFFF), 1), 0x20)))
            stackTop := sub(stackTop, 0x20)
            mstore(stackTop, value)
        }
        return stackTop;
    }

    function referenceFn(InterpreterState memory state, OperandV2 operand, StackItem[] memory)
        internal
        pure
        returns (StackItem[] memory outputs)
    {
        uint256 index = uint256(OperandV2.unwrap(operand) & bytes32(uint256(0xFFFF)));
        outputs = new StackItem[](1);
        outputs[0] = StackItem.wrap(state.constants[index]);
    }
}
