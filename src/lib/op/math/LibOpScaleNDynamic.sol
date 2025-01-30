// SPDX-License-Identifier: CAL
pragma solidity ^0.8.18;

// import {OperandV2} from "rain.interpreter.interface/interface/unstable/IInterpreterV4.sol";
// import {IntegrityCheckState} from "../../integrity/LibIntegrityCheckNP.sol";
// import {InterpreterState} from "../../state/LibInterpreterState.sol";
// import {Pointer} from "rain.solmem/lib/LibPointer.sol";
// import {MASK_2BIT} from "sol.lib.binmaskflag/Binary.sol";
// import {LibParseLiteral} from "../../parse/literal/LibParseLiteral.sol";

// /// @title LibOpScaleNDynamic
// /// @notice Opcode for scaling a number from 18 decimal fixed point based on
// /// runtime scale input.
// library LibOpScaleNDynamic {
//     using LibFixedPointDecimalScale for uint256;

//     function integrity(IntegrityCheckState memory, Operand) internal pure returns (uint256, uint256) {
//         return (2, 1);
//     }

//     /// scaleN-dynamic
//     /// 18 decimal fixed point scaling from runtime value.
//     function run(InterpreterState memory, Operand operand, Pointer stackTop) internal pure returns (Pointer) {
//         uint256 a;
//         uint256 scale;
//         assembly ("memory-safe") {
//             scale := mload(stackTop)
//             stackTop := add(stackTop, 0x20)
//             a := mload(stackTop)
//         }
//         a = a.scaleN(
//             LibFixedPointDecimalScale.decimalOrIntToInt(scale, DECIMAL_MAX_SAFE_INT),
//             Operand.unwrap(operand) & MASK_2BIT
//         );
//         assembly ("memory-safe") {
//             mstore(stackTop, a)
//         }
//         return stackTop;
//     }

//     function referenceFn(InterpreterState memory, Operand operand, uint256[] memory inputs)
//         internal
//         pure
//         returns (uint256[] memory outputs)
//     {
//         outputs = new uint256[](1);
//         outputs[0] = inputs[1].scaleN(
//             LibFixedPointDecimalScale.decimalOrIntToInt(inputs[0], DECIMAL_MAX_SAFE_INT),
//             Operand.unwrap(operand) & MASK_2BIT
//         );
//     }
// }
