// SPDX-License-Identifier: CAL
pragma solidity ^0.8.18;

import {Pointer} from "rain.solmem/lib/LibPointer.sol";
import {OperandV2} from "rain.interpreter.interface/interface/unstable/IInterpreterV4.sol";
import {InterpreterState} from "../../state/LibInterpreterState.sol";
import {IntegrityCheckState} from "../../integrity/LibIntegrityCheckNP.sol";
import {LibIntOrAString, IntOrAString} from "rain.intorastring/lib/LibIntOrAString.sol";

/// @title LibOpEnsureNP
/// @notice Opcode to revert if the condition is zero.
library LibOpEnsureNP {
    using LibIntOrAString for IntOrAString;

    function integrity(IntegrityCheckState memory, OperandV2) internal pure returns (uint256, uint256) {
        // There must be exactly 2 inputs.
        return (2, 0);
    }

    /// `ensure`
    /// If the condition is zero, the expression will revert with the given
    /// string.
    /// All conditions are eagerly evaluated and there are no outputs.
    function run(InterpreterState memory, OperandV2, Pointer stackTop) internal pure returns (Pointer) {
        uint256 condition;
        IntOrAString reason;
        assembly ("memory-safe") {
            condition := mload(stackTop)
            reason := mload(add(stackTop, 0x20))
            stackTop := add(stackTop, 0x40)
        }

        require(condition > 0, reason.toString());
        return stackTop;
    }

    /// Gas intensive reference implementation of `ensure` for testing.
    function referenceFn(InterpreterState memory, OperandV2, uint256[] memory inputs)
        internal
        pure
        returns (uint256[] memory outputs)
    {
        require(inputs[0] > 0, IntOrAString.wrap(inputs[1]).toString());
        outputs = new uint256[](0);
    }
}
