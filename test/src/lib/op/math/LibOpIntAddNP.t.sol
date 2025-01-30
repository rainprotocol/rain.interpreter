// SPDX-License-Identifier: CAL
pragma solidity =0.8.25;

// import {stdError} from "forge-std/Test.sol";
// import {OpTest, IntegrityCheckState, Operand, InterpreterState} from "test/abstract/OpTest.sol";
// import {LibOpAdd} from "src/lib/op/math/LibOpAdd.sol";
// import {LibOperand} from "test/lib/operand/LibOperand.sol";

// contract LibOpAddTest is OpTest {
//     /// Directly test the integrity logic of LibOpAdd. This tests the happy
//     /// path where the inputs and calc match.
//     function testOpAddIntegrityHappy(IntegrityCheckState memory state, uint8 inputs, uint16 operandData)
//         external
//         pure
//     {
//         inputs = uint8(bound(inputs, 2, 0x0F));
//         (uint256 calcInputs, uint256 calcOutputs) = LibOpAdd.integrity(state, LibOperand.build(inputs, 1, operandData));

//         assertEq(calcInputs, inputs);
//         assertEq(calcOutputs, 1);
//     }

// /// Directly test the integrity logic of LibOpAdd. This tests the unhappy
// /// path where the operand is invalid due to 0 inputs.
// function testOpAddIntegrityUnhappyZeroInputs(IntegrityCheckState memory state) external pure {
//     (uint256 calcInputs, uint256 calcOutputs) = LibOpAdd.integrity(state, Operand.wrap(0));
//     // Calc inputs will be minimum 2.
//     assertEq(calcInputs, 2);
//     assertEq(calcOutputs, 1);
// }

// /// Directly test the integrity logic of LibOpAdd. This tests the unhappy
// /// path where the operand is invalid due to 1 inputs.
// function testOpAddIntegrityUnhappyOneInput(IntegrityCheckState memory state) external pure {
//     (uint256 calcInputs, uint256 calcOutputs) = LibOpAdd.integrity(state, Operand.wrap(0x010000));
//     // Calc inputs will be minimum 2.
//     assertEq(calcInputs, 2);
//     assertEq(calcOutputs, 1);
// }

//     /// Directly test the runtime logic of LibOpAdd.
//     function testOpAddRun(uint256[] memory inputs) external {
//         InterpreterState memory state = opTestDefaultInterpreterState();
//         vm.assume(inputs.length >= 2);
//         vm.assume(inputs.length <= 0x0F);
//         Operand operand = LibOperand.build(uint8(inputs.length), 1, 0);
//         uint256 overflows = 0;
//         unchecked {
//             uint256 a = inputs[0];
//             for (uint256 i = 1; i < inputs.length; i++) {
//                 uint256 c = a + inputs[i];
//                 if (c < a) {
//                     overflows++;
//                 }
//                 a = c;
//             }
//         }
//         if (overflows > 0) {
//             vm.expectRevert(stdError.arithmeticError);
//         }
//         opReferenceCheck(state, operand, LibOpAdd.referenceFn, LibOpAdd.integrity, LibOpAdd.run, inputs);
//     }

//     /// Test the eval of `add` opcode parsed from a string. Tests zero inputs.
//     function testOpAddEvalZeroInputs() external {
//         checkBadInputs("_: add();", 0, 2, 0);
//     }

//     /// Test the eval of `add` opcode parsed from a string. Tests one input.
//     function testOpAddEvalOneInput() external {
//         checkBadInputs("_: add(5e-18);", 1, 2, 1);
//     }

//     function testOpAddEvalZeroOutputs() external {
//         checkBadOutputs(": add(5e-18 6e-18);", 2, 1, 0);
//     }

//     function testOpAddEvalTwoOutput() external {
//         checkBadOutputs("_ _: add(5e-18 6e-18);", 2, 1, 2);
//     }

// /// Test the eval of `add` opcode parsed from a string. Tests two inputs.
// /// Tests the happy path where the addition does not overflow.
// function testOpAddEval2InputsHappy() external view {
//     checkHappy("_: add(5e-18 6e-18);", 11, "5 + 6");
//     checkHappy("_: add(6e-18 5e-18);", 11, "6 + 5");
// }

