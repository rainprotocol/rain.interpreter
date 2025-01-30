// SPDX-License-Identifier: CAL
pragma solidity ^0.8.18;

// import {Pointer} from "rain.solmem/lib/LibPointer.sol";
// import {OperandV2} from "rain.interpreter.interface/interface/unstable/IInterpreterV4.sol";
// import {InterpreterState} from "../../state/LibInterpreterState.sol";
// import {IntegrityCheckState} from "../../integrity/LibIntegrityCheckNP.sol";

// /// @title LibOpE
// /// Stacks the mathematical constant e.
// library LibOpE {
//     function integrity(IntegrityCheckState memory, Operand) internal pure returns (uint256, uint256) {
//         return (0, 1);
//     }

//     function run(InterpreterState memory, Operand, Pointer stackTop) internal pure returns (Pointer) {
//         uint256 e = FIXED_POINT_E;
//         assembly ("memory-safe") {
//             stackTop := sub(stackTop, 0x20)
//             mstore(stackTop, e)
//         }
//         return stackTop;
//     }

//     function referenceFn(InterpreterState memory, Operand, uint256[] memory)
//         internal
//         pure
//         returns (uint256[] memory)
//     {
//         uint256[] memory outputs = new uint256[](1);
//         outputs[0] = FIXED_POINT_E;
//         return outputs;
//     }
// }
