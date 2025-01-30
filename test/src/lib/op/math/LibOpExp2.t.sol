// SPDX-License-Identifier: CAL
pragma solidity =0.8.25;

// import {OpTest, IntegrityCheckState, Operand, InterpreterState, UnexpectedOperand} from "test/abstract/OpTest.sol";
// import {LibOpExp2} from "src/lib/op/math/LibOpExp2.sol";
// import {LibOperand} from "test/lib/operand/LibOperand.sol";

// contract LibOpExp2Test is OpTest {
//     /// Directly test the integrity logic of LibOpExp2.
//     /// Inputs are always 1, outputs are always 1.
//     function testOpExp2Integrity(IntegrityCheckState memory state, Operand operand) external pure {
//         (uint256 calcInputs, uint256 calcOutputs) = LibOpExp2.integrity(state, operand);
//         assertEq(calcInputs, 1);
//         assertEq(calcOutputs, 1);
//     }

//     /// Directly test the runtime logic of LibOpExp2.
//     function testOpExp2Run(uint256 a, uint16 operandData) public view {
//         a = bound(a, 0, type(uint64).max - 1e18);
//         InterpreterState memory state = opTestDefaultInterpreterState();

//         Operand operand = LibOperand.build(1, 1, operandData);
//         uint256[] memory inputs = new uint256[](1);
//         inputs[0] = a;

//         opReferenceCheck(state, operand, LibOpExp2.referenceFn, LibOpExp2.integrity, LibOpExp2.run, inputs);
//     }

// /// Test the eval of `exp2`.
// function testOpExp2Eval() external view {
//     checkHappy("_: exp2(0);", 1e18, "2^0");
//     checkHappy("_: exp2(1);", 2e18, "2^1");
//     checkHappy("_: exp2(0.5);", 1414213562373095048, "2^0.5");
//     checkHappy("_: exp2(2);", 4e18, "2^2");
//     checkHappy("_: exp2(3);", 8e18, "2^3");
// }

//     /// Test the eval of `exp2` for bad inputs.
//     function testOpExp2EvalBad() external {
//         checkBadInputs("_: exp2();", 0, 1, 0);
//         checkBadInputs("_: exp2(1 1);", 2, 1, 2);
//     }

//     /// Test that operand is disallowed.
//     function testOpExp2EvalOperandDisallowed() external {
//         checkUnhappyParse("_: exp2<0>(1);", abi.encodeWithSelector(UnexpectedOperand.selector));
//     }

//     function testOpExp2ZeroOutputs() external {
//         checkBadOutputs(": exp2(1);", 1, 1, 0);
//     }

//     function testOpExp2TwoOutputs() external {
//         checkBadOutputs("_ _: exp2(1);", 1, 1, 2);
//     }
// }
