// SPDX-License-Identifier: CAL
pragma solidity =0.8.25;

// import {OpTest, IntegrityCheckState, InterpreterState, Operand, stdError} from "test/abstract/OpTest.sol";
// import {LibOpSub} from "src/lib/op/math/LibOpSub.sol";
// import {LibOperand} from "test/lib/operand/LibOperand.sol";

// contract LibOpSubTest is OpTest {
//     /// Directly test the integrity logic of LibOpSub. This tests the happy
//     /// path where the inputs input and calc match.
//     function testOpSubIntegrityHappy(IntegrityCheckState memory state, uint8 inputs, uint16 operandData)
//         external
//         pure
//     {
//         inputs = uint8(bound(inputs, 2, 0x0F));
//         (uint256 calcInputs, uint256 calcOutputs) = LibOpSub.integrity(state, LibOperand.build(inputs, 1, operandData));

//         assertEq(calcInputs, inputs);
//         assertEq(calcOutputs, 1);
//     }

// /// Directly test the integrity logic of LibOpSub. This tests the unhappy
// /// path where the operand is invalid due to 0 inputs.
// function testOpSubIntegrityUnhappyZeroInputs(IntegrityCheckState memory state) external pure {
//     (uint256 calcInputs, uint256 calcOutputs) = LibOpSub.integrity(state, Operand.wrap(0));
//     // Calc inputs will be minimum 2.
//     assertEq(calcInputs, 2);
//     assertEq(calcOutputs, 1);
// }

// /// Directly test the integrity logic of LibOpSub. This tests the unhappy
// /// path where the operand is invalid due to 1 inputs.
// function testOpSubIntegrityUnhappyOneInput(IntegrityCheckState memory state) external pure {
//     (uint256 calcInputs, uint256 calcOutputs) = LibOpSub.integrity(state, Operand.wrap(0x010000));
//     // Calc inputs will be minimum 2.
//     assertEq(calcInputs, 2);
//     assertEq(calcOutputs, 1);
// }

//     /// Directly test the runtime logic of LibOpSub.
//     function testOpSubRun(uint256[] memory inputs) external {
//         InterpreterState memory state = opTestDefaultInterpreterState();
//         vm.assume(inputs.length >= 2);
//         vm.assume(inputs.length <= 0x0F);
//         Operand operand = LibOperand.build(uint8(inputs.length), 1, 0);
//         uint256 underflows = 0;
//         unchecked {
//             uint256 a = inputs[0];
//             for (uint256 i = 1; i < inputs.length; i++) {
//                 uint256 b = inputs[i];
//                 uint256 c = a - b;
//                 if (c > a) {
//                     underflows++;
//                 }
//                 a = c;
//             }
//         }
//         if (underflows > 0) {
//             vm.expectRevert(stdError.arithmeticError);
//         }
//         opReferenceCheck(state, operand, LibOpSub.referenceFn, LibOpSub.integrity, LibOpSub.run, inputs);
//     }

//     /// Test the eval of `sub` opcode parsed from a string. Tests zero inputs.
//     function testOpSubEvalZeroInputs() external {
//         checkBadInputs("_: sub();", 0, 2, 0);
//     }

//     /// Test the eval of `sub` opcode parsed from a string. Tests zero inputs.
//     /// Test that saturating does not change the result.
//     function testOpSubEvalZeroInputsSaturating() external {
//         checkBadInputs("_: sub<1>();", 0, 2, 0);
//         checkBadInputs("_: saturating-sub();", 0, 2, 0);
//     }

//     /// Test the eval of `sub` opcode parsed from a string. Tests one input.
//     function testOpSubEvalOneInput() external {
//         checkBadInputs("_: sub(5e-18);", 1, 2, 1);
//         checkBadInputs("_: sub(0);", 1, 2, 1);
//         checkBadInputs("_: sub(1e-18);", 1, 2, 1);
//         checkBadInputs("_: sub(max-value());", 1, 2, 1);
//     }

