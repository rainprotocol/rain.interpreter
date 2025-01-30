// SPDX-License-Identifier: CAL
pragma solidity =0.8.25;

// import {OpTest, IntegrityCheckState, InterpreterState, Operand, stdError} from "test/abstract/OpTest.sol";
// import {LibWillOverflow} from "rain.math.fixedpoint/lib/LibWillOverflow.sol";
// import {LibOpScaleNDynamic} from "src/lib/op/math/LibOpScaleNDynamic.sol";
// import {LibOperand} from "test/lib/operand/LibOperand.sol";
// import {LibParseLiteral} from "src/lib/parse/literal/LibParseLiteral.sol";
// import {LibFixedPointDecimalScale, DECIMAL_MAX_SAFE_INT} from "rain.math.fixedpoint/lib/LibFixedPointDecimalScale.sol";

// contract LibOpScaleNDynamicTest is OpTest {
//     /// Directly test the integrity logic of LibOpScaleNDynamic.
//     /// Inputs are always 2, outputs are always 1.
//     function testOpScaleNDynamicIntegrity(IntegrityCheckState memory state, uint8 inputs, uint16 op) external pure {
//         inputs = uint8(bound(inputs, 2, 0x0F));
//         (uint256 calcInputs, uint256 calcOutputs) = LibOpScaleNDynamic.integrity(state, LibOperand.build(inputs, 1, op));
//         assertEq(calcInputs, 2);
//         assertEq(calcOutputs, 1);
//     }

//     /// Directly test the runtime logic of LibOpScaleNDynamic.
//     function testOpScaleNDynamicRun(uint256 scale, uint256 round, uint256 saturate, uint256 value) public {
//         scale = bound(scale, 0, DECIMAL_MAX_SAFE_INT * 1e18);
//         round = bound(round, 0, 1);
//         saturate = bound(saturate, 0, 1);
//         uint256 flags = round | (saturate << 1);
//         InterpreterState memory state = opTestDefaultInterpreterState();

//         if (scale >= 1e18) {
//             scale = scale - (scale % 1e18);
//         }

//         Operand operand = LibOperand.build(2, 1, uint16(flags));
//         uint256[] memory inputs = new uint256[](2);
//         inputs[0] = scale;
//         inputs[1] = value;

//         if (
//             LibWillOverflow.scaleNWillOverflow(
//                 value, LibFixedPointDecimalScale.decimalOrIntToInt(scale, DECIMAL_MAX_SAFE_INT), flags
//             )
//         ) {
//             vm.expectRevert(stdError.arithmeticError);
//         }

//         opReferenceCheck(
//             state, operand, LibOpScaleNDynamic.referenceFn, LibOpScaleNDynamic.integrity, LibOpScaleNDynamic.run, inputs
//         );
//     }

