// SPDX-License-Identifier: CAL
pragma solidity =0.8.25;

// import {OpTest, IntegrityCheckState, InterpreterState, Operand, stdError} from "test/abstract/OpTest.sol";
// import {LibWillOverflow} from "rain.math.fixedpoint/lib/LibWillOverflow.sol";
// import {LibOpScale18Dynamic} from "src/lib/op/math/LibOpScale18Dynamic.sol";
// import {LibOperand} from "test/lib/operand/LibOperand.sol";
// import {LibParseLiteral} from "src/lib/parse/literal/LibParseLiteral.sol";
// import {LibFixedPointDecimalScale, DECIMAL_MAX_SAFE_INT} from "rain.math.fixedpoint/lib/LibFixedPointDecimalScale.sol";

// contract LibOpScale18DynamicTest is OpTest {
//     /// Directly test the integrity logic of LibOpScale18Dynamic.
//     /// Inputs are always 2, outputs are always 1.
//     function testOpScale18DynamicIntegrity(IntegrityCheckState memory state, uint8 inputs, uint16 op) external pure {
//         inputs = uint8(bound(inputs, 2, 0x0F));
//         (uint256 calcInputs, uint256 calcOutputs) =
//             LibOpScale18Dynamic.integrity(state, LibOperand.build(inputs, 1, op));
//         assertEq(calcInputs, 2);
//         assertEq(calcOutputs, 1);
//     }

//     /// Directly test the runtime logic of LibOpScale18Dynamic.
//     function testOpScale18DynamicRun(uint256 scale, uint256 round, uint256 saturate, uint256 value) public {
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
//             LibWillOverflow.scale18WillOverflow(
//                 value, LibFixedPointDecimalScale.decimalOrIntToInt(scale, DECIMAL_MAX_SAFE_INT), flags
//             )
//         ) {
//             vm.expectRevert(stdError.arithmeticError);
//         }

//         opReferenceCheck(
//             state,
//             operand,
//             LibOpScale18Dynamic.referenceFn,
//             LibOpScale18Dynamic.integrity,
//             LibOpScale18Dynamic.run,
//             inputs
//         );
//     }

//     /// Test the eval of `scale-18-dynamic`.
//     function testOpScale18DynamicEval() external {
//         // Scale 0 value 0 round 0 saturate 0
//         checkHappy("_: scale-18-dynamic(0 0);", 0, "0 0 0 0");
//         // Scale 0 value 0 round 0 saturate 1
//         checkHappy("_: scale-18-dynamic<0 1>(0 0);", 0, "0 0 0 1");
//         // Scale 0 value 0 round 1 saturate 0
//         checkHappy("_: scale-18-dynamic<1 0>(0 0);", 0, "0 0 1 0");
//         // Scale 0 value 0 round 1 saturate 1
//         checkHappy("_: scale-18-dynamic<1 1>(0 0);", 0, "0 0 1 1");
//         // Scale 0 value 1 round 0 saturate 0
//         checkHappy("_: scale-18-dynamic(0 1e-18);", 1e18, "0 1 0 0");
//         // Scale 0 value 1 round 0 saturate 1
//         checkHappy("_: scale-18-dynamic<0 1>(0 1e-18);", 1e18, "0 1 0 1");
//         // Scale 0 value 1 round 1 saturate 0
//         checkHappy("_: scale-18-dynamic<1 0>(0 1e-18);", 1e18, "0 1 1 0");
//         // Scale 0 value 1 round 1 saturate 1
//         checkHappy("_: scale-18-dynamic<1 1>(0 1e-18);", 1e18, "0 1 1 1");
//         // Scale 1 value 0 round 0 saturate 0
//         checkHappy("_: scale-18-dynamic(1 0);", 0, "1 0 0 0");
//         // Scale 1 value 0 round 0 saturate 1
//         checkHappy("_: scale-18-dynamic<0 1>(1 0);", 0, "1 0 0 1");
//         // Scale 1 value 0 round 1 saturate 0
//         checkHappy("_: scale-18-dynamic<1 0>(1 0);", 0, "1 0 1 0");
//         // Scale 1 value 0 round 1 saturate 1
//         checkHappy("_: scale-18-dynamic<1 1>(1 0);", 0, "1 0 1 1");
//         // Scale 1 value 1 round 0 saturate 0
//         checkHappy("_: scale-18-dynamic(1 1e-18);", 1e17, "1 1 0 0");
//         // Scale 1 value 1 round 0 saturate 1
//         checkHappy("_: scale-18-dynamic<0 1>(1 1e-18);", 1e17, "1 1 0 1");
//         // Scale 1 value 1 round 1 saturate 0
//         checkHappy("_: scale-18-dynamic<1 0>(1 1e-18);", 1e17, "1 1 1 0");
//         // Scale 1 value 1 round 1 saturate 1
//         checkHappy("_: scale-18-dynamic<1 1>(1 1e-18);", 1e17, "1 1 1 1");
//         // Scale 18 value 1 round 0 saturate 0
//         checkHappy("_: scale-18-dynamic(18 1e-18);", 1, "18 1 0 0");
//         // Scale 18 value 1 round 0 saturate 1
//         checkHappy("_: scale-18-dynamic<0 1>(18 1e-18);", 1, "18 1 0 1");
//         // Scale 18 value 1 round 1 saturate 0
//         checkHappy("_: scale-18-dynamic<1 0>(18 1e-18);", 1, "18 1 1 0");
//         // Scale 18 value 1 round 1 saturate 1
//         checkHappy("_: scale-18-dynamic<1 1>(18 1e-18);", 1, "18 1 1 1");
//         // Scale 18 value 1e18 round 0 saturate 0
//         checkHappy("_: scale-18-dynamic(18 1);", 1e18, "18 1e18 0 0");
//         // Scale 18 value 1e18 round 0 saturate 1
//         checkHappy("_: scale-18-dynamic<0 1>(18 1);", 1e18, "18 1e18 0 1");
//         // Scale 18 value 1e18 round 1 saturate 0
//         checkHappy("_: scale-18-dynamic<1 0>(18 1);", 1e18, "18 1e18 1 0");
//         // Scale 18 value 1e18 round 1 saturate 1
//         checkHappy("_: scale-18-dynamic<1 1>(18 1);", 1e18, "18 1e18 1 1");
//         // Scale 19 value 1e18 round 0 saturate 0
//         checkHappy("_: scale-18-dynamic(19 1);", 1e17, "19 1e18 0 0");
//         // Scale 19 value 1e18 round 0 saturate 1
//         checkHappy("_: scale-18-dynamic<0 1>(19 1);", 1e17, "19 1e18 0 1");
//         // Scale 19 value 1e18 round 1 saturate 0
//         checkHappy("_: scale-18-dynamic<1 0>(19 1);", 1e17, "19 1e18 1 0");
//         // Scale 19 value 1e18 round 1 saturate 1
//         checkHappy("_: scale-18-dynamic<1 1>(19 1);", 1e17, "19 1e18 1 1");

