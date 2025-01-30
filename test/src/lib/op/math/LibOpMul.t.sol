// SPDX-License-Identifier: CAL
pragma solidity =0.8.25;

// import {LibPointer} from "rain.solmem/lib/LibPointer.sol";
// import {LibOpMul} from "src/lib/op/math/LibOpMul.sol";
// import {Math as OZMath} from "openzeppelin-contracts/contracts/utils/math/Math.sol";
// import {OpTest, IntegrityCheckState, Operand, InterpreterState} from "test/abstract/OpTest.sol";
// import {PRBMath_MulDiv18_Overflow} from "prb-math/Common.sol";
// import {LibWillOverflow} from "rain.math.fixedpoint/lib/LibWillOverflow.sol";
// import {LibOperand} from "test/lib/operand/LibOperand.sol";

// contract LibOpMulTest is OpTest {
//     /// Directly test the integrity logic of LibOpMul. This tests the
//     /// happy path where the inputs input and calc match.
//     function testOpMulIntegrityHappy(IntegrityCheckState memory state, uint8 inputs, uint16 operandData)
//         external
//         pure
//     {
//         inputs = uint8(bound(inputs, 2, 0x0F));
//         (uint256 calcInputs, uint256 calcOutputs) = LibOpMul.integrity(state, LibOperand.build(inputs, 1, operandData));

//         assertEq(calcInputs, inputs);
//         assertEq(calcOutputs, 1);
//     }

// /// Directly test the integrity logic of LibOpMul. This tests the
// /// unhappy path where the operand is invalid due to 0 inputs.
// function testOpMulIntegrityUnhappyZeroInputs(IntegrityCheckState memory state) external pure {
//     (uint256 calcInputs, uint256 calcOutputs) = LibOpMul.integrity(state, Operand.wrap(0));
//     // Calc inputs will be minimum 2.
//     assertEq(calcInputs, 2);
//     assertEq(calcOutputs, 1);
// }

// /// Directly test the integrity logic of LibOpMul. This tests the
// /// unhappy path where the operand is invalid due to 1 inputs.
// function testOpDecimal18MulNPIntegrityUnhappyOneInput(IntegrityCheckState memory state) external pure {
//     (uint256 calcInputs, uint256 calcOutputs) = LibOpMul.integrity(state, Operand.wrap(0x010000));
//     // Calc inputs will be minimum 2.
//     assertEq(calcInputs, 2);
//     assertEq(calcOutputs, 1);
// }

//     /// Directly test the runtime logic of LibOpMul.
//     function testOpMulRun(uint256[] memory inputs) public {
//         InterpreterState memory state = opTestDefaultInterpreterState();
//         vm.assume(inputs.length >= 2);
//         vm.assume(inputs.length <= 0x0F);
//         Operand operand = LibOperand.build(uint8(inputs.length), 1, 0);
//         // This is kinda shitty because it just duplicates what the reference
//         // fn is doing, but because neither PRB nor Open Zeppelin expose a
//         // try/catch for overflow, we have to do this.
//         uint256 a = inputs[0];
//         for (uint256 i = 1; i < inputs.length; i++) {
//             uint256 b = inputs[i];
//             if (LibWillOverflow.mulDivWillOverflow(a, b, 1e18)) {
//                 vm.expectRevert(abi.encodeWithSelector(PRBMath_MulDiv18_Overflow.selector, a, b));
//                 break;
//             }
//             a = OZMath.mulDiv(a, b, 1e18);
//         }
//         opReferenceCheck(state, operand, LibOpMul.referenceFn, LibOpMul.integrity, LibOpMul.run, inputs);
//     }

//     /// Test the eval of `mul` opcode parsed from a string.
//     /// Tests zero inputs.
//     function testOpMulEvalZeroInputs() external {
//         checkBadInputs("_: mul();", 0, 2, 0);
//     }

//     /// Test the eval of `mul` opcode parsed from a string.
//     /// Tests one input.
//     function testOpMulEvalOneInput() external {
//         checkBadInputs("_: mul(5);", 1, 2, 1);
//         checkBadInputs("_: mul(0);", 1, 2, 1);
//         checkBadInputs("_: mul(1);", 1, 2, 1);
//         checkBadInputs("_: mul(max-value());", 1, 2, 1);
//     }

//     function testOpMulZeroOutputs() external {
//         checkBadOutputs(": mul(0 0);", 2, 1, 0);
//     }

//     function testOpMulTwoOutputs() external {
//         checkBadOutputs("_ _: mul(0 0);", 2, 1, 2);
//     }

