// SPDX-License-Identifier: CAL
pragma solidity =0.8.25;

// import {OpTest, IntegrityCheckState, Operand, InterpreterState, stdError} from "test/abstract/OpTest.sol";
// import {LibContext} from "rain.interpreter.interface/lib/caller/LibContext.sol";
// import {UnexpectedOperand} from "src/error/ErrParse.sol";
// import {LibOpUint256Div} from "src/lib/op/math/uint256/LibOpUint256Div.sol";
// import {LibOperand} from "test/lib/operand/LibOperand.sol";

// contract LibOpUint256DivTest is OpTest {
//     /// Directly test the integrity logic of LibOpUint256Div. This tests the happy
//     /// path where the inputs input and calc match.
//     function testOpUint256DivIntegrityHappy(IntegrityCheckState memory state, uint8 inputs, uint16 operandData)
//         external
//         pure
//     {
//         inputs = uint8(bound(inputs, 2, 0x0F));
//         (uint256 calcInputs, uint256 calcOutputs) =
//             LibOpUint256Div.integrity(state, LibOperand.build(inputs, 1, operandData));

//         assertEq(calcInputs, inputs);
//         assertEq(calcOutputs, 1);
//     }

// /// Directly test the integrity logic of LibOpUint256Div. This tests the unhappy
// /// path where the operand is invalid due to 0 inputs.
// function testOpUint256DivIntegrityUnhappyZeroInputs(IntegrityCheckState memory state) external pure {
//     (uint256 calcInputs, uint256 calcOutputs) = LibOpUint256Div.integrity(state, Operand.wrap(0));
//     // Calc inputs will be minimum 2.
//     assertEq(calcInputs, 2);
//     assertEq(calcOutputs, 1);
// }

// /// Directly test the integrity logic of LibOpUint256Div. This tests the unhappy
// /// path where the operand is invalid due to 1 inputs.
// function testOpUint256DivIntegrityUnhappyOneInput(IntegrityCheckState memory state) external pure {
//     (uint256 calcInputs, uint256 calcOutputs) = LibOpUint256Div.integrity(state, Operand.wrap(0x010000));
//     // Calc inputs will be minimum 2.
//     assertEq(calcInputs, 2);
//     assertEq(calcOutputs, 1);
// }

//     /// Directly test the runtime logic of LibOpUint256Div.
//     function testOpUint256DivRun(uint256[] memory inputs) external {
//         InterpreterState memory state = opTestDefaultInterpreterState();
//         vm.assume(inputs.length >= 2);
//         vm.assume(inputs.length <= 0x0F);
//         Operand operand = LibOperand.build(uint8(inputs.length), 1, 0);

//         uint256 divZeros = 0;
//         for (uint256 i = 1; i < inputs.length; i++) {
//             if (inputs[i] == 0) {
//                 divZeros++;
//             }
//         }
//         if (divZeros > 0) {
//             vm.expectRevert(stdError.divisionError);
//         }
//         opReferenceCheck(
//             state, operand, LibOpUint256Div.referenceFn, LibOpUint256Div.integrity, LibOpUint256Div.run, inputs
//         );
//     }

//     /// Test the eval of `uint256-div` opcode parsed from a string. Tests zero inputs.
//     function testOpUint256DivEvalZeroInputs() external {
//         checkBadInputs("_: uint256-div();", 0, 2, 0);
//     }

//     /// Test the eval of `uint256-div` opcode parsed from a string. Tests one input.
//     function testOpUint256DivEvalOneInput() external {
//         checkBadInputs("_: uint256-div(5e-18);", 1, 2, 1);
//         checkBadInputs("_: uint256-div(0e-18);", 1, 2, 1);
//         checkBadInputs("_: uint256-div(1e-18);", 1, 2, 1);
//         checkBadInputs("_: uint256-div(max-value());", 1, 2, 1);
//     }

//     function testOpUint256DivEvalZeroOutputs() external {
//         checkBadOutputs(": uint256-div(0 0);", 2, 1, 0);
//     }

