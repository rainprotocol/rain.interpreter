// SPDX-License-Identifier: CAL
pragma solidity ^0.8.18;

// import {UD60x18, avg} from "prb-math/UD60x18.sol";
// import {OperandV2} from "rain.interpreter.interface/interface/unstable/IInterpreterV4.sol";
// import {Pointer} from "rain.solmem/lib/LibPointer.sol";
// import {InterpreterState} from "../../state/LibInterpreterState.sol";
// import {IntegrityCheckState} from "../../integrity/LibIntegrityCheckNP.sol";

// /// @title LibOpAvg
// /// @notice Opcode for the average of two decimal 18 fixed point numbers.
// library LibOpAvg {
//     function integrity(IntegrityCheckState memory, Operand) internal pure returns (uint256, uint256) {
//         // There must be two inputs and one output.
//         return (2, 1);
//     }

//     /// avg
//     /// 18 decimal fixed point average of two numbers.
//     function run(InterpreterState memory, Operand, Pointer stackTop) internal pure returns (Pointer) {
//         uint256 a;
//         uint256 b;
//         assembly ("memory-safe") {
//             a := mload(stackTop)
//             stackTop := add(stackTop, 0x20)
//             b := mload(stackTop)
//         }
//         a = UD60x18.unwrap(avg(UD60x18.wrap(a), UD60x18.wrap(b)));

//         assembly ("memory-safe") {
//             mstore(stackTop, a)
//         }
//         return stackTop;
//     }

//     /// Gas intensive reference implementation of avg for testing.
//     function referenceFn(InterpreterState memory, Operand, uint256[] memory inputs)
//         internal
//         pure
//         returns (uint256[] memory)
//     {
//         uint256[] memory outputs = new uint256[](1);
//         outputs[0] = UD60x18.unwrap(avg(UD60x18.wrap(inputs[0]), UD60x18.wrap(inputs[1])));
//         return outputs;
//     }
// }
