// SPDX-License-Identifier: CAL
pragma solidity =0.8.25;

// import {LibPointer} from "rain.solmem/lib/LibPointer.sol";

// import {Math as OZMath} from "openzeppelin-contracts/contracts/utils/math/Math.sol";
// import {OpTest, IntegrityCheckState, InterpreterState, Operand, stdError} from "test/abstract/OpTest.sol";
// import {PRBMath_MulDiv_Overflow} from "prb-math/Common.sol";
// import {LibWillOverflow} from "rain.math.fixedpoint/lib/LibWillOverflow.sol";
// import {LibOpDiv} from "src/lib/op/math/LibOpDiv.sol";
// import {LibOperand} from "test/lib/operand/LibOperand.sol";

// contract LibOpDivTest is OpTest {
//     /// Directly test the integrity logic of LibOpDiv. This tests the
//     /// happy path where the inputs input and calc match.
//     function testOpDivIntegrityHappy(IntegrityCheckState memory state, uint8 inputs, uint16 operandData)
//         external
//         pure
//     {
//         inputs = uint8(bound(inputs, 2, 0x0F));
//         (uint256 calcInputs, uint256 calcOutputs) = LibOpDiv.integrity(state, LibOperand.build(inputs, 1, operandData));

//         assertEq(calcInputs, inputs);
//         assertEq(calcOutputs, 1);
//     }

// /// Directly test the integrity logic of LibOpDiv. This tests the
// /// unhappy path where the operand is invalid due to 0 inputs.
// function testOpDivIntegrityUnhappyZeroInputs(IntegrityCheckState memory state) external pure {
//     (uint256 calcInputs, uint256 calcOutputs) = LibOpDiv.integrity(state, Operand.wrap(0));
//     // Calc inputs will be minimum 2.
//     assertEq(calcInputs, 2);
//     assertEq(calcOutputs, 1);
// }

// /// Directly test the integrity logic of LibOpDiv. This tests the
// /// unhappy path where the operand is invalid due to 1 inputs.
// function testOpDivIntegrityUnhappyOneInput(IntegrityCheckState memory state) external pure {
//     (uint256 calcInputs, uint256 calcOutputs) = LibOpDiv.integrity(state, Operand.wrap(0x110000));
//     // Calc inputs will be minimum 2.
//     assertEq(calcInputs, 2);
//     assertEq(calcOutputs, 1);
// }

//     /// Directly test the runtime logic of LibOpDiv.
//     function testOpDivRun(uint256[] memory inputs) public {
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
//             if (b == 0) {
//                 // There's two different errors that we can get for the same
//                 // basic issue (divide by zero). This is bad juju replicating
//                 // so much of the SUT logic here, but it's the only way to
//                 // test this.
//                 uint256 prod0; // Least significant 256 bits of the product
//                 uint256 prod1; // Most significant 256 bits of the product
//                 uint256 one = 1e18;
//                 assembly ("memory-safe") {
//                     let mm := mulmod(a, one, not(0))
//                     prod0 := mul(a, one)
//                     prod1 := sub(sub(mm, prod0), lt(mm, prod0))
//                 }
//                 if (prod1 == 0) {
//                     vm.expectRevert(stdError.divisionError);
//                     break;
//                 } else {
//                     vm.expectRevert(abi.encodeWithSelector(PRBMath_MulDiv_Overflow.selector, a, 1e18, 0));
//                     break;
//                 }
//             } else if (LibWillOverflow.mulDivWillOverflow(a, 1e18, b)) {
//                 vm.expectRevert(abi.encodeWithSelector(PRBMath_MulDiv_Overflow.selector, a, 1e18, b));
//                 break;
//             }
//             a = OZMath.mulDiv(a, 1e18, b);
//         }
//         opReferenceCheck(state, operand, LibOpDiv.referenceFn, LibOpDiv.integrity, LibOpDiv.run, inputs);
//     }

//     function testDebugOpDivRun() external {
//         uint256[] memory inputs = new uint256[](2);
//         inputs[0] = 115792089237316195423570985008687907853269984665640564039458;
//         testOpDivRun(inputs);
//     }

//     /// Test the eval of `div` opcode parsed from a string.
//     /// Tests zero inputs.
//     function testOpDivEvalZeroInputs() external {
//         checkBadInputs("_: div();", 0, 2, 0);
//     }

//     /// Test the eval of `div` opcode parsed from a string.
//     /// Tests one input.
//     function testOpDivEvalOneInput() external {
//         checkBadInputs("_: div(5);", 1, 2, 1);
//         checkBadInputs("_: div(0);", 1, 2, 1);
//         checkBadInputs("_: div(1);", 1, 2, 1);
//         checkBadInputs("_: div(max-value());", 1, 2, 1);
//     }