//     function testOpUint256DivEvalTwoOutputs() external {
//         checkBadOutputs("_ _: uint256-div(0 0);", 2, 1, 2);
//     }

// /// Test the eval of `uint256-div` opcode parsed from a string. Tests two inputs.
// /// Tests the happy path where we do not divide by zero.
// /// Note that the division truncates (rounds down).
// function testOpUint256DivEval2InputsHappy() external view {
//     // Show that the division truncates (rounds down).
//     checkHappy("_: uint256-div(6e-18 1e-18);", 6, "6 / 1");
//     checkHappy("_: uint256-div(6e-18 2e-18);", 3, "6 / 2");
//     checkHappy("_: uint256-div(6e-18 3e-18);", 2, "6 / 3");
//     checkHappy("_: uint256-div(6e-18 4e-18);", 1, "6 / 4");
//     checkHappy("_: uint256-div(6e-18 5e-18);", 1, "6 / 5");
//     checkHappy("_: uint256-div(6e-18 6e-18);", 1, "6 / 6");
//     checkHappy("_: uint256-div(6e-18 7e-18);", 0, "6 / 7");
//     checkHappy("_: uint256-div(6e-18 max-value());", 0, "6 / max-value()");

//         // Anything divided by 1 is itself.
//         checkHappy("_: uint256-div(0 1e-18);", 0, "0 / 1");
//         checkHappy("_: uint256-div(1e-18 1e-18);", 1, "1 / 1");
//         checkHappy("_: uint256-div(2e-18 1e-18);", 2, "2 / 1");
//         checkHappy("_: uint256-div(3e-18 1e-18);", 3, "3 / 1");
//         checkHappy("_: uint256-div(max-value() 1e-18);", type(uint256).max, "max-value() / 1");

//         // Anything divided by itself is 1 (except 0).
//         checkHappy("_: uint256-div(1e-18 1e-18);", 1, "1 / 1");
//         checkHappy("_: uint256-div(2e-18 2e-18);", 1, "2 / 2");
//         checkHappy("_: uint256-div(3e-18 3e-18);", 1, "3 / 3");
//         checkHappy("_: uint256-div(max-value() max-value());", 1, "max-value() / max-value()");
//     }

//     /// Test the eval of `uint256-div` opcode parsed from a string. Tests two inputs.
//     /// Tests the unhappy path where we divide by zero.
//     function testOpUint256DivEval2InputsUnhappy() external {
//         checkUnhappy("_: uint256-div(0 0);", stdError.divisionError);
//         checkUnhappy("_: uint256-div(1e-18 0);", stdError.divisionError);
//         checkUnhappy("_: uint256-div(max-value() 0);", stdError.divisionError);
//     }

// /// Test the eval of `uint256-div` opcode parsed from a string. Tests three inputs.
// /// Tests the happy path where we do not divide by zero.
// function testOpUint256DivEval3InputsHappy() external view {
//     // Show that the division truncates (rounds down).
//     checkHappy("_: uint256-div(6e-18 1e-18 1e-18);", 6, "6 / 1 / 1");
//     checkHappy("_: uint256-div(6e-18 2e-18 1e-18);", 3, "6 / 2 / 1");
//     checkHappy("_: uint256-div(6e-18 3e-18 1e-18);", 2, "6 / 3 / 1");
//     checkHappy("_: uint256-div(6e-18 4e-18 1e-18);", 1, "6 / 4 / 1");
//     checkHappy("_: uint256-div(6e-18 5e-18 1e-18);", 1, "6 / 5 / 1");
//     checkHappy("_: uint256-div(6e-18 6e-18 1e-18);", 1, "6 / 6 / 1");
//     checkHappy("_: uint256-div(6e-18 7e-18 1e-18);", 0, "6 / 7 / 1");
//     checkHappy("_: uint256-div(6e-18 max-value() 1e-18);", 0, "6 / max-value() / 1");
//     checkHappy("_: uint256-div(6e-18 1e-18 2e-18);", 3, "6 / 1 / 2");
//     checkHappy("_: uint256-div(6e-18 2e-18 2e-18);", 1, "6 / 2 / 2");
//     checkHappy("_: uint256-div(6e-18 3e-18 2e-18);", 1, "6 / 3 / 2");
//     checkHappy("_: uint256-div(6e-18 4e-18 2e-18);", 0, "6 / 4 / 2");
//     checkHappy("_: uint256-div(6e-18 5e-18 2e-18);", 0, "6 / 5 / 2");
//     checkHappy("_: uint256-div(6e-18 6e-18 2e-18);", 0, "6 / 6 / 2");
//     checkHappy("_: uint256-div(6e-18 7e-18 2e-18);", 0, "6 / 7 / 2");
//     checkHappy("_: uint256-div(6e-18 max-value() 2e-18);", 0, "6 / max-value() / 2");

