// SPDX-License-Identifier: CAL
pragma solidity =0.8.25;

// import {OpTest, IntegrityCheckState, Operand, InterpreterState, UnexpectedOperand} from "test/abstract/OpTest.sol";
// import {LibOpExp} from "src/lib/op/math/LibOpExp.sol";
// import {LibOperand} from "test/lib/operand/LibOperand.sol";

// contract LibOpExpTest is OpTest {
//     /// Directly test the integrity logic of LibOpExp.
//     /// Inputs are always 1, outputs are always 1.
//     function testOpExpIntegrity(IntegrityCheckState memory state, Operand operand) external pure {
//         (uint256 calcInputs, uint256 calcOutputs) = LibOpExp.integrity(state, operand);
//         assertEq(calcInputs, 1);
//         assertEq(calcOutputs, 1);
//     }

//     /// Directly test the runtime logic of LibOpExp.
//     function testOpExpRun(uint256 a, uint16 operandData) public view {
//         a = bound(a, 0, type(uint64).max - 1e18);
//         InterpreterState memory state = opTestDefaultInterpreterState();

//         Operand operand = LibOperand.build(1, 1, operandData);
//         uint256[] memory inputs = new uint256[](1);
//         inputs[0] = a;

//         opReferenceCheck(state, operand, LibOpExp.referenceFn, LibOpExp.integrity, LibOpExp.run, inputs);
//     }

// /// Test the eval of `exp`.
// function testOpExpEval() external view {
//     checkHappy("_: exp(0);", 1e18, "e^0");
//     checkHappy("_: exp(1);", 2718281828459045234, "e^1");
//     checkHappy("_: exp(0.5);", 1648721270700128145, "e^0.5");
//     checkHappy("_: exp(2);", 7389056098930650223, "e^2");
//     checkHappy("_: exp(3);", 20085536923187667724, "e^3");
// }

//     /// Test the eval of `exp` for bad inputs.
//     function testOpExpEvalZeroInputs() external {
//         checkBadInputs("_: exp();", 0, 1, 0);
//     }

//     function testOpExpEvalTwoInputs() external {
//         checkBadInputs("_: exp(1 1);", 2, 1, 2);
//     }

//     function testOpExpZeroOutputs() external {
//         checkBadOutputs(": exp(1);", 1, 1, 0);
//     }

//     function testOpExpTwoOutputs() external {
//         checkBadOutputs("_ _: exp(1);", 1, 1, 2);
//     }

//     /// Test that operand is disallowed.
//     function testOpExpEvalOperandDisallowed() external {
//         checkUnhappyParse("_: exp<0>(1);", abi.encodeWithSelector(UnexpectedOperand.selector));
//     }
// }