//         // Test rounding down while scaling down.
//         checkHappy("_: scale-18-dynamic(19 1e-18);", 0, "19 1 0 0");
//         // Test rounding up while scaling down.
//         checkHappy("_: scale-18-dynamic<1>(19 1e-18);", 1, "19 1 1 0");
//         // Test saturating while scaling up.
//         checkHappy("_: scale-18-dynamic<0 1>(0 1e52);", type(uint256).max, "0 1e70 0 1");
//         // Test error while scaling up.
//         checkUnhappy("_: scale-18-dynamic(0 1e52);", stdError.arithmeticError);
//     }

//     /// Test the eval of `scale-18-dynamic` opcode parsed from a string.
//     /// Tests zero inputs.
//     function testOpScale18DynamicEvalZeroInputs() external {
//         checkBadInputs("_: scale-18-dynamic();", 0, 2, 0);
//     }

//     /// Test the eval of `scale-18-dynamic` opcode parsed from a string.
//     /// Tests one input.
//     function testOpScale18DynamicEvalOneInput() external {
//         checkBadInputs("_: scale-18-dynamic(5);", 1, 2, 1);
//         checkBadInputs("_: scale-18-dynamic(0);", 1, 2, 1);
//         checkBadInputs("_: scale-18-dynamic(1);", 1, 2, 1);
//         checkBadInputs("_: scale-18-dynamic(max-value());", 1, 2, 1);
//     }

//     /// Test the eval of `scale-18-dynamic` opcode parsed from a string.
//     /// Tests three inputs.
//     function testOpScale18DynamicEvalThreeInputs() external {
//         checkBadInputs("_: scale-18-dynamic(0 0 0);", 3, 2, 3);
//         checkBadInputs("_: scale-18-dynamic(0 0 1);", 3, 2, 3);
//         checkBadInputs("_: scale-18-dynamic(0 1 0);", 3, 2, 3);
//         checkBadInputs("_: scale-18-dynamic(0 1 1);", 3, 2, 3);
//         checkBadInputs("_: scale-18-dynamic(1 0 0);", 3, 2, 3);
//         checkBadInputs("_: scale-18-dynamic(1 0 1);", 3, 2, 3);
//         checkBadInputs("_: scale-18-dynamic(1 1 0);", 3, 2, 3);
//         checkBadInputs("_: scale-18-dynamic(1 1 1);", 3, 2, 3);
//     }

//     function testOpScale18DynamicZeroOutputs() external {
//         checkBadOutputs(": scale-18-dynamic(0 0);", 2, 1, 0);
//     }

//     function testOpScale18DynamicTwoOutputs() external {
//         checkBadOutputs("_ _: scale-18-dynamic(0 0);", 2, 1, 2);
//     }
// }
