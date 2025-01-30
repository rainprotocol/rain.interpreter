// SPDX-License-Identifier: CAL
pragma solidity ^0.8.18;

// import {InterpreterState} from "../../state/LibInterpreterState.sol";
// import {IntegrityCheckState} from "../../integrity/LibIntegrityCheckNP.sol";
// import {OperandV2} from "rain.interpreter.interface/interface/unstable/IInterpreterV4.sol";
// import {Pointer} from "rain.solmem/lib/LibPointer.sol";
// import {UD60x18, frac, ceil, floor} from "prb-math/UD60x18.sol";

// /// @title LibOpSnapToUnit
// /// @notice Opcode for the snap to unit of an decimal 18 fixed point number.
// library LibOpSnapToUnit {
//     function integrity(IntegrityCheckState memory, Operand) internal pure returns (uint256, uint256) {
//         // There must be two inputs and one output.
//         return (2, 1);
//     }

//     /// snap-to-unit
//     function run(InterpreterState memory, Operand, Pointer stackTop) internal pure returns (Pointer) {
//         unchecked {
//             uint256 threshold;
//             uint256 value;
//             assembly ("memory-safe") {
//                 threshold := mload(stackTop)
//                 stackTop := add(stackTop, 0x20)
//                 value := mload(stackTop)
//             }
//             uint256 valueFrac = UD60x18.unwrap(frac(UD60x18.wrap(value)));
//             if (valueFrac <= threshold) {
//                 value = UD60x18.unwrap(floor(UD60x18.wrap(value)));
//                 assembly ("memory-safe") {
//                     mstore(stackTop, value)
//                 }
//             }
//             // Frac cannot be more than 1e18, so we can safely subtract it from 1e18
//             // as unchecked.
//             else if ((1e18 - valueFrac) <= threshold) {
//                 value = UD60x18.unwrap(ceil(UD60x18.wrap(value)));
//                 assembly ("memory-safe") {
//                     mstore(stackTop, value)
//                 }
//             }
//             return stackTop;
//         }
//     }

//     /// Gas intensive reference implementation of snap-to-unit for testing.
//     function referenceFn(InterpreterState memory, Operand, uint256[] memory inputs)
//         internal
//         pure
//         returns (uint256[] memory)
//     {
//         uint256[] memory outputs = new uint256[](1);
//         uint256 threshold = inputs[0];
//         uint256 value = inputs[1];
//         uint256 valueFrac = UD60x18.unwrap(frac(UD60x18.wrap(value)));
//         if (valueFrac <= threshold) {
//             value = UD60x18.unwrap(floor(UD60x18.wrap(value)));
//             outputs[0] = value;
//         } else if ((1e18 - valueFrac) <= threshold) {
//             value = UD60x18.unwrap(ceil(UD60x18.wrap(value)));
//             outputs[0] = value;
//         } else {
//             outputs[0] = value;
//         }
//         return outputs;
//     }
// }
