// SPDX-License-Identifier: CAL
pragma solidity ^0.8.18;

// import {OperandV2} from "rain.interpreter.interface/interface/unstable/IInterpreterV4.sol";
// import {Pointer} from "rain.solmem/lib/LibPointer.sol";
// import {IntegrityCheckState} from "../../integrity/LibIntegrityCheckNP.sol";
// import {InterpreterState} from "../../state/LibInterpreterState.sol";
// import {SaturatingMath} from "rain.math.saturating/SaturatingMath.sol";

// /// @title LibOpSub
// /// @notice Opcode to subtract N integers.
// library LibOpSub {
//     function integrity(IntegrityCheckState memory, Operand operand) internal pure returns (uint256, uint256) {
//         // There must be at least two inputs.
//         uint256 inputs = (Operand.unwrap(operand) >> 0x10) & 0x0F;
//         inputs = inputs > 1 ? inputs : 2;
//         return (inputs, 1);
//     }

//     function sub(uint256 a, uint256 b) internal pure returns (uint256) {
//         return a - b;
//     }

//     /// sub
//     /// Subtraction with implied overflow checks from the Solidity 0.8.x compiler.
//     function run(InterpreterState memory, Operand operand, Pointer stackTop) internal pure returns (Pointer) {
//         uint256 a;
//         uint256 b;
//         uint256 saturate;
//         assembly ("memory-safe") {
//             a := mload(stackTop)
//             b := mload(add(stackTop, 0x20))
//             stackTop := add(stackTop, 0x40)
//             saturate := and(operand, 1)
//         }
//         function (uint256, uint256) internal pure returns (uint256) f =
//             saturate > 0 ? SaturatingMath.saturatingSub : sub;
//         a = f(a, b);

//         {
//             uint256 inputs = (Operand.unwrap(operand) >> 0x10) & 0x0F;
//             uint256 i = 2;
//             while (i < inputs) {
//                 assembly ("memory-safe") {
//                     b := mload(stackTop)
//                     stackTop := add(stackTop, 0x20)
//                 }
//                 a = f(a, b);
//                 unchecked {
//                     i++;
//                 }
//             }
//         }

//         assembly ("memory-safe") {
//             stackTop := sub(stackTop, 0x20)
//             mstore(stackTop, a)
//         }
//         return stackTop;
//     }

//     /// Gas intensive reference implementation of subtraction for testing.
//     function referenceFn(InterpreterState memory, Operand, uint256[] memory inputs)
//         internal
//         pure
//         returns (uint256[] memory outputs)
//     {
//         // Unchecked so that when we assert that an overflow error is thrown, we
//         // see the revert from the real function and not the reference function.
//         unchecked {
//             uint256 acc = inputs[0];
//             for (uint256 i = 1; i < inputs.length; i++) {
//                 acc -= inputs[i];
//             }
//             outputs = new uint256[](1);
//             outputs[0] = acc;
//         }
//     }
// }
