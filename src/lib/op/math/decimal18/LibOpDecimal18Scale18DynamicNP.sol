// SPDX-License-Identifier: CAL
pragma solidity ^0.8.18;

import {FixedPointDecimalScale} from "rain.math.fixedpoint/FixedPointDecimalScale.sol";
import "sol.lib.binmaskflag/Binary.sol";

import "../../../state/LibInterpreterStateNP.sol";
import "../../../integrity/LibIntegrityCheckNP.sol";

/// @title LibOpDecimal18Scale18DynamicNP
/// @notice Opcode for scaling a number to 18 decimal fixed point based on
/// runtime scale input.
library LibOpDecimal18Scale18DynamicNP {
    using FixedPointDecimalScale for uint256;

    function integrity(
        IntegrityCheckStateNP memory,
        Operand
    ) internal pure returns (uint256, uint256) {
        return (2, 1);
    }

    /// decimal18-scale18-dynamic
    /// 18 decimal fixed point scaling from runtime value.
    function run(InterpreterStateNP memory, Operand operand, Pointer stackTop) internal pure returns (Pointer) {
        uint256 a;
        uint256 scale;
        assembly ("memory-safe") {
            scale := mload(stackTop)
            stackTop := add(stackTop, 0x20)
            a := mload(stackTop)
        }
        a = a.scale18(scale, Operand.unwrap(operand) & MASK_2BIT);
        assembly ("memory-safe") {
            mstore(stackTop, a)
        }
        return stackTop;
    }

    function referenceFn(InterpreterStateNP memory, Operand operand, uint256[] memory inputs)
        internal
        pure
        returns (uint256[] memory outputs)
    {
        outputs = new uint256[](1);
        outputs[0] = inputs[1].scale18(inputs[0], Operand.unwrap(operand) & MASK_2BIT);
    }
}
