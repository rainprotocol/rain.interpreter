// SPDX-License-Identifier: CAL
pragma solidity ^0.8.18;

import {OperandV2} from "rain.interpreter.interface/interface/unstable/IInterpreterV4.sol";
import {Pointer} from "rain.solmem/lib/LibPointer.sol";
import {InterpreterState} from "../../state/LibInterpreterState.sol";
import {IntegrityCheckState} from "../../integrity/LibIntegrityCheckNP.sol";

/// @title LibOpGreaterThanOrEqualToNP
/// @notice Opcode to return 1 if the first item on the stack is greater than or
/// equal to the second item on the stack, else 0.
library LibOpGreaterThanOrEqualToNP {
    function integrity(IntegrityCheckState memory, OperandV2) internal pure returns (uint256, uint256) {
        return (2, 1);
    }

    /// GTE
    /// GTE is 1 if the first item is greater than or equal to the second item,
    /// else 0.
    function run(InterpreterState memory, OperandV2, Pointer stackTop) internal pure returns (Pointer) {
        assembly ("memory-safe") {
            let a := mload(stackTop)
            stackTop := add(stackTop, 0x20)
            mstore(stackTop, iszero(lt(a, mload(stackTop))))
        }
        return stackTop;
    }

    /// Gas intensive reference implementation of GTE for testing.
    function referenceFn(InterpreterState memory, OperandV2, uint256[] memory inputs)
        internal
        pure
        returns (uint256[] memory outputs)
    {
        outputs = new uint256[](1);
        outputs[0] = inputs[0] >= inputs[1] ? 1 : 0;
    }
}
