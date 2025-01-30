// SPDX-License-Identifier: CAL
pragma solidity =0.8.25;

// import {OpTest, IntegrityCheckState, Operand, InterpreterState, UnexpectedOperand} from "test/abstract/OpTest.sol";
// import {LibOpLog2} from "src/lib/op/math/LibOpLog2.sol";
// import {LibOperand} from "test/lib/operand/LibOperand.sol";

// contract LibOpLog2Test is OpTest {
//     /// Directly test the integrity logic of LibOpLog2.
//     /// Inputs are always 1, outputs are always 1.
//     function testOpLog2Integrity(IntegrityCheckState memory state, Operand operand) external pure {
//         (uint256 calcInputs, uint256 calcOutputs) = LibOpLog2.integrity(state, operand);
//         assertEq(calcInputs, 1);
//         assertEq(calcOutputs, 1);
//     }

//     /// Directly test the runtime logic of LibOpLog2.
//     function testOpLog2Run(uint256 a) public view {
//         // e lifted from prb math.
//         a = bound(a, 2_718281828459045235, type(uint64).max - 1e18);
//         InterpreterState memory state = opTestDefaultInterpreterState();

//         Operand operand = LibOperand.build(1, 1, 0);
//         uint256[] memory inputs = new uint256[](1);
//         inputs[0] = a;

//         opReferenceCheck(state, operand, LibOpLog2.referenceFn, LibOpLog2.integrity, LibOpLog2.run, inputs);
//     }

// /// Test the eval of `log2`.
// function testOpLog2Eval() external view {
//     // Any number less than 2 other than 1 is negative which doesn't exist
//     // in unsigned integers.
//     checkHappy("_: log2(1);", 0, "log2 1");
//     checkHappy("_: log2(2);", 1e18, "log2 2");
//     checkHappy("_: log2(2.718281828459045235);", 1442695040888963394, "log2 e");
//     checkHappy("_: log2(3);", 1584962500721156166, "log2 3");
//     checkHappy("_: log2(4);", 2000000000000000000, "log2 4");
//     checkHappy("_: log2(5);", 2321928094887362334, "log2 5");
// }

//     /// Test the eval of `log2` for bad inputs.
//     function testOpLog2ZeroInputs() external {
//         checkBadInputs("_: log2();", 0, 1, 0);
//     }

//     function testOpLog2TwoInputs() external {
//         checkBadInputs("_: log2(1 1);", 2, 1, 2);
//     }

//     function testOpLog2ZeroOutputs() external {
//         checkBadOutputs(": log2(1);", 1, 1, 0);
//     }

//     function testOpLog2TwoOutputs() external {
//         checkBadOutputs("_ _: log2(1);", 1, 1, 2);
//     }

//     /// Test that operand is disallowed.
//     function testOpLog2EvalOperandDisallowed() external {
//         checkUnhappyParse("_: log2<0>(1);", abi.encodeWithSelector(UnexpectedOperand.selector));
//     }
// }