//         // Anything divided by 1 is itself.
//         checkHappy("_: uint256-div(0 1e-18 1e-18);", 0, "0 / 1 / 1");
//         checkHappy("_: uint256-div(1e-18 1e-18 1e-18);", 1, "1 / 1 / 1");
//         checkHappy("_: uint256-div(2e-18 1e-18 1e-18);", 2, "2 / 1 / 1");
//         checkHappy("_: uint256-div(3e-18 1e-18 1e-18);", 3, "3 / 1 / 1");
//         checkHappy("_: uint256-div(max-value() 1e-18 1e-18);", type(uint256).max, "max-value() / 1 / 1");

//         // Anything divided by itself is 1 (except 0).
//         checkHappy("_: uint256-div(1e-18 1e-18 1e-18);", 1, "1 / 1 / 1");
//         checkHappy("_: uint256-div(2e-18 2e-18 1e-18);", 1, "2 / 2 / 1");
//         checkHappy("_: uint256-div(2e-18 1e-18 2e-18);", 1, "2 / 1 / 2");
//         checkHappy("_: uint256-div(3e-18 3e-18 1e-18);", 1, "3 / 3 / 1");
//         checkHappy("_: uint256-div(3e-18 1e-18 3e-18);", 1, "3 / 1 / 3");
//         checkHappy("_: uint256-div(max-value() max-value() 1e-18);", 1, "max-value() / max-value() / 1");
//         checkHappy("_: uint256-div(max-value() 1e-18 max-value());", 1, "max-value() / 1 / max-value()");
//     }

//     /// Test the eval of `uint256-div` opcode parsed from a string. Tests three inputs.
//     /// Tests the unhappy path where we divide by zero.
//     function testOpUint256DivEval3InputsUnhappy() external {
//         checkUnhappy("_: uint256-div(0 0 0);", stdError.divisionError);
//         checkUnhappy("_: uint256-div(1e-18 0 0);", stdError.divisionError);
//         checkUnhappy("_: uint256-div(max-value() 0 0);", stdError.divisionError);
//         checkUnhappy("_: uint256-div(0 1e-18 0);", stdError.divisionError);
//         checkUnhappy("_: uint256-div(1e-18 1e-18 0);", stdError.divisionError);
//         checkUnhappy("_: uint256-div(max-value() max-value() 0);", stdError.divisionError);
//         checkUnhappy("_: uint256-div(0 0 1e-18);", stdError.divisionError);
//         checkUnhappy("_: uint256-div(1e-18 0 1e-18);", stdError.divisionError);
//         checkUnhappy("_: uint256-div(max-value() 0 1e-18);", stdError.divisionError);
//     }

//     /// Test the eval of `uint256-div` opcode parsed from a string.
//     /// Tests that operands are disallowed.
//     function testOpUint256DivEvalOperandDisallowed() external {
//         checkDisallowedOperand("_: uint256-div<0>(0 0 0);");
//         checkDisallowedOperand("_: uint256-div<1>(0 0 0);");
//         checkDisallowedOperand("_: uint256-div<2>(0 0 0);");
//         checkDisallowedOperand("_: uint256-div<3 1>(0 0 0);");
//     }
// }
