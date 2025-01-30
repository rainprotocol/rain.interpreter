// SPDX-License-Identifier: CAL
pragma solidity ^0.8.18;

// /// Used for reference implementation so that we have two independent
// /// upstreams to compare against.
// import {Math as OZMath} from "openzeppelin-contracts/contracts/utils/math/Math.sol";
// import {LibWillOverflow} from "rain.math.fixedpoint/lib/LibWillOverflow.sol";
// import {UD60x18, div} from "prb-math/UD60x18.sol";
// import {OperandV2} from "rain.interpreter.interface/interface/unstable/IInterpreterV4.sol";
// import {Pointer} from "rain.solmem/lib/LibPointer.sol";
// import {InterpreterState} from "../../state/LibInterpreterState.sol";
// import {IntegrityCheckState} from "../../integrity/LibIntegrityCheckNP.sol";

// /// @title LibOpDiv
// /// @notice Opcode to div N 18 decimal fixed point values. Errors on overflow.
// library LibOpDiv {
//     function integrity(IntegrityCheckState memory, Operand operand) internal pure returns (uint256, uint256) {
//         // There must be at least two inputs.
//         uint256 inputs = (Operand.unwrap(operand) >> 0x10) & 0x0F;
//         inputs = inputs > 1 ? inputs : 2;
//         return (inputs, 1);
//     }

//     /// div
//     /// 18 decimal fixed point division with implied overflow checks from PRB
//     /// Math.
//     function run(InterpreterState memory, Operand operand, Pointer stackTop) internal pure returns (Pointer) {
//         uint256 a;
//         uint256 b;
//         assembly ("memory-safe") {
//             a := mload(stackTop)
//             b := mload(add(stackTop, 0x20))
//             stackTop := add(stackTop, 0x40)
//         }
//         a = UD60x18.unwrap(div(UD60x18.wrap(a), UD60x18.wrap(b)));

//         {
//             uint256 inputs = (Operand.unwrap(operand) >> 0x10) & 0x0F;
//             uint256 i = 2;
//             while (i < inputs) {
//                 assembly ("memory-safe") {
//                     b := mload(stackTop)
//                     stackTop := add(stackTop, 0x20)
//                 }
//                 a = UD60x18.unwrap(div(UD60x18.wrap(a), UD60x18.wrap(b)));
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

//     /// Gas intensive reference implementation of division for testing.
//     function referenceFn(InterpreterState memory, Operand, uint256[] memory inputs)
//         internal
//         pure
//         returns (uint256[] memory outputs)
//     {
//         // Unchecked so that when we assert that an overflow error is thrown, we
//         // see the revert from the real function and not the reference function.
//         unchecked {
//             uint256 a = inputs[0];
//             for (uint256 i = 1; i < inputs.length; i++) {
//                 uint256 b = inputs[i];
//                 // Just bail out with a = some sentinel value if we're going to
//                 // overflow or divide by zero. This gives the real implementation
//                 // space to throw its own error that the test harness is expecting.
//                 // We don't want the real implementation to fail to throw the
//                 // error and also produce the same result, so a needs to have
//                 // some collision resistant value.
//                 if (b == 0 || LibWillOverflow.mulDivWillOverflow(a, 1e18, b)) {
//                     a = uint256(keccak256(abi.encodePacked("overflow sentinel")));
//                     break;
//                 }
//                 a = OZMath.mulDiv(a, 1e18, b);
//             }
//             outputs = new uint256[](1);
//             outputs[0] = a;
//         }
//     }
// }
