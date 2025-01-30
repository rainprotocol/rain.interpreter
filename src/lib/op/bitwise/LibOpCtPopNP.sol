// SPDX-License-Identifier: CAL
pragma solidity ^0.8.18;

import {Pointer} from "rain.solmem/lib/LibPointer.sol";
import {OperandV2} from "rain.interpreter.interface/interface/unstable/IInterpreterV4.sol";
import {InterpreterState} from "../../state/LibInterpreterState.sol";
import {IntegrityCheckState} from "../../integrity/LibIntegrityCheckNP.sol";
import {LibCtPop} from "rain.math.binary/lib/LibCtPop.sol";

/// @title LibOpCtPopNP
/// @notice An opcode that counts the number of bits set in a word. This is
/// called ctpop because that's the name of this kind of thing elsewhere, but
/// the more common name is "population count" or "Hamming weight". The word
/// in the standard ops lib is called `bitwise-count-ones`, which follows the
/// Rust naming convention.
/// There is no evm opcode for this, so we have to implement it ourselves.
library LibOpCtPopNP {
    /// ctpop unconditionally takes one value and returns one value.
    function integrity(IntegrityCheckState memory, OperandV2) internal pure returns (uint256, uint256) {
        return (1, 1);
    }

    /// Output is the number of bits set to one in the input. Thin wrapper around
    /// `LibCtPop.ctpop`.
    function run(InterpreterState memory, OperandV2, Pointer stackTop) internal pure returns (Pointer) {
        uint256 value;
        assembly ("memory-safe") {
            value := mload(stackTop)
        }
        unchecked {
            value = LibCtPop.ctpop(value);
        }
        assembly ("memory-safe") {
            mstore(stackTop, value)
        }
        return stackTop;
    }

    /// The reference implementation of ctpop.
    function referenceFn(InterpreterState memory, OperandV2, uint256[] memory inputs)
        internal
        pure
        returns (uint256[] memory)
    {
        inputs[0] = LibCtPop.ctpopSlow(inputs[0]);
        return inputs;
    }
}
