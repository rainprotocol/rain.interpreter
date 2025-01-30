// SPDX-License-Identifier: CAL
pragma solidity ^0.8.18;

import {Pointer} from "rain.solmem/lib/LibPointer.sol";
import {OperandV2, StackItem} from "rain.interpreter.interface/interface/unstable/IInterpreterV4.sol";
import {InterpreterState} from "../../state/LibInterpreterState.sol";
import {IntegrityCheckState} from "../../integrity/LibIntegrityCheckNP.sol";

library LibOpContextNP {
    function integrity(IntegrityCheckState memory, OperandV2) internal pure returns (uint256, uint256) {
        // Context doesn't have any inputs. The operand defines the reads.
        // Unfortunately we don't know the shape of the context that we will
        // receive at runtime, so we can't check the reads at integrity time.
        return (0, 1);
    }

    function run(InterpreterState memory state, OperandV2 operand, Pointer stackTop) internal pure returns (Pointer) {
        uint256 i = uint256(OperandV2.unwrap(operand) & bytes32(uint256(0xFF)));
        uint256 j = uint256((OperandV2.unwrap(operand) >> 8) & bytes32(uint256(0xFF)));
        // We want these indexes to be checked at runtime for OOB accesses
        // because we don't know the shape of the context at compile time.
        // Solidity handles that for us as long as we don't invoke yul for the
        // reads.
        if (Pointer.unwrap(stackTop) < 0x20) {
            revert("stack underflow");
        }
        bytes32 v = state.context[i][j];
        assembly ("memory-safe") {
            stackTop := sub(stackTop, 0x20)
            mstore(stackTop, v)
        }
        return stackTop;
    }

    function referenceFn(InterpreterState memory state, OperandV2 operand, StackItem[] memory)
        internal
        pure
        returns (StackItem[] memory outputs)
    {
        uint256 i = uint256(OperandV2.unwrap(operand) & bytes32(uint256(0xFF)));
        uint256 j = uint256((OperandV2.unwrap(operand) >> 8) & bytes32(uint256(0xFF)));
        // We want these indexes to be checked at runtime for OOB accesses
        // because we don't know the shape of the context at compile time.
        // Solidity handles that for us as long as we don't invoke yul for the
        // reads.
        bytes32 v = state.context[i][j];
        outputs = new StackItem[](1);
        outputs[0] = StackItem.wrap(v);
        return outputs;
    }
}
