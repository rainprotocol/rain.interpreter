// SPDX-License-Identifier: CAL
pragma solidity =0.8.25;

// import {LibUint256Array} from "rain.solmem/lib/LibUint256Array.sol";

// import {OpTest, IntegrityCheckState, InterpreterState} from "test/abstract/OpTest.sol";
// import {LibContext} from "rain.interpreter.interface/lib/caller/LibContext.sol";
// import {UnexpectedOperand} from "src/error/ErrParse.sol";
// import {LibOpMin} from "src/lib/op/math/LibOpMin.sol";
// import {LibOperand, Operand} from "test/lib/operand/LibOperand.sol";

// contract LibOpMinTest is OpTest {
//     using LibUint256Array for uint256[];

// /// Directly test the integrity logic of LibOpMin. This tests the happy
// /// path where the inputs input and calc match.
// function testOpMinIntegrityHappy(IntegrityCheckState memory state, uint8 inputs, uint16 operandData)
//     external
//     pure
// {
//     inputs = uint8(bound(inputs, 2, 0x0F));
//     (uint256 calcInputs, uint256 calcOutputs) = LibOpMin.integrity(state, LibOperand.build(inputs, 1, operandData));

//         assertEq(calcInputs, inputs);
//         assertEq(calcOutputs, 1);
//     }

// /// Directly test the integrity logic of LibOpMin. This tests the unhappy
// /// path where the operand is invalid due to 0 inputs.
// function testOpMinIntegrityUnhappyZeroInputs(IntegrityCheckState memory state) external pure {
//     (uint256 calcInputs, uint256 calcOutputs) = LibOpMin.integrity(state, Operand.wrap(0));
//     // Calc inputs will be minimum 2.
//     assertEq(calcInputs, 2);
//     assertEq(calcOutputs, 1);
// }

// /// Directly test the integrity logic of LibOpMin. This tests the unhappy
// /// path where the operand is invalid due to 1 inputs.
// function testOpMinIntegrityUnhappyOneInput(IntegrityCheckState memory state) external pure {
//     (uint256 calcInputs, uint256 calcOutputs) = LibOpMin.integrity(state, Operand.wrap(0x010000));
//     // Calc inputs will be minimum 2.
//     assertEq(calcInputs, 2);
//     assertEq(calcOutputs, 1);
// }

// /// Directly test the runtime logic of LibOpMin.
// function testOpMinRun(uint256[] memory inputs, uint16 operandData) external view {
//     InterpreterState memory state = opTestDefaultInterpreterState();
//     vm.assume(inputs.length >= 2);
//     vm.assume(inputs.length <= 0x0F);
//     Operand operand = LibOperand.build(uint8(inputs.length), 1, operandData);
//     opReferenceCheck(state, operand, LibOpMin.referenceFn, LibOpMin.integrity, LibOpMin.run, inputs);
// }

//     /// Test the eval of `min` opcode parsed from a string. Tests zero inputs.
//     function testOpMinEvalZeroInputs() external {
//         checkBadInputs("_: min();", 0, 2, 0);
//     }

//     /// Test the eval of `min` opcode parsed from a string. Tests one input.
//     function testOpMinEvalOneInput() external {
//         checkBadInputs("_: min(5e-18);", 1, 2, 1);
//         checkBadInputs("_: min(0);", 1, 2, 1);
//         checkBadInputs("_: min(1e-18);", 1, 2, 1);
//         checkBadInputs("_: min(max-value());", 1, 2, 1);
//     }