//     /// Test the eval of `sub` opcode parsed from a string. Tests one input.
//     /// Test that saturating does not change the result.
//     function testOpSubEvalOneInputSaturating() external {
//         checkBadInputs("_: sub<1>(5e-18);", 1, 2, 1);
//         checkBadInputs("_: sub<1>(0);", 1, 2, 1);
//         checkBadInputs("_: sub<1>(1e-18);", 1, 2, 1);
//         checkBadInputs("_: sub<1>(max-value());", 1, 2, 1);

//         checkBadInputs("_: saturating-sub(5e-18);", 1, 2, 1);
//         checkBadInputs("_: saturating-sub(0);", 1, 2, 1);
//         checkBadInputs("_: saturating-sub(1e-18);", 1, 2, 1);
//         checkBadInputs("_: saturating-sub(max-value());", 1, 2, 1);
//     }

// /// Test the eval of `sub` opcode parsed from a string. Tests two inputs.
// function testOpSubEvalTwoInputs() external view {
//     checkHappy("_: sub(1e-18 0);", 1, "1 0");
//     checkHappy("_: sub(1e-18 1e-18);", 0, "1 1");
//     checkHappy("_: sub(2e-18 1e-18);", 1, "2 1");
//     checkHappy("_: sub(2e-18 2e-18);", 0, "2 2");
//     checkHappy("_: sub(max-value() 0);", type(uint256).max, "max-value() 0");
//     checkHappy("_: sub(max-value() 1e-18);", type(uint256).max - 1, "max-value() 1");
//     checkHappy("_: sub(max-value() max-value());", 0, "max-value() max-value()");
// }

// /// Test the eval of `sub` opcode parsed from a string. Tests two inputs.
// /// Test that saturating does not change the result.
// function testOpSubEvalTwoInputsSaturating() external view {
//     checkHappy("_: sub<1>(1e-18 0);", 1, "1 0");
//     checkHappy("_: sub<1>(1e-18 1e-18);", 0, "1 1");
//     checkHappy("_: sub<1>(2e-18 1e-18);", 1, "2 1");
//     checkHappy("_: sub<1>(2e-18 2e-18);", 0, "2 2");
//     checkHappy("_: sub<1>(max-value() 0);", type(uint256).max, "max-value() 0");
//     checkHappy("_: sub<1>(max-value() 1e-18);", type(uint256).max - 1, "max-value() 1");
//     checkHappy("_: sub<1>(max-value() max-value());", 0, "max-value() max-value()");

//         checkHappy("_: saturating-sub(1e-18 0);", 1, "1 0");
//         checkHappy("_: saturating-sub(1e-18 1e-18);", 0, "1 1");
//         checkHappy("_: saturating-sub(2e-18 1e-18);", 1, "2 1");
//         checkHappy("_: saturating-sub(2e-18 2e-18);", 0, "2 2");
//         checkHappy("_: saturating-sub(max-value() 0);", type(uint256).max, "max-value() 0");
//         checkHappy("_: saturating-sub(max-value() 1e-18);", type(uint256).max - 1, "max-value() 1");
//         checkHappy("_: saturating-sub(max-value() max-value());", 0, "max-value() max-value()");
//     }

//     /// Test the eval of `sub` opcode parsed from a string. Tests two inputs.
//     /// Tests the unhappy path where we underflow.
//     function testOpSubEval2InputsUnhappyUnderflow() external {
//         checkUnhappyOverflow("_: sub(0 1e-18);");
//         checkUnhappyOverflow("_: sub(1e-18 2e-18);");
//         checkUnhappyOverflow("_: sub(2e-18 3e-18);");
//     }

// /// Test the eval of `sub` opcode parsed from a string. Tests two inputs.
// /// Tests saturating on an underflow.
// function testOpSubEval2InputsSaturatingUnderflow() external view {
//     checkHappy("_: sub<1>(0 1e-18);", 0, "0 1");
//     checkHappy("_: sub<1>(1e-18 2e-18);", 0, "1 2");
//     checkHappy("_: sub<1>(2e-18 3e-18);", 0, "2 3");

//         checkHappy("_: saturating-sub(0 1e-18);", 0, "0 1");
//         checkHappy("_: saturating-sub(1e-18 2e-18);", 0, "1 2");
//         checkHappy("_: saturating-sub(2e-18 3e-18);", 0, "2 3");
//     }

