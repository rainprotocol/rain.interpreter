// SPDX-License-Identifier: CAL
pragma solidity =0.8.25;

// import {OpTest, IntegrityCheckState, Operand, InterpreterState, UnexpectedOperand} from "test/abstract/OpTest.sol";
// import {LibOpLn} from "src/lib/op/math/LibOpLn.sol";
// import {LibOperand} from "test/lib/operand/LibOperand.sol";

// contract LibOpLnTest is OpTest {
//     /// Directly test the integrity logic of LibOpLn.
//     /// Inputs are always 1, outputs are always 1.
//     function testOpLnIntegrity(IntegrityCheckState memory state, Operand operand) external pure {
//         (uint256 calcInputs, uint256 calcOutputs) = LibOpLn.integrity(state, operand);
//         assertEq(calcInputs, 1);
//         assertEq(calcOutputs, 1);
//     }

//     /// Directly test the runtime logic of LibOpLn.
//     function testOpLnRun(uint256 a, uint16 operandData) public view {
//         // e lifted from prb math.
//         a = bound(a, 2_718281828459045235, type(uint64).max - 1e18);
//         InterpreterState memory state = opTestDefaultInterpreterState();

//         Operand operand = LibOperand.build(1, 1, operandData);
//         uint256[] memory inputs = new uint256[](1);
//         inputs[0] = a;

//         opReferenceCheck(state, operand, LibOpLn.referenceFn, LibOpLn.integrity, LibOpLn.run, inputs);
//     }

// /// Test the eval of `ln`.
// function testOpLnEval() external view {
//     // Any number less than e other than 1 is negative which doesn't exist
//     // in unsigned integers.
//     checkHappy("_: ln(1);", 0, "ln 1");
//     checkHappy("_: ln(2.718281828459045235);", 999999999999999990, "ln e");
//     checkHappy("_: ln(3);", 1098612288668109680, "ln 3");
//     checkHappy("_: ln(4);", 1386294361119890619, "ln 4");
//     checkHappy("_: ln(5);", 1609437912434100365, "ln 5");
// }

//     /// Test the eval of `ln` for bad inputs.
//     function testOpLnZeroInputs() external {
//         checkBadInputs("_: ln();", 0, 1, 0);
//     }

//     function testOpLnTwoInputs() external {
//         checkBadInputs("_: ln(1 1);", 2, 1, 2);
//     }

//     function testOpLnZeroOutputs() external {
//         checkBadOutputs(": ln(1);", 1, 1, 0);
//     }

//     function testOpLnTwoOutputs() external {
//         checkBadOutputs("_ _: ln(1);", 1, 1, 2);
//     }

//     /// Test that operand is disallowed.
//     function testOpLnEvalOperandDisallowed() external {
//         checkUnhappyParse("_: ln<0>(1);", abi.encodeWithSelector(UnexpectedOperand.selector));
//     }
// }