// /// Test the eval of `mul` opcode parsed from a string.
// /// Tests two inputs.
// /// Tests the happy path where we do not overflow.
// function testOpMulEvalTwoInputsHappy() external view {
//     checkHappy("_: mul(0 1);", 0, "0 1");
//     checkHappy("_: mul(1 1);", 1e18, "1 1");
//     checkHappy("_: mul(1 2);", 2e18, "1 2");
//     checkHappy("_: mul(2 1);", 2e18, "2 1");
//     checkHappy("_: mul(2 2);", 4e18, "2 2");
//     checkHappy("_: mul(2 0.1);", 2e17, "2 0.1");
//     checkHappy("_: mul(1 0.1);", 1e17, "1 0.1");
//     checkHappy("_: mul(1 0.01);", 1e16, "1 0.01");
//     checkHappy("_: mul(0.001 0.001);", 1e12, "0.001 0.001");
//     checkHappy("_: mul(10 10);", 1e20, "10 10");
//     // Test an intermediate overflow.
//     checkHappy("_: mul(1 max-value());", type(uint256).max, "1 max-value()");
// }

//     /// Test the eval of `mul` opcode parsed from a string.
//     /// Tests two inputs.
//     /// Tests the unhappy path where the final result overflows.
//     function testOpMulEvalTwoInputsUnhappyOverflow() external {
//         checkUnhappy(
//             "_: mul(max-value() 10);",
//             abi.encodeWithSelector(PRBMath_MulDiv18_Overflow.selector, type(uint256).max, 1e19)
//         );
//         checkUnhappy("_: mul(1e52 1e12);", abi.encodeWithSelector(PRBMath_MulDiv18_Overflow.selector, 1e70, 1e30));
//     }

// /// Test the eval of `mul` opcode parsed from a string.
// /// Tests three inputs.
// /// Tests the happy path where we do not divide by zero or overflow.
// function testOpMulEvalThreeInputsHappy() external view {
//     checkHappy("_: mul(0 0 0);", 0, "0 0 0");
//     checkHappy("_: mul(1 0 0);", 0, "1 0 0");
//     checkHappy("_: mul(1 1 0);", 0, "1 1 0");
//     checkHappy("_: mul(1 1 1);", 1e18, "1 1 1");
//     checkHappy("_: mul(1 1 2);", 2e18, "1 1 2");
//     checkHappy("_: mul(1 2 1);", 2e18, "1 2 1");
//     checkHappy("_: mul(2 1 1);", 2e18, "2 1 1");
//     checkHappy("_: mul(2 2 2);", 8e18, "2 2 2");
//     checkHappy("_: mul(2 0.1 1);", 2e17, "2 0.1 1");
//     checkHappy("_: mul(1 0.1 1);", 1e17, "1 0.1 1");
//     checkHappy("_: mul(1 0.01 1);", 1e16, "1 0.01 1");
//     checkHappy("_: mul(0.001 0.001 0.001);", 1e9, "0.001 0.001 0.001");
//     checkHappy("_: mul(10 10 10);", 1e21, "10 10 10");
//     // Test an intermediate overflow.
//     checkHappy("_: mul(1 max-value() 1);", type(uint256).max, "1 max-value() 1");
// }

//     /// Test the eval of `mul` opcode parsed from a string.
//     /// Tests three inputs.
//     /// Tests the unhappy path where the final result overflows.
//     function testOpMulEvalThreeInputsUnhappyOverflow() external {
//         checkUnhappy(
//             "_: mul(max-value() 1 10);",
//             abi.encodeWithSelector(PRBMath_MulDiv18_Overflow.selector, type(uint256).max, 1e19)
//         );
//         checkUnhappy("_: mul(1e52 1 1e8);", abi.encodeWithSelector(PRBMath_MulDiv18_Overflow.selector, 1e70, 1e26));
//         checkUnhappy("_: mul(1e52 1e8 1);", abi.encodeWithSelector(PRBMath_MulDiv18_Overflow.selector, 1e70, 1e26));
//     }

//     /// Test the eval of `mul` opcode parsed from a string.
//     /// Tests that operands are disallowed.
//     function testOpMulEvalOperandsDisallowed() external {
//         checkDisallowedOperand("_: mul<0>(1 1 1);");
//         checkDisallowedOperand("_: mul<1>(1 1 1);");
//         checkDisallowedOperand("_: mul<2>(1 1 1);");
//         checkDisallowedOperand("_: mul<0 0>(1 1 1);");
//         checkDisallowedOperand("_: mul<0 1>(1 1 1);");
//         checkDisallowedOperand("_: mul<1 0>(1 1 1);");
//     }
// }
