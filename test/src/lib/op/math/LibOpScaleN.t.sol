// SPDX-License-Identifier: CAL
pragma solidity =0.8.25;

// import {OpTest, IntegrityCheckState, InterpreterState, Operand, stdError} from "test/abstract/OpTest.sol";
// import {LibWillOverflow} from "rain.math.fixedpoint/lib/LibWillOverflow.sol";
// import {LibOpScaleN} from "src/lib/op/math/LibOpScaleN.sol";
// import {LibOperand} from "test/lib/operand/LibOperand.sol";

// contract LibOpScaleNTest is OpTest {
//     /// Directly test the integrity logic of LibOpScaleN.
//     /// Inputs are always 1, outputs are always 1.
//     function testOpScaleNIntegrity(IntegrityCheckState memory state, uint8 inputs, uint16 op) external pure {
//         inputs = uint8(bound(inputs, 1, 0x0F));
//         (uint256 calcInputs, uint256 calcOutputs) = LibOpScaleN.integrity(state, LibOperand.build(inputs, 1, op));
//         assertEq(calcInputs, 1);
//         assertEq(calcOutputs, 1);
//     }

//     /// Directly test the runtime logic of LibOpScaleN.
//     function testOpScaleNRun(uint256 scale, uint256 round, uint256 saturate, uint256 value) public {
//         scale = bound(scale, 0, type(uint8).max);
//         round = bound(round, 0, 1);
//         saturate = bound(saturate, 0, 1);
//         uint256 flags = round | (saturate << 1);
//         InterpreterState memory state = opTestDefaultInterpreterState();

//         Operand operand = LibOperand.build(1, 1, uint16((flags << 8) | scale));

//         uint256[] memory inputs = new uint256[](1);
//         inputs[0] = value;

//         if (LibWillOverflow.scaleNWillOverflow(value, scale, flags)) {
//             vm.expectRevert(stdError.arithmeticError);
//         }

//         opReferenceCheck(state, operand, LibOpScaleN.referenceFn, LibOpScaleN.integrity, LibOpScaleN.run, inputs);
//     }

//     /// Test the eval of `scale-n`.
//     function testOpScaleNEval() external {
//         // Scale 0 value 0 round 0 saturate 0
//         checkHappy("_: scale-n<0>(0);", 0, "0 0 0 0");
//         // Scale 0 value 0 round 0 saturate 1
//         checkHappy("_: scale-n<0 0 1>(0);", 0, "0 0 0 1");
//         // Scale 0 value 0 round 1 saturate 0
//         checkHappy("_: scale-n<0 1 0>(0);", 0, "0 0 1 0");
//         // Scale 0 value 0 round 1 saturate 1
//         checkHappy("_: scale-n<0 1 1>(0);", 0, "0 0 1 1");
//         // Scale 0 value 1 round 0 saturate 0
//         checkHappy("_: scale-n<0>(1e-18);", 0, "0 1 0 0");
//         // Scale 0 value 1 round 0 saturate 1
//         checkHappy("_: scale-n<0 0 1>(1e-18);", 0, "0 1 0 1");
//         // Scale 0 value 1 round 1 saturate 0
//         checkHappy("_: scale-n<0 1 0>(1e-18);", 1, "0 1 1 0");
//         // Scale 0 value 1 round 1 saturate 1
//         checkHappy("_: scale-n<0 1 1>(1e-18);", 1, "0 1 1 1");
//         // Scale 1 value 0 round 0 saturate 0
//         checkHappy("_: scale-n<1>(0);", 0, "1 0 0 0");
//         // Scale 1 value 0 round 0 saturate 1
//         checkHappy("_: scale-n<1 0 1>(0);", 0, "1 0 0 1");
//         // Scale 1 value 0 round 1 saturate 0
//         checkHappy("_: scale-n<1 1 0>(0);", 0, "1 0 1 0");
//         // Scale 1 value 0 round 1 saturate 1
//         checkHappy("_: scale-n<1 1 1>(0);", 0, "1 0 1 1");
//         // Scale 1 value 1 round 0 saturate 0
//         checkHappy("_: scale-n<1>(1e-18);", 0, "1 1 0 0");
//         // Scale 1 value 1 round 0 saturate 1
//         checkHappy("_: scale-n<1 0 1>(1e-18);", 0, "1 1 0 1");
//         // Scale 1 value 1 round 1 saturate 0
//         checkHappy("_: scale-n<1 1 0>(1e-18);", 1, "1 1 1 0");
//         // Scale 1 value 1 round 1 saturate 1
//         checkHappy("_: scale-n<1 1 1>(1e-18);", 1, "1 1 1 1");
//         // Scale 18 value 1 round 0 saturate 0
//         checkHappy("_: scale-n<18>(1e-18);", 1, "18 1 0 0");
//         // Scale 18 value 1 round 0 saturate 1
//         checkHappy("_: scale-n<18 0 1>(1e-18);", 1, "18 1 0 1");
//         // Scale 18 value 1 round 1 saturate 0
//         checkHappy("_: scale-n<18 1 0>(1e-18);", 1, "18 1 1 0");
//         // Scale 18 value 1 round 1 saturate 1
//         checkHappy("_: scale-n<18 1 1>(1e-18);", 1, "18 1 1 1");
//         // Scale 18 value 1e18 round 0 saturate 0
//         checkHappy("_: scale-n<18>(1);", 1e18, "18 1e18 0 0");
//         // Scale 18 value 1e18 round 0 saturate 1
//         checkHappy("_: scale-n<18 0 1>(1);", 1e18, "18 1e18 0 1");
//         // Scale 18 value 1e18 round 1 saturate 0
//         checkHappy("_: scale-n<18 1 0>(1);", 1e18, "18 1e18 1 0");
//         // Scale 18 value 1e18 round 1 saturate 1
//         checkHappy("_: scale-n<18 1 1>(1);", 1e18, "18 1e18 1 1");
//         // Scale 19 value 1e18 round 0 saturate 0
//         checkHappy("_: scale-n<19>(1);", 1e19, "19 1e18 0 0");
//         // Scale 19 value 1e18 round 0 saturate 1
//         checkHappy("_: scale-n<19 0 1>(1);", 1e19, "19 1e18 0 1");
//         // Scale 19 value 1e18 round 1 saturate 0
//         checkHappy("_: scale-n<19 1 0>(1);", 1e19, "19 1e18 1 0");
//         // Scale 19 value 1e18 round 1 saturate 1
//         checkHappy("_: scale-n<19 1 1>(1);", 1e19, "19 1e18 1 1");