// /// Test the eval of `add` opcode parsed from a string. Tests two inputs.
// /// Tests that adding 0 to 0 is 0.
// function testOpAddEval2InputsHappyZero() external view {
//     checkHappy("_: add(0 0);", 0, "0 + 0");
// }

// /// Test the eval of `add` opcode parsed from a string. Tests two inputs.
// /// Tests that adding 0 to 1 is 1.
// function testOpAddEval2InputsHappyZeroOne() external view {
//     checkHappy("_: add(0 1e-18);", 1, "0 + 1");
//     checkHappy("_: add(1e-18 0);", 1, "1 + 0");
// }

// /// Test the eval of `add` opcode parsed from a string. Tests two inputs.
// /// Tests that adding 0 to max-value() is max-value().
// function testOpAddEval2InputsHappyZeroMax() external view {
//     checkHappy("_: add(0 max-value());", type(uint256).max, "0 + max-value()");
//     checkHappy("_: add(max-value() 0);", type(uint256).max, "max-value() + 0");
// }

//     /// Test the eval of `add` opcode parsed from a string. Tests two inputs.
//     /// Tests the unhappy path where the addition does overflow.
//     function testOpAddEval2InputsUnhappy() external {
//         checkUnhappyOverflow("_: add(max-value() 1e-18);");
//         checkUnhappyOverflow("_: add(1e-18 max-value());");
//     }

// /// Test the eval of `add` opcode parsed from a string. Tests three inputs.
// /// Tests the happy path where the addition does not overflow.
// function testOpAddEval3InputsHappy() external view {
//     checkHappy("_: add(5e-18 6e-18 7e-18);", 18, "5 + 6 + 7");
//     checkHappy("_: add(6e-18 5e-18 7e-18);", 18, "6 + 5 + 7");
//     checkHappy("_: add(7e-18 6e-18 5e-18);", 18, "7 + 6 + 5");
//     checkHappy("_: add(5e-18 7e-18 6e-18);", 18, "5 + 7 + 6");
//     checkHappy("_: add(6e-18 7e-18 5e-18);", 18, "6 + 7 + 5");
//     checkHappy("_: add(7e-18 5e-18 6e-18);", 18, "7 + 5 + 6");
// }

//     /// Test the eval of `add` opcode parsed from a string. Tests three inputs.
//     /// Tests the unhappy path where the addition does overflow.
//     function testOpAddEval3InputsUnhappy() external {
//         checkUnhappyOverflow("_: add(max-value() 1e-18 1e-18);");
//         checkUnhappyOverflow("_: add(1e-18 max-value() 1e-18);");
//         checkUnhappyOverflow("_: add(1e-18 1e-18 max-value());");
//         checkUnhappyOverflow("_: add(max-value() max-value() 1e-18);");
//         checkUnhappyOverflow("_: add(max-value() 1e-18 max-value());");
//         checkUnhappyOverflow("_: add(1e-18 max-value() max-value());");
//         checkUnhappyOverflow("_: add(max-value() max-value() max-value());");
//         checkUnhappyOverflow("_: add(max-value() 1e-18 0);");
//         checkUnhappyOverflow("_: add(1e-18 max-value() 0);");
//         checkUnhappyOverflow("_: add(1e-18 0 max-value());");
//         checkUnhappyOverflow("_: add(max-value() max-value() 0);");
//         checkUnhappyOverflow("_: add(max-value() 0 max-value());");
//         checkUnhappyOverflow("_: add(0 max-value() max-value());");
//     }

//     /// Test the eval of `add` opcode parsed from a string.
//     /// Tests that operands are disallowed.
//     function testOpAddEvalOperandDisallowed() external {
//         checkDisallowedOperand("_: add<0>(0 0 0);");
//         checkDisallowedOperand("_: add<1>(0 0 0);");
//         checkDisallowedOperand("_: add<2>(0 0 0);");
//         checkDisallowedOperand("_: add<0 0>(0 0 0);");
//         checkDisallowedOperand("_: add<0 1>(0 0 0);");
//         checkDisallowedOperand("_: add<1 0>(0 0 0);");
//     }
// }