// /// Test the eval of `min` opcode parsed from a string. Tests two inputs.
// function testOpMinEval2InputsHappy() external view {
//     checkHappy("_: min(0 0);", 0, "0 > 0 ? 0 : 1");
//     checkHappy("_: min(1e-18 0);", 0, "1 > 0 ? 1 : 0");
//     checkHappy("_: min(max-value() 0);", 0, "max-value() > 0 ? max-value() : 0");
//     checkHappy("_: min(0 1e-18);", 0, "0 > 1 ? 0 : 1");
//     checkHappy("_: min(1e-18 1e-18);", 1, "1 > 1 ? 1 : 1");
//     checkHappy("_: min(0 max-value());", 0, "0 > max-value() ? 0 : max-value()");
//     checkHappy("_: min(1e-18 max-value());", 1, "1 > max-value() ? 1 : max-value()");
//     checkHappy("_: min(max-value() 1e-18);", 1, "1 > max-value() ? 1 : max-value()");
//     checkHappy(
//         "_: min(max-value() max-value());",
//         type(uint256).max,
//         "max-value() > max-value() ? max-value() : max-value()"
//     );
//     checkHappy("_: min(0 2e-18);", 0, "0 > 2 ? 0 : 2");
//     checkHappy("_: min(1e-18 2e-18);", 1, "1 > 2 ? 1 : 2");
//     checkHappy("_: min(2e-18 2e-18);", 2, "2 > 2 ? 2 : 2");
// }

