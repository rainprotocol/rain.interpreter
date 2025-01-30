// SPDX-License-Identifier: CAL
pragma solidity =0.8.25;

// import {LibUint256Array} from "rain.solmem/lib/LibUint256Array.sol";

// import {OpTest, IntegrityCheckState, InterpreterState, Operand, stdError} from "test/abstract/OpTest.sol";
// import {LibContext} from "rain.interpreter.interface/lib/caller/LibContext.sol";
// import {UnexpectedOperand} from "src/error/ErrParse.sol";
// import {LibOpMod} from "src/lib/op/math/LibOpMod.sol";
// import {LibOperand} from "test/lib/operand/LibOperand.sol";

// contract LibOpModTest is OpTest {
//     using LibUint256Array for uint256[];

// /// Directly test the integrity logic of LibOpMod. This tests the happy
// /// path where the inputs input and calc match.
// function testOpModIntegrityHappy(IntegrityCheckState memory state, uint8 inputs, uint16 operandData)
//     external
//     pure
// {
//     inputs = uint8(bound(inputs, 2, 0x0F));
//     (uint256 calcInputs, uint256 calcOutputs) = LibOpMod.integrity(state, LibOperand.build(inputs, 1, operandData));

//         assertEq(calcInputs, inputs);
//         assertEq(calcOutputs, 1);
//     }

// /// Directly test the integrity logic of LibOpMod. This tests the unhappy
// /// path where the operand is invalid due to 0 inputs.
// function testOpModIntegrityUnhappyZeroInputs(IntegrityCheckState memory state) external pure {
//     (uint256 calcInputs, uint256 calcOutputs) = LibOpMod.integrity(state, Operand.wrap(0));
//     // Calc inputs will be minimum 2.
//     assertEq(calcInputs, 2);
//     assertEq(calcOutputs, 1);
// }

// /// Directly test the integrity logic of LibOpMod. This tests the unhappy
// /// path where the operand is invalid due to 1 inputs.
// function testOpModIntegrityUnhappyOneInput(IntegrityCheckState memory state) external pure {
//     (uint256 calcInputs, uint256 calcOutputs) = LibOpMod.integrity(state, Operand.wrap(0x010000));
//     // Calc inputs will be minimum 2.
//     assertEq(calcInputs, 2);
//     assertEq(calcOutputs, 1);
// }

//     /// Directly test the runtime logic of LibOpMod.
//     function testOpModRun(uint256[] memory inputs) external {
//         InterpreterState memory state = opTestDefaultInterpreterState();
//         vm.assume(inputs.length >= 2);
//         vm.assume(inputs.length <= 0x0F);
//         Operand operand = LibOperand.build(uint8(inputs.length), 1, 0);
//         uint256 modZeros = 0;
//         for (uint256 i = 1; i < inputs.length; i++) {
//             if (inputs[i] == 0) {
//                 modZeros++;
//             }
//         }
//         if (modZeros > 0) {
//             vm.expectRevert(stdError.divisionError);
//         }
//         opReferenceCheck(state, operand, LibOpMod.referenceFn, LibOpMod.integrity, LibOpMod.run, inputs);
//     }

//     /// Test the eval of `mod` opcode parsed from a string. Tests zero inputs.
//     function testOpModEvalZeroInputs() external {
//         checkBadInputs("_: mod();", 0, 2, 0);
//     }

//     /// Test the eval of `mod` opcode parsed from a string. Tests one input.
//     function testOpModEvalOneInput() external {
//         checkBadInputs("_: mod(5e-18);", 1, 2, 1);
//         checkBadInputs("_: mod(0);", 1, 2, 1);
//         checkBadInputs("_: mod(1e-18);", 1, 2, 1);
//         checkBadInputs("_: mod(max-value());", 1, 2, 1);
//     }

//     function testOpModEvalZeroOutputs() external {
//         checkBadOutputs(": mod(0 0);", 2, 1, 0);
//     }

//     function testOpModEvalTwoOutputs() external {
//         checkBadOutputs("_ _: mod(0 0);", 2, 1, 2);
//     }

// /// Test the eval of `mod` opcode parsed from a string. Tests two inputs.
// /// Tests the happy path where we do not mod by zero.
// function testOpModEval2InputsHappy() external view {
//     // Show that the modulo truncates (rounds down).
//     checkHappy("_: mod(6e-18 1e-18);", 0, "6 1");
//     checkHappy("_: mod(6e-18 2e-18);", 0, "6 2");
//     checkHappy("_: mod(6e-18 3e-18);", 0, "6 3");
//     checkHappy("_: mod(6e-18 4e-18);", 2, "6 4");
//     checkHappy("_: mod(6e-18 5e-18);", 1, "6 5");
//     checkHappy("_: mod(6e-18 6e-18);", 0, "6 6");
//     checkHappy("_: mod(6e-18 7e-18);", 6, "6 7");
//     checkHappy("_: mod(6e-18 max-value());", 6, "6 max-value()");

//         // Anything module by 1 is 0.
//         checkHappy("_: mod(0 1e-18);", 0, "0 1");
//         checkHappy("_: mod(1e-18 1e-18);", 0, "1 1");
//         checkHappy("_: mod(2e-18 1e-18);", 0, "2 1");
//         checkHappy("_: mod(3e-18 1e-18);", 0, "3 1");
//         checkHappy("_: mod(max-value() 1e-18);", 0, "max-value() 1");