//     /// Test the eval of `scale-n-dynamic`.
//     function testOpScaleNDynamicEval() external {
//         // Scale 0 value 0 round 0 saturate 0
//         checkHappy("_: scale-n-dynamic(0 0);", 0, "0 0 0 0");
//         // Scale 0 value 0 round 0 saturate 1
//         checkHappy("_: scale-n-dynamic<0 1>(0 0);", 0, "0 0 0 1");
//         // Scale 0 value 0 round 1 saturate 0
//         checkHappy("_: scale-n-dynamic<1 0>(0 0);", 0, "0 0 1 0");
//         // Scale 0 value 0 round 1 saturate 1
//         checkHappy("_: scale-n-dynamic<1 1>(0 0);", 0, "0 0 1 1");
//         // Scale 0 value 1 round 0 saturate 0
//         checkHappy("_: scale-n-dynamic(0 1e-18);", 0, "0 1 0 0");
//         // Scale 0 value 1 round 0 saturate 1
//         checkHappy("_: scale-n-dynamic<0 1>(0 1e-18);", 0, "0 1 0 1");
//         // Scale 0 value 1 round 1 saturate 0
//         checkHappy("_: scale-n-dynamic<1 0>(0 1e-18);", 1, "0 1 1 0");
//         // Scale 0 value 1 round 1 saturate 1
//         checkHappy("_: scale-n-dynamic<1 1>(0 1e-18);", 1, "0 1 1 1");
//         // Scale 1 value 0 round 0 saturate 0
//         checkHappy("_: scale-n-dynamic(1 0);", 0, "1 0 0 0");
//         // Scale 1 value 0 round 0 saturate 1
//         checkHappy("_: scale-n-dynamic<0 1>(1 0);", 0, "1 0 0 1");
//         // Scale 1 value 0 round 1 saturate 0
//         checkHappy("_: scale-n-dynamic<1 0>(1 0);", 0, "1 0 1 0");
//         // Scale 1 value 0 round 1 saturate 1
//         checkHappy("_: scale-n-dynamic<1 1>(1 0);", 0, "1 0 1 1");
//         // Scale 1 value 1 round 0 saturate 0
//         checkHappy("_: scale-n-dynamic(1 1e-18);", 0, "1 1 0 0");
//         // Scale 1 value 1 round 0 saturate 1
//         checkHappy("_: scale-n-dynamic<0 1>(1 1e-18);", 0, "1 1 0 1");
//         // Scale 1 value 1 round 1 saturate 0
//         checkHappy("_: scale-n-dynamic<1 0>(1 1e-18);", 1, "1 1 1 0");
//         // Scale 1 value 1 round 1 saturate 1
//         checkHappy("_: scale-n-dynamic<1 1>(1 1e-18);", 1, "1 1 1 1");
//         // Scale 18 value 1 round 0 saturate 0
//         checkHappy("_: scale-n-dynamic(18 1e-18);", 1, "18 1 0 0");
//         // Scale 18 value 1 round 0 saturate 1
//         checkHappy("_: scale-n-dynamic<0 1>(18 1e-18);", 1, "18 1 0 1");
//         // Scale 18 value 1 round 1 saturate 0
//         checkHappy("_: scale-n-dynamic<1 0>(18 1e-18);", 1, "18 1 1 0");
//         // Scale 18 value 1 round 1 saturate 1
//         checkHappy("_: scale-n-dynamic<1 1>(18 1e-18);", 1, "18 1 1 1");
//         // Scale 18 value 1e18 round 0 saturate 0
//         checkHappy("_: scale-n-dynamic(18 1);", 1e18, "18 1e18 0 0");
//         // Scale 18 value 1e18 round 0 saturate 1
//         checkHappy("_: scale-n-dynamic<0 1>(18 1);", 1e18, "18 1e18 0 1");
//         // Scale 18 value 1e18 round 1 saturate 0
//         checkHappy("_: scale-n-dynamic<1 0>(18 1);", 1e18, "18 1e18 1 0");
//         // Scale 18 value 1e18 round 1 saturate 1
//         checkHappy("_: scale-n-dynamic<1 1>(18 1);", 1e18, "18 1e18 1 1");
//         // Scale 19 value 1e18 round 0 saturate 0
//         checkHappy("_: scale-n-dynamic(19 1);", 1e19, "19 1e18 0 0");
//         // Scale 19 value 1e18 round 0 saturate 1
//         checkHappy("_: scale-n-dynamic<0 1>(19 1);", 1e19, "19 1e18 0 1");
//         // Scale 19 value 1e18 round 1 saturate 0
//         checkHappy("_: scale-n-dynamic<1 0>(19 1);", 1e19, "19 1e18 1 0");
//         // Scale 19 value 1e18 round 1 saturate 1
//         checkHappy("_: scale-n-dynamic<1 1>(19 1);", 1e19, "19 1e18 1 1");

//         // Test rounding down while scaling down.
//         checkHappy("_: scale-n-dynamic(17 1e-18);", 0, "19 1 0 0");
//         // Test rounding up while scaling down.
//         checkHappy("_: scale-n-dynamic<1>(17 1e-18);", 1, "19 1 1 0");
//         // Test saturating while scaling up.
//         checkHappy("_: scale-n-dynamic<0 1>(36 1e52);", type(uint256).max, "0 1e70 0 1");
//         // Test error while scaling up.
//         checkUnhappy("_: scale-n-dynamic(36 1e52);", stdError.arithmeticError);
//     }

//     /// Test the eval of `scale-n-dynamic` opcode parsed from a string.
//     /// Tests zero inputs.
//     function testOpScaleNDynamicEvalZeroInputs() external {
//         checkBadInputs("_: scale-n-dynamic();", 0, 2, 0);
//     }

//     /// Test the eval of `scale-n-dynamic` opcode parsed from a string.
//     /// Tests one input.
//     function testOpScaleNDynamicEvalOneInput() external {
//         checkBadInputs("_: scale-n-dynamic(5);", 1, 2, 1);
//         checkBadInputs("_: scale-n-dynamic(0);", 1, 2, 1);
//         checkBadInputs("_: scale-n-dynamic(1);", 1, 2, 1);
//         checkBadInputs("_: scale-n-dynamic(max-value());", 1, 2, 1);
//     }

//     /// Test the eval of `scale-n-dynamic` opcode parsed from a string.
//     /// Tests three inputs.
//     function testOpScaleNDynamicEvalThreeInputs() external {
//         checkBadInputs("_: scale-n-dynamic(0 0 0);", 3, 2, 3);
//         checkBadInputs("_: scale-n-dynamic(0 0 1);", 3, 2, 3);
//         checkBadInputs("_: scale-n-dynamic(0 1 0);", 3, 2, 3);
//         checkBadInputs("_: scale-n-dynamic(0 1 1);", 3, 2, 3);
//         checkBadInputs("_: scale-n-dynamic(1 0 0);", 3, 2, 3);
//         checkBadInputs("_: scale-n-dynamic(1 0 1);", 3, 2, 3);
//         checkBadInputs("_: scale-n-dynamic(1 1 0);", 3, 2, 3);
//         checkBadInputs("_: scale-n-dynamic(1 1 1);", 3, 2, 3);
//     }

//     function testOpScaleNDynamicZeroOutputs() external {
//         checkBadOutputs(": scale-n-dynamic(0 0);", 2, 1, 0);
//     }

//     function testOpScaleNDynamicTwoOutputs() external {
//         checkBadOutputs("_ _: scale-n-dynamic(0 0);", 2, 1, 2);
//     }
// }
