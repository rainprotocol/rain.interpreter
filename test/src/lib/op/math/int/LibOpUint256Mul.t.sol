// SPDX-License-Identifier: CAL
pragma solidity =0.8.25;

// import {OpTest, IntegrityCheckState, Operand, InterpreterState, stdError} from "test/abstract/OpTest.sol";
// import {LibOpUint256Mul} from "src/lib/op/math/uint256/LibOpUint256Mul.sol";
// import {LibOperand} from "test/lib/operand/LibOperand.sol";

// contract LibOpUint256MulTest is OpTest {
//     /// Directly test the integrity logic of LibOpUint256Mul. This tests the happy
//     /// path where the inputs input and calc match.
//     function testOpUint256MulIntegrityHappy(IntegrityCheckState memory state, uint8 inputs, uint16 operandData)
//         external
//         pure
//     {
//         inputs = uint8(bound(inputs, 2, 0x0F));
//         (uint256 calcInputs, uint256 calcOutputs) =
//             LibOpUint256Mul.integrity(state, LibOperand.build(inputs, 1, operandData));

//         assertEq(calcInputs, inputs);
//         assertEq(calcOutputs, 1);
//     }

// /// Directly test the integrity logic of LibOpUint256Mul. This tests the unhappy
// /// path where the operand is invalid due to 0 inputs.
// function testOpUint256MulIntegrityUnhappyZeroInputs(IntegrityCheckState memory state) external pure {
//     (uint256 calcInputs, uint256 calcOutputs) = LibOpUint256Mul.integrity(state, Operand.wrap(0));
//     // Calc inputs will be minimum 2.
//     assertEq(calcInputs, 2);
//     assertEq(calcOutputs, 1);
// }

// /// Directly test the integrity logic of LibOpUint256Mul. This tests the unhappy
// /// path where the operand is invalid due to 1 inputs.
// function testOpUint256MulIntegrityUnhappyOneInput(IntegrityCheckState memory state) external pure {
//     (uint256 calcInputs, uint256 calcOutputs) = LibOpUint256Mul.integrity(state, Operand.wrap(0x010000));
//     // Calc inputs will be minimum 2.
//     assertEq(calcInputs, 2);
//     assertEq(calcOutputs, 1);
// }

//     /// Directly test the runtime logic of LibOpUint256Mul.
//     function testOpUint256MulRun(uint256[] memory inputs) external {
//         InterpreterState memory state = opTestDefaultInterpreterState();
//         vm.assume(inputs.length >= 2);
//         vm.assume(inputs.length <= 0x0F);
//         Operand operand = LibOperand.build(uint8(inputs.length), 1, 0);
//         uint256 overflows = 0;
//         unchecked {
//             uint256 a = inputs[0];
//             for (uint256 i = 1; i < inputs.length; i++) {
//                 uint256 b = inputs[i];
//                 if (a == 0 || b == 0) {
//                     break;
//                 }
//                 uint256 c = a * b;
//                 if (c / a != b) {
//                     overflows++;
//                 }
//                 a = c;
//             }
//         }
//         if (overflows > 0) {
//             vm.expectRevert(stdError.arithmeticError);
//         }
//         opReferenceCheck(
//             state, operand, LibOpUint256Mul.referenceFn, LibOpUint256Mul.integrity, LibOpUint256Mul.run, inputs
//         );
//     }

//     /// Test the eval of `uint256-mul` opcode parsed from a string. Tests zero inputs.
//     function testOpUint256MulEvalZeroInputs() external {
//         checkBadInputs("_: uint256-mul();", 0, 2, 0);
//     }

//     /// Test the eval of `uint256-mul` opcode parsed from a string. Tests one input.
//     function testOpUint256MulEvalOneInput() external {
//         checkBadInputs("_: uint256-mul(5e-18);", 1, 2, 1);
//         checkBadInputs("_: uint256-mul(0);", 1, 2, 1);
//         checkBadInputs("_: uint256-mul(1e-18);", 1, 2, 1);
//         checkBadInputs("_: uint256-mul(max-value());", 1, 2, 1);
//     }

//     function testOpUint256MulEvalZeroOutputs() external {
//         checkBadOutputs(": uint256-mul(0 0);", 2, 1, 0);
//     }

//     function testOpUint256MulEvalTwoOutputs() external {
//         checkBadOutputs("_ _: uint256-mul(0 0);", 2, 1, 2);
//     }

// /// Test the eval of `uint256-mul` opcode parsed from a string. Tests two inputs.
// /// Tests the happy path where multiplication does not overflow.
// function testOpUint256MulEvalTwoInputsHappy() external view {
//     checkHappy("_: uint256-mul(0 0);", 0, "0 0");
//     checkHappy("_: uint256-mul(0 1e-18);", 0, "0 1");
//     checkHappy("_: uint256-mul(1e-18 0);", 0, "1 0");
//     checkHappy("_: uint256-mul(1e-18 1e-18);", 1, "1 1");
//     checkHappy("_: uint256-mul(1e-18 2e-18);", 2, "1 2");
//     checkHappy("_: uint256-mul(2e-18 1e-18);", 2, "2 1");
//     checkHappy("_: uint256-mul(2e-18 2e-18);", 4, "2 2");
//     checkHappy("_: uint256-mul(max-value() 0);", 0, "max-value() 0");
//     checkHappy("_: uint256-mul(max-value() 1e-18);", type(uint256).max, "max-value() 1");
// }

