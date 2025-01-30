// SPDX-License-Identifier: CAL
pragma solidity ^0.8.18;

// import {UD60x18, mul, pow} from "prb-math/UD60x18.sol";
// import {OperandV2} from "rain.interpreter.interface/interface/unstable/IInterpreterV4.sol";
// import {Pointer} from "rain.solmem/lib/LibPointer.sol";
// import {InterpreterState} from "../../../state/LibInterpreterState.sol";
// import {IntegrityCheckState} from "../../../integrity/LibIntegrityCheckNP.sol";

// /// @title LibOpExponentialGrowth
// /// @notice Exponential growth is base(1 + rate)^t where base is the initial
// /// value, rate is the growth rate, and t is time.
// library LibOpExponentialGrowth {
//     function integrity(IntegrityCheckState memory, Operand) internal pure returns (uint256, uint256) {
//         // There must be three inputs and one output.
//         return (3, 1);
//     }

//     /// exponential-growth
//     function run(InterpreterState memory, Operand, Pointer stackTop) internal pure returns (Pointer) {
//         uint256 base;
//         uint256 rate;
//         uint256 t;
//         assembly ("memory-safe") {
//             base := mload(stackTop)
//             rate := mload(add(stackTop, 0x20))
//             stackTop := add(stackTop, 0x40)
//             t := mload(stackTop)
//         }
//         base = UD60x18.unwrap(mul(UD60x18.wrap(base), pow(UD60x18.wrap(1e18 + rate), UD60x18.wrap(t))));

//         assembly ("memory-safe") {
//             mstore(stackTop, base)
//         }
//         return stackTop;
//     }

//     /// Gas intensive reference implementation for testing.
//     function referenceFn(InterpreterState memory, Operand, uint256[] memory inputs)
//         internal
//         pure
//         returns (uint256[] memory)
//     {
//         uint256[] memory outputs = new uint256[](1);
//         outputs[0] =
//             UD60x18.unwrap(mul(UD60x18.wrap(inputs[0]), pow(UD60x18.wrap(1e18 + inputs[1]), UD60x18.wrap(inputs[2]))));
//         return outputs;
//     }
// }
