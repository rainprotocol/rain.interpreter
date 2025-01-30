// SPDX-License-Identifier: CAL
pragma solidity =0.8.25;

// import {OpTest, IntegrityCheckState, Operand, InterpreterState, UnexpectedOperand} from "test/abstract/OpTest.sol";
// import {LibOpLog10} from "src/lib/op/math/LibOpLog10.sol";
// import {LibOperand} from "test/lib/operand/LibOperand.sol";

// contract LibOpLog10Test is OpTest {
//     /// Directly test the integrity logic of LibOpLog10.
//     /// Inputs are always 1, outputs are always 1.
//     function testOpLog10Integrity(IntegrityCheckState memory state, Operand operand) external pure {
//         (uint256 calcInputs, uint256 calcOutputs) = LibOpLog10.integrity(state, operand);
//         assertEq(calcInputs, 1);
//         assertEq(calcOutputs, 1);
//     }

//     /// Directly test the runtime logic of LibOpLog10.
//     function testOpLog10Run(uint256 a, uint16 operandData) public view {
//         // e lifted from prb math.
//         a = bound(a, 2_718281828459045235, type(uint64).max - 1e18);
//         InterpreterState memory state = opTestDefaultInterpreterState();

//         Operand operand = LibOperand.build(1, 1, operandData);
//         uint256[] memory inputs = new uint256[](1);
//         inputs[0] = a;

//         opReferenceCheck(state, operand, LibOpLog10.referenceFn, LibOpLog10.integrity, LibOpLog10.run, inputs);
//     }

// /// Test the eval of `log10`.
// function testOpLog10Eval() external view {
//     checkHappy("_: log10(1);", 0, "log10 1");
//     checkHappy("_: log10(2);", 301029995663981195, "log10 2");
//     checkHappy("_: log10(2.718281828459045235);", 434294481903251823, "log2 e");
//     checkHappy("_: log10(3);", 477121254719662432, "log2 3");
//     checkHappy("_: log10(4);", 602059991327962390, "log2 4");
//     checkHappy("_: log10(5);", 698970004336018800, "log2 5");
// }

//     /// Test the eval of `log10` for bad inputs.
//     function testOpLog10ZeroInputs() external {
//         checkBadInputs("_: log10();", 0, 1, 0);
//     }

//     function testOpLog10TwoInputs() external {
//         checkBadInputs("_: log10(1 1);", 2, 1, 2);
//     }

//     function testOpLog10ZeroOutputs() external {
//         checkBadOutputs(": log10(1);", 1, 1, 0);
//     }

//     function testOpLog10TwoOutputs() external {
//         checkBadOutputs("_ _: log10(1);", 1, 1, 2);
//     }

//     /// Test that operand is disallowed.
//     function testOpLog10EvalOperandDisallowed() external {
//         checkUnhappyParse("_: log10<0>(1);", abi.encodeWithSelector(UnexpectedOperand.selector));
//     }
// }