//     /// Test the eval of `uint256-mul` opcode parsed from a string. Tests two inputs.
//     /// Tests the unhappy path where multiplication overflows.
//     function testOpUint256MulEvalTwoInputsUnhappy() external {
//         checkUnhappyOverflow("_: uint256-mul(max-value() 2e-18);");
//         checkUnhappyOverflow("_: uint256-mul(2e-18 max-value());");
//         checkUnhappyOverflow("_: uint256-mul(max-value() max-value());");
//     }

// /// Test the eval of `uint256-mul` opcode parsed from a string. Tests three inputs.
// /// Tests the happy path where multiplication does not overflow.
// function testOpUint256MulEvalThreeInputsHappy() external view {
//     checkHappy("_: uint256-mul(0 0 0);", 0, "0 0 0");
//     checkHappy("_: uint256-mul(0 0 1e-18);", 0, "0 0 1");
//     checkHappy("_: uint256-mul(0 1e-18 0);", 0, "0 1 0");
//     checkHappy("_: uint256-mul(0 1e-18 1e-18);", 0, "0 1 1");
//     checkHappy("_: uint256-mul(1e-18 0 0);", 0, "1 0 0");
//     checkHappy("_: uint256-mul(1e-18 0 1e-18);", 0, "1 0 1");
//     checkHappy("_: uint256-mul(1e-18 1e-18 0);", 0, "1 1 0");
//     checkHappy("_: uint256-mul(1e-18 1e-18 1e-18);", 1, "1 1 1");
//     checkHappy("_: uint256-mul(1e-18 1e-18 2e-18);", 2, "1 1 2");
//     checkHappy("_: uint256-mul(1e-18 2e-18 1e-18);", 2, "1 2 1");
//     checkHappy("_: uint256-mul(1e-18 2e-18 2e-18);", 4, "1 2 2");
//     checkHappy("_: uint256-mul(2e-18 1e-18 1e-18);", 2, "2 1 1");
//     checkHappy("_: uint256-mul(2e-18 1e-18 2e-18);", 4, "2 1 2");
//     checkHappy("_: uint256-mul(2e-18 2e-18 1e-18);", 4, "2 2 1");
//     checkHappy("_: uint256-mul(2e-18 2e-18 2e-18);", 8, "2 2 2");
//     checkHappy("_: uint256-mul(max-value() 0 0);", 0, "max-value() 0 0");
//     checkHappy("_: uint256-mul(max-value() 0 1e-18);", 0, "max-value() 0 1");
//     checkHappy("_: uint256-mul(max-value() 0 2e-18);", 0, "max-value() 0 2");
//     checkHappy("_: uint256-mul(max-value() 1e-18 0);", 0, "max-value() 1 0");
//     checkHappy("_: uint256-mul(max-value() 1e-18 1e-18);", type(uint256).max, "max-value() 1 1");
// }

//     /// Test the eval of `uint256-mul` opcode parsed from a string. Tests three inputs.
//     /// Tests the unhappy path where multiplication overflows.
//     function testOpUint256MulEvalThreeInputsUnhappy() external {
//         checkUnhappyOverflow("_: uint256-mul(max-value() 2e-18 2e-18);");
//         checkUnhappyOverflow("_: uint256-mul(2e-18 max-value() 2e-18);");
//         checkUnhappyOverflow("_: uint256-mul(2e-18 2e-18 max-value());");
//         checkUnhappyOverflow("_: uint256-mul(max-value() max-value() 2e-18);");
//         checkUnhappyOverflow("_: uint256-mul(max-value() 2e-18 max-value());");
//         checkUnhappyOverflow("_: uint256-mul(2e-18 max-value() max-value());");
//         checkUnhappyOverflow("_: uint256-mul(max-value() max-value() max-value());");

//         // Show that overflow can happen in the middle of the calculation.
//         checkUnhappyOverflow("_: uint256-mul(2e-18 max-value() 2e-18 2e-18);");
//         checkUnhappyOverflow("_: uint256-mul(2e-18 2e-18 max-value() 2e-18);");
//         checkUnhappyOverflow("_: uint256-mul(2e-18 2e-18 2e-18 max-value());");
//         checkUnhappyOverflow("_: uint256-mul(max-value() 2e-18 2e-18 2e-18);");
//         checkUnhappyOverflow("_: uint256-mul(2e-18 max-value() 0);");
//     }

//     /// Test the eval of `uint256-mul` opcode parsed from a string.
//     /// Tests that operands are disallowed.
//     function testOpUint256MulEvalOperandsDisallowed() external {
//         checkDisallowedOperand("_: uint256-mul<0>(0 0 0);");
//         checkDisallowedOperand("_: uint256-mul<1>(0 0 0);");
//         checkDisallowedOperand("_: uint256-mul<2>(0 0 0);");
//         checkDisallowedOperand("_: uint256-mul<0 0>(0 0 0);");
//         checkDisallowedOperand("_: uint256-mul<0 1>(0 0 0);");
//         checkDisallowedOperand("_: uint256-mul<1 0>(0 0 0);");
//     }
// }