//         // Anything mod by itself is 0 (except 0).
//         checkHappy("_: mod(1e-18 1e-18);", 0, "1 1");
//         checkHappy("_: mod(2e-18 2e-18);", 0, "2 2");
//         checkHappy("_: mod(3e-18 3e-18);", 0, "3 3");
//         checkHappy("_: mod(max-value() max-value());", 0, "max-value() max-value()");
//     }

//     /// Test the eval of `mod` opcode parsed from a string. Tests two inputs.
//     /// Tests the unhappy path where we modulo by zero.
//     function testOpModEval2InputsUnhappy() external {
//         checkUnhappy("_: mod(0 0);", stdError.divisionError);
//         checkUnhappy("_: mod(1e-18 0);", stdError.divisionError);
//         checkUnhappy("_: mod(max-value() 0);", stdError.divisionError);
//     }

// /// Test the eval of `mod` opcode parsed from a string. Tests three inputs.
// /// Tests the happy path where we do not modulo by zero.
// function testOpModEval3InputsHappy() external view {
//     // Show that the modulo truncates (rounds down).
//     checkHappy("_: mod(6e-18 1e-18 1e-18);", 0, "6 1 1");
//     checkHappy("_: mod(6e-18 2e-18 1e-18);", 0, "6 2 1");
//     checkHappy("_: mod(6e-18 3e-18 1e-18);", 0, "6 3 1");
//     checkHappy("_: mod(26e-18 20e-18 4e-18);", 2, "26 20 4");
//     checkHappy("_: mod(6e-18 4e-18 1e-18);", 0, "6 4 1");
//     checkHappy("_: mod(6e-18 5e-18 1e-18);", 0, "6 5 1");
//     checkHappy("_: mod(6e-18 6e-18 1e-18);", 0, "6 6 1");
//     checkHappy("_: mod(6e-18 7e-18 1e-18);", 0, "6 7 1");
//     checkHappy("_: mod(6e-18 max-value() 1e-18);", 0, "6 max-value() 1");
//     checkHappy("_: mod(6e-18 1e-18 2e-18);", 0, "6 1 2");
//     checkHappy("_: mod(6e-18 2e-18 2e-18);", 0, "6 2 2");
//     checkHappy("_: mod(6e-18 3e-18 2e-18);", 0, "6 3 2");
//     checkHappy("_: mod(6e-18 4e-18 2e-18);", 0, "6 4 2");
//     checkHappy("_: mod(6e-18 5e-18 2e-18);", 1, "6 5 2");
//     checkHappy("_: mod(6e-18 6e-18 2e-18);", 0, "6 6 2");
//     checkHappy("_: mod(6e-18 7e-18 2e-18);", 0, "6 7 2");
//     checkHappy("_: mod(6e-18 max-value() 2e-18);", 0, "6 max-value() 2");

//         // Anything modulo by 1 is 0.
//         checkHappy("_: mod(0 1e-18 1e-18);", 0, "0 1 1");
//         checkHappy("_: mod(1e-18 1e-18 1e-18);", 0, "1 1 1");
//         checkHappy("_: mod(2e-18 1e-18 1e-18);", 0, "2 1 1");
//         checkHappy("_: mod(3e-18 1e-18 1e-18);", 0, "3 1 1");
//         checkHappy("_: mod(max-value() 1e-18 1e-18);", 0, "max-value() 1 1");

//         // Anything modulo by itself is 0 (except 0).
//         checkHappy("_: mod(1e-18 1e-18 1e-18);", 0, "1 1 1");
//         checkHappy("_: mod(2e-18 2e-18 1e-18);", 0, "2 2 1");
//         checkHappy("_: mod(2e-18 1e-18 2e-18);", 0, "2 1 2");
//         checkHappy("_: mod(3e-18 3e-18 1e-18);", 0, "3 3 1");
//         checkHappy("_: mod(3e-18 1e-18 3e-18);", 0, "3 1 3");
//         checkHappy("_: mod(max-value() max-value() 1e-18);", 0, "max-value() max-value() 1");
//         checkHappy("_: mod(max-value() 1e-18 max-value());", 0, "max-value() 1 max-value()");
//     }

//     /// Test the eval of `mod` opcode parsed from a string. Tests three inputs.
//     /// Tests the unhappy path where we modulo by zero.
//     function testOpModEval3InputsUnhappy() external {
//         checkUnhappy("_: mod(0 0 0);", stdError.divisionError);
//         checkUnhappy("_: mod(1e-18 0 0);", stdError.divisionError);
//         checkUnhappy("_: mod(max-value() 0 0);", stdError.divisionError);
//         checkUnhappy("_: mod(0 1e-18 0);", stdError.divisionError);
//         checkUnhappy("_: mod(1e-18 1e-18 0);", stdError.divisionError);
//         checkUnhappy("_: mod(max-value() max-value() 0);", stdError.divisionError);
//         checkUnhappy("_: mod(0 0 1e-18);", stdError.divisionError);
//         checkUnhappy("_: mod(1e-18 0 1e-18);", stdError.divisionError);
//         checkUnhappy("_: mod(max-value() 0 1e-18);", stdError.divisionError);
//     }

//     /// Test the eval of `mod` opcode parsed from a string.
//     /// Tests that operands are disallowed.
//     function testOpModEvalOperandDisallowed() external {
//         checkDisallowedOperand("_: mod<0>(0 0 0);");
//         checkDisallowedOperand("_: mod<1>(0 0 0);");
//         checkDisallowedOperand("_: mod<2>(0 0 0);");
//         checkDisallowedOperand("_: mod<3 1>(0 0 0);");
//     }
// }
