// SPDX-License-Identifier: CAL
pragma solidity =0.8.25;

// import {OpTest, IntegrityCheckState, Operand, InterpreterState, UnexpectedOperand} from "test/abstract/OpTest.sol";
// import {LibOpSqrt} from "src/lib/op/math/LibOpSqrt.sol";
// import {LibOperand} from "test/lib/operand/LibOperand.sol";

// contract LibOpSqrtTest is OpTest {
//     /// Directly test the integrity logic of LibOpSqrt.
//     /// Inputs are always 1, outputs are always 1.
//     function testOpSqrtIntegrity(IntegrityCheckState memory state, Operand operand) external pure {
//         (uint256 calcInputs, uint256 calcOutputs) = LibOpSqrt.integrity(state, operand);
//         assertEq(calcInputs, 1);
//         assertEq(calcOutputs, 1);
//     }

//     /// Directly test the runtime logic of LibOpSqrt.
//     function testOpSqrtRun(uint256 a) public view {
//         a = bound(a, 0, type(uint64).max - 1e18);
//         InterpreterState memory state = opTestDefaultInterpreterState();

//         Operand operand = LibOperand.build(1, 1, 0);
//         uint256[] memory inputs = new uint256[](1);
//         inputs[0] = a;

//         opReferenceCheck(state, operand, LibOpSqrt.referenceFn, LibOpSqrt.integrity, LibOpSqrt.run, inputs);
//     }

// /// Test the eval of `sqrt`.
// function testOpSqrtEval() external view {
//     checkHappy("_: sqrt(0);", 0, "0");
//     checkHappy("_: sqrt(1);", 1e18, "1");
//     checkHappy("_: sqrt(0.5);", 707106781186547524, "0.5");
//     checkHappy("_: sqrt(2);", 1414213562373095048, "2");
//     checkHappy("_: sqrt(2.5);", 1581138830084189665, "2.5");
// }

//     /// Test the eval of `sqrt` for bad inputs.
//     function testOpSqrtEvalBad() external {
//         checkBadInputs("_: sqrt();", 0, 1, 0);
//         checkBadInputs("_: sqrt(1 1);", 2, 1, 2);
//     }

//     function testOpSqrtEvalZeroOutputs() external {
//         checkBadOutputs(": sqrt(1);", 1, 1, 0);
//     }

//     function testOpSqrtEvalTwoOutputs() external {
//         checkBadOutputs("_ _: sqrt(1);", 1, 1, 2);
//     }

//     /// Test that operand is disallowed.
//     function testOpSqrtEvalOperandDisallowed() external {
//         checkUnhappyParse("_: sqrt<0>(1);", abi.encodeWithSelector(UnexpectedOperand.selector));
//     }
// }
