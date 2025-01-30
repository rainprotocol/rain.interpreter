// SPDX-License-Identifier: CAL
pragma solidity ^0.8.18;

// import {MASK_2BIT} from "sol.lib.binmaskflag/Binary.sol";
// import {OperandV2} from "rain.interpreter.interface/interface/unstable/IInterpreterV4.sol";
// import {Pointer} from "rain.solmem/lib/LibPointer.sol";
// import {IntegrityCheckState} from "../../integrity/LibIntegrityCheckNP.sol";
// import {InterpreterState} from "../../state/LibInterpreterState.sol";
// import {LibParseLiteral} from "../../parse/literal/LibParseLiteral.sol";

// /// @title LibOpScale18Dynamic
// /// @notice Opcode for scaling a number to 18 decimal fixed point based on
// /// runtime scale input.
// library LibOpScale18Dynamic {
//     using LibFixedPointDecimalScale for uint256;

//     function integrity(IntegrityCheckState memory, Operand) internal pure returns (uint256, uint256) {
//         return (2, 1);
//     }

//     /// scale-18-dynamic
//     /// 18 decimal fixed point scaling from runtime value.
//     function run(InterpreterState memory, Operand operand, Pointer stackTop) internal pure returns (Pointer) {
//         uint256 a;
//         uint256 scale;
//         assembly ("memory-safe") {
//             scale := mload(stackTop)
//             stackTop := add(stackTop, 0x20)
//             a := mload(stackTop)
//         }
//         // There's no upper bound because we might be saturating all the way to
//         // infinity. `scale18` will handle catching such things.
//         scale = LibFixedPointDecimalScale.decimalOrIntToInt(scale, DECIMAL_MAX_SAFE_INT);
//         a = a.scale18(scale, Operand.unwrap(operand));
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
//         outputs[0] = inputs[1].scale18(
//             LibFixedPointDecimalScale.decimalOrIntToInt(inputs[0], DECIMAL_MAX_SAFE_INT),
//             Operand.unwrap(operand) & MASK_2BIT
//         );
//     }
// }