// /// Test the eval of `div` opcode parsed from a string.
// /// Tests two inputs.
// /// Tests the happy path where we do not divide by zero or overflow.
// function testOpDivEvalTwoInputsHappy() external view {
//     checkHappy("_: div(0 1);", 0, "0 1");
//     checkHappy("_: div(1 1);", 1e18, "1 1");
//     checkHappy("_: div(1 2);", 5e17, "1 2");
//     checkHappy("_: div(2 1);", 2e18, "2 1");
//     checkHappy("_: div(2 2);", 1e18, "2 2");
//     checkHappy("_: div(2 0.1);", 2e19, "2 0.1");
//     // This one is interesting because it overflows internally before
//     // reaching a final result.
//     checkHappy("_: div(max-value() 1);", type(uint256).max, "max-value() 1");
// }

//     /// Test the eval of `div` opcode parsed from a string.
//     /// Tests two inputs.
//     /// Tests the unhappy path where we divide by zero.
//     function testOpDivEvalTwoInputsUnhappy() external {
//         checkUnhappy("_: div(0 0);", stdError.divisionError);
//         checkUnhappy("_: div(1 0);", stdError.divisionError);
//         checkUnhappy(
//             "_: div(max-value() 0);",
//             abi.encodeWithSelector(PRBMath_MulDiv_Overflow.selector, type(uint256).max, 1e18, 0)
//         );
//     }

//     /// Test the eval of `div` opcode parsed from a string.
//     /// Tests two inputs.
//     /// Tests the unhappy path where the final result overflows.
//     function testOpDivEvalTwoInputsUnhappyOverflow() external {
//         checkUnhappy(
//             "_: div(max-value() 1e-18);",
//             abi.encodeWithSelector(PRBMath_MulDiv_Overflow.selector, type(uint256).max, 1e18, 1)
//         );
//         checkUnhappy("_: div(1e52 1e-8);", abi.encodeWithSelector(PRBMath_MulDiv_Overflow.selector, 1e70, 1e18, 1e10));
//     }

// /// Test the eval of `div` opcode parsed from a string.
// /// Tests three inputs.
// /// Tests the happy path where we do not divide by zero or overflow.
// function testOpDivEvalThreeInputsHappy() external view {
//     checkHappy("_: div(0 1 1);", 0, "0 1 1");
//     checkHappy("_: div(1 1 1);", 1e18, "1 1 1");
//     checkHappy("_: div(1 1 2);", 5e17, "1 1 2");
//     checkHappy("_: div(1 2 1);", 5e17, "1 2 1");
//     checkHappy("_: div(1 2 2);", 25e16, "1 2 2");
//     checkHappy("_: div(1 2 0.1);", 5e18, "1 2 0.1");
//     // This one is interesting because it overflows internally before
//     // reaching a final result.
//     checkHappy("_: div(max-value() 1 1);", type(uint256).max, "max-value() 1 1");
// }

//     /// Test the eval of `div` opcode parsed from a string.
//     /// Tests three inputs.
//     /// Tests the unhappy path where we divide by zero.
//     function testOpDivEvalThreeInputsUnhappy() external {
//         checkUnhappy("_: div(0 0 0);", stdError.divisionError);
//         checkUnhappy("_: div(1 0 0);", stdError.divisionError);
//         checkUnhappy("_: div(1 1 0);", stdError.divisionError);
//         checkUnhappy(
//             "_: div(max-value() 0 0);",
//             abi.encodeWithSelector(PRBMath_MulDiv_Overflow.selector, type(uint256).max, 1e18, 0)
//         );
//     }

//     /// Test the eval of `div` opcode parsed from a string.
//     /// Tests three inputs.
//     /// Tests the unhappy path where the final result overflows.
//     function testOpDivEvalThreeInputsUnhappyOverflow() external {
//         checkUnhappy(
//             "_: div(max-value() 1e-18 1e-18);",
//             abi.encodeWithSelector(PRBMath_MulDiv_Overflow.selector, type(uint256).max, 1e18, 1)
//         );
//         checkUnhappy("_: div(1e52 1 1e-8);", abi.encodeWithSelector(PRBMath_MulDiv_Overflow.selector, 1e70, 1e18, 1e10));
//         checkUnhappy("_: div(1e52 1e-8 1);", abi.encodeWithSelector(PRBMath_MulDiv_Overflow.selector, 1e70, 1e18, 1e10));
//     }

//     /// Test the eval of `div` opcode parsed from a string.
//     /// Tests that operands are disallowed.
//     function testOpDivEvalOperandsDisallowed() external {
//         checkDisallowedOperand("_: div<0>(1 1 1);");
//         checkDisallowedOperand("_: div<1>(1 1 1);");
//         checkDisallowedOperand("_: div<2>(1 1 1);");
//         checkDisallowedOperand("_: div<0 0>(1 1 1);");
//         checkDisallowedOperand("_: div<0 1>(1 1 1);");
//         checkDisallowedOperand("_: div<1 0>(1 1 1);");
//     }

//     function testOpDivEvalZeroOutputs() external {
//         checkBadOutputs(": div(0 1);", 2, 1, 0);
//     }

//     function testOpDivEvalTwoOutputs() external {
//         checkBadOutputs("_ _: div(0 1);", 2, 1, 2);
//     }
// }