// /// Test the eval of `sub` opcode parsed from a string. Tests three inputs.
// function testOpSubEvalThreeInputs() external view {
//     checkHappy("_: sub(1e-18 0 0);", 1, "1 0 0");
//     checkHappy("_: sub(1e-18 1e-18 0);", 0, "1 1 0");
//     checkHappy("_: sub(2e-18 1e-18 1e-18);", 0, "2 1 1");
//     checkHappy("_: sub(2e-18 2e-18 0);", 0, "2 2 0");
// }

// /// Test the eval of `sub` opcode parsed from a string. Tests three inputs.
// /// Test that saturating does not change the result.
// function testOpSubEvalThreeInputsSaturating() external view {
//     checkHappy("_: sub<1>(1e-18 0 0);", 1, "1 0 0");
//     checkHappy("_: sub<1>(1e-18 1e-18 0);", 0, "1 1 0");
//     checkHappy("_: sub<1>(2e-18 1e-18 1e-18);", 0, "2 1 1");
//     checkHappy("_: sub<1>(2e-18 2e-18 0);", 0, "2 2 0");

//         checkHappy("_: saturating-sub(1e-18 0 0);", 1, "1 0 0");
//         checkHappy("_: saturating-sub(1e-18 1e-18 0);", 0, "1 1 0");
//         checkHappy("_: saturating-sub(2e-18 1e-18 1e-18);", 0, "2 1 1");
//         checkHappy("_: saturating-sub(2e-18 2e-18 0);", 0, "2 2 0");
//     }

//     /// Test the eval of `sub` opcode parsed from a string. Tests three inputs.
//     /// Tests the unhappy path where we underflow.
//     function testOpSubEval3InputsUnhappyUnderflow() external {
//         checkUnhappyOverflow("_: sub(0 0 1e-18);");
//         checkUnhappyOverflow("_: sub(0 1e-18 2e-18);");
//         checkUnhappyOverflow("_: sub(1e-18 1e-18 1e-18);");
//         checkUnhappyOverflow("_: sub(1e-18 2e-18 3e-18);");
//         checkUnhappyOverflow("_: sub(2e-18 3e-18 4e-18);");
//         checkUnhappyOverflow("_: sub(3e-18 4e-18 5e-18);");
//         checkUnhappyOverflow("_: sub(2e-18 2e-18 1e-18);");
//     }

// /// Test the eval of `sub` opcocde parsed from a string. Tests three inputs.
// /// Tests saturating on an underflow.
// function testOpSubEval3InputsSaturatingUnderflow() external view {
//     checkHappy("_: sub<1>(0 0 1e-18);", 0, "0 0 1");
//     checkHappy("_: sub<1>(0 1e-18 2e-18);", 0, "0 1 2");
//     checkHappy("_: sub<1>(1e-18 1e-18 1e-18);", 0, "1 1 1");
//     checkHappy("_: sub<1>(1e-18 2e-18 3e-18);", 0, "1 2 3");
//     checkHappy("_: sub<1>(2e-18 3e-18 4e-18);", 0, "2 3 4");
//     checkHappy("_: sub<1>(3e-18 4e-18 5e-18);", 0, "3 4 5");
//     checkHappy("_: sub<1>(2e-18 2e-18 1e-18);", 0, "2 2 1");

//         checkHappy("_: saturating-sub(0 0 1e-18);", 0, "0 0 1");
//         checkHappy("_: saturating-sub(0 1e-18 2e-18);", 0, "0 1 2");
//         checkHappy("_: saturating-sub(1e-18 1e-18 1e-18);", 0, "1 1 1");
//         checkHappy("_: saturating-sub(1e-18 2e-18 3e-18);", 0, "1 2 3");
//         checkHappy("_: saturating-sub(2e-18 3e-18 4e-18);", 0, "2 3 4");
//         checkHappy("_: saturating-sub(3e-18 4e-18 5e-18);", 0, "3 4 5");
//         checkHappy("_: saturating-sub(2e-18 2e-18 1e-18);", 0, "2 2 1");
//     }
// }