//         // Test rounding down while scaling down.
//         checkHappy("_: scale-n<17>(1e-18);", 0, "19 1 0 0");
//         // Test rounding up while scaling down.
//         checkHappy("_: scale-n<17 1>(1e-18);", 1, "19 1 1 0");
//         // Test saturating while scaling up.
//         checkHappy("_: scale-n<36 0 1>(1e52);", type(uint256).max, "0 1e70 0 1");
//         // Test error while scaling up.
//         checkUnhappy("_: scale-n<36>(1e52);", stdError.arithmeticError);
//     }

// /// Test the eval of `decimal18-to-uint256` which is an alias of `scale-n<0>`.
// function testOpDecimal18ToIntNPEval() external view {
//     checkHappy("_: decimal18-to-uint256(0);", 0, "0 0 0 0");
//     checkHappy("_: decimal18-to-uint256(1e-18);", 0, "0 1 0 0");
//     checkHappy("_: decimal18-to-uint256(0.5);", 0, "0 5e17 0 0");
//     checkHappy("_: decimal18-to-uint256(1);", 1, "0 1e18 0 0");
//     checkHappy("_: decimal18-to-uint256(1.5);", 1, "0 15e17 0 0");
//     checkHappy("_: decimal18-to-uint256(1.9);", 1, "0 19e17 0 0");
//     checkHappy("_: decimal18-to-uint256(2);", 2, "0 2e18 0 0");
// }

//     /// Test the eval of `scale-n` opcode parsed from a string.
//     /// Tests zero inputs.
//     function testOpScaleNEvalZeroInputs() external {
//         checkBadInputs("_: scale-n<0>();", 0, 1, 0);
//     }

//     /// Test the eval of `scale-n` opcode parsed from a string.
//     /// Tests two inputs.
//     function testOpScaleNEvalOneInput() external {
//         checkBadInputs("_: scale-n<0>(0 5);", 2, 1, 2);
//         checkBadInputs("_: scale-n<0>(0 0);", 2, 1, 2);
//         checkBadInputs("_: scale-n<0>(0 1);", 2, 1, 2);
//         checkBadInputs("_: scale-n<0>(0 max-value());", 2, 1, 2);
//     }

//     function testOpScaleNEvalZeroOutputs() external {
//         checkBadOutputs(": scale-n<0>(0);", 1, 1, 0);
//     }

//     function testOpScaleNTwoOutputs() external {
//         checkBadOutputs("_ _: scale-n<0>(0);", 1, 1, 2);
//     }
// }
