// SPDX-License-Identifier: CAL
pragma solidity ^0.8.18;

// import {OperandV2} from "rain.interpreter.interface/interface/unstable/IInterpreterV4.sol";
// import {InterpreterState} from "../../state/LibInterpreterState.sol";
// import {IntegrityCheckState} from "../../integrity/LibIntegrityCheckNP.sol";
// import {Pointer} from "rain.solmem/lib/LibPointer.sol";

// /// @title LibOpScale18
// /// @notice Opcode for scaling a number to 18 decimal fixed point.
// library LibOpScale18 {
//     using LibFixedPointDecimalScale for uint256;

//     function integrity(IntegrityCheckState memory, Operand) internal pure returns (uint256, uint256) {
//         return (1, 1);
//     }

//     /// scale-18
//     /// 18 decimal fixed point scaling.
//     function run(InterpreterState memory, Operand operand, Pointer stackTop) internal pure returns (Pointer) {
//         uint256 a;
//         assembly ("memory-safe") {
//             a := mload(stackTop)
//         }
//         a = a.scale18(Operand.unwrap(operand) & 0xFF, Operand.unwrap(operand) >> 8);
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
//         outputs[0] = inputs[0].scale18(Operand.unwrap(operand) & 0xFF, Operand.unwrap(operand) >> 8);
//     }
// }