// /// Test the eval of `min` opcode parsed from a string. Tests three inputs.
// function testOpMinEval3InputsHappy() external view {
//     checkHappy("_: min(0 0 0);", 0, "0 0 0");
//     checkHappy("_: min(1e-18 0 0);", 0, "1 0 0");
//     checkHappy("_: min(2e-18 0 0);", 0, "2 0 0");
//     checkHappy("_: min(0 1e-18 0);", 0, "0 1 0");
//     checkHappy("_: min(1e-18 1e-18 0);", 0, "1 1 0");
//     checkHappy("_: min(2e-18 1e-18 0);", 0, "2 1 0");
//     checkHappy("_: min(0 2e-18 0);", 0, "0 2 0");
//     checkHappy("_: min(1e-18 2e-18 0);", 0, "1 2 0");
//     checkHappy("_: min(2e-18 2e-18 0);", 0, "2 2 0");
//     checkHappy("_: min(0 0 1e-18);", 0, "0 0 1");
//     checkHappy("_: min(1e-18 0 1e-18);", 0, "1 0 1");
//     checkHappy("_: min(2e-18 0 1e-18);", 0, "2 0 1");
//     checkHappy("_: min(0 1e-18 1e-18);", 0, "0 1 1");
//     checkHappy("_: min(1e-18 1e-18 1e-18);", 1, "1 1 1");
//     checkHappy("_: min(2e-18 1e-18 1e-18);", 1, "2 1 1");
//     checkHappy("_: min(0 2e-18 1e-18);", 0, "0 2 1");
//     checkHappy("_: min(1e-18 2e-18 1e-18);", 1, "1 2 1");
//     checkHappy("_: min(2e-18 2e-18 1e-18);", 1, "2 2 1");
//     checkHappy("_: min(0 0 2e-18);", 0, "0 0 2");
//     checkHappy("_: min(1e-18 0 2e-18);", 0, "1 0 2");
//     checkHappy("_: min(2e-18 0 2e-18);", 0, "2 0 2");
//     checkHappy("_: min(0 1e-18 2e-18);", 0, "0 1 2");
//     checkHappy("_: min(1e-18 1e-18 2e-18);", 1, "1 1 2");
//     checkHappy("_: min(2e-18 1e-18 2e-18);", 1, "2 1 2");
//     checkHappy("_: min(0 2e-18 2e-18);", 0, "0 2 2");
//     checkHappy("_: min(1e-18 2e-18 2e-18);", 1, "1 2 2");
//     checkHappy("_: min(2e-18 2e-18 2e-18);", 2, "2 2 2");
//     checkHappy("_: min(0 0 max-value());", 0, "0 0 max-value()");
//     checkHappy("_: min(1e-18 0 max-value());", 0, "1 0 max-value()");
//     checkHappy("_: min(2e-18 0 max-value());", 0, "2 0 max-value()");
//     checkHappy("_: min(0 1e-18 max-value());", 0, "0 1 max-value()");
//     checkHappy("_: min(1e-18 1e-18 max-value());", 1, "1 1 max-value()");
//     checkHappy("_: min(2e-18 1e-18 max-value());", 1, "2 1 max-value()");
//     checkHappy("_: min(0 2e-18 max-value());", 0, "0 2 max-value()");
//     checkHappy("_: min(1e-18 2e-18 max-value());", 1, "1 2 max-value()");
//     checkHappy("_: min(2e-18 2e-18 max-value());", 2, "2 2 max-value()");
//     checkHappy("_: min(0 max-value() 0);", 0, "0 max-value() 0");
//     checkHappy("_: min(1e-18 max-value() 0);", 0, "1 max-value() 0");
//     checkHappy("_: min(2e-18 max-value() 0);", 0, "2 max-value() 0");
//     checkHappy("_: min(0 max-value() 1e-18);", 0, "0 max-value() 1");
//     checkHappy("_: min(1e-18 max-value() 1e-18);", 1, "1 max-value() 1");
//     checkHappy("_: min(2e-18 max-value() 1e-18);", 1, "2 max-value() 1");
//     checkHappy("_: min(0 max-value() 2e-18);", 0, "0 max-value() 2");
//     checkHappy("_: min(1e-18 max-value() 2e-18);", 1, "1 max-value() 2");
//     checkHappy("_: min(2e-18 max-value() 2e-18);", 2, "2 max-value() 2");
//     checkHappy("_: min(0 max-value() max-value());", 0, "0 max-value() max-value()");
//     checkHappy("_: min(1e-18 max-value() max-value());", 1, "1 max-value() max-value()");
//     checkHappy("_: min(2e-18 max-value() max-value());", 2, "2 max-value() max-value()");
//     checkHappy("_: min(max-value() 0 0);", 0, "max-value() 0 0");
//     checkHappy("_: min(max-value() 1e-18 0);", 0, "max-value() 1 0");
//     checkHappy("_: min(max-value() 2e-18 0);", 0, "max-value() 2 0");
//     checkHappy("_: min(max-value() 0 1e-18);", 0, "max-value() 0 1");
//     checkHappy("_: min(max-value() 1e-18 1e-18);", 1, "max-value() 1 1");
//     checkHappy("_: min(max-value() 2e-18 1e-18);", 1, "max-value() 2 1");
//     checkHappy("_: min(max-value() 0 2e-18);", 0, "max-value() 0 2");
//     checkHappy("_: min(max-value() 1e-18 2e-18);", 1, "max-value() 1 2");
//     checkHappy("_: min(max-value() 2e-18 2e-18);", 2, "max-value() 2 2");
//     checkHappy("_: min(max-value() 0 max-value());", 0, "max-value() 0 max-value()");
//     checkHappy("_: min(max-value() 1e-18 max-value());", 1, "max-value() 1 max-value()");
//     checkHappy("_: min(max-value() 2e-18 max-value());", 2, "max-value() 2 max-value()");
//     checkHappy("_: min(max-value() max-value() 0);", 0, "max-value() max-value() 0");
//     checkHappy("_: min(max-value() max-value() 1e-18);", 1, "max-value() max-value() 1");
//     checkHappy("_: min(max-value() max-value() 2e-18);", 2, "max-value() max-value() 2");
//     checkHappy(
//         "_: min(max-value() max-value() max-value());", type(uint256).max, "max-value() max-value() max-value()"
//     );
// }

//     /// Test the eval of `min` opcode parsed from a string.
//     /// Tests that operands are disallowed.
//     function testOpMinEvalOperandDisallowed() external {
//         checkDisallowedOperand("_: min<0>(0 0 0);");
//         checkDisallowedOperand("_: min<1>(0 0 0);");
//         checkDisallowedOperand("_: min<2>(0 0 0);");
//         checkDisallowedOperand("_: min<3 1>(0 0 0);");
//     }
// }
