// SPDX-License-Identifier: CAL
pragma solidity =0.8.25;

// import {OpTest, IntegrityCheckState, Operand, InterpreterState, UnexpectedOperand} from "test/abstract/OpTest.sol";
// import {LibOpHeadroom} from "src/lib/op/math/LibOpHeadroom.sol";
// import {LibOperand} from "test/lib/operand/LibOperand.sol";

// contract LibOpHeadroomTest is OpTest {
//     /// Directly test the integrity logic of LibOpHeadroom.
//     /// Inputs are always 1, outputs are always 1.
//     function testOpHeadroomIntegrity(IntegrityCheckState memory state, Operand operand) external pure {
//         (uint256 calcInputs, uint256 calcOutputs) = LibOpHeadroom.integrity(state, operand);
//         assertEq(calcInputs, 1);
//         assertEq(calcOutputs, 1);
//     }

//     /// Directly test the runtime logic of LibOpHeadroom.
//     function testOpHeadroomRun(uint256 a, uint16 operandData) public view {
//         a = bound(a, 0, type(uint64).max - 1e18);
//         InterpreterState memory state = opTestDefaultInterpreterState();

//         Operand operand = LibOperand.build(1, 1, operandData);
//         uint256[] memory inputs = new uint256[](1);
//         inputs[0] = a;

//         opReferenceCheck(state, operand, LibOpHeadroom.referenceFn, LibOpHeadroom.integrity, LibOpHeadroom.run, inputs);
//     }

// /// Test the eval of `headroom`.
// function testOpHeadroomEval() external view {
//     checkHappy("_: headroom(0);", 1e18, "0");
//     checkHappy("_: headroom(1);", 1e18, "1");
//     checkHappy("_: headroom(0.5);", 0.5e18, "0.5");
//     checkHappy("_: headroom(2);", 1e18, "2");
//     checkHappy("_: headroom(3);", 1e18, "3");
//     checkHappy("_: headroom(3.8);", 0.2e18, "3.8");
// }

//     /// Test the eval of `headroom` for bad inputs.
//     function testOpHeadroomZeroInputs() external {
//         checkBadInputs("_: headroom();", 0, 1, 0);
//     }

//     function testOpHeadroomTwoInputs() external {
//         checkBadInputs("_: headroom(1 1);", 2, 1, 2);
//     }

//     function testOpHeadroomZeroOutputs() external {
//         checkBadOutputs(": headroom(1);", 1, 1, 0);
//     }

//     function testOpHeadroomTwoOutputs() external {
//         checkBadOutputs("_ _: headroom(1);", 1, 1, 2);
//     }

//     /// Test that operand is disallowed.
//     function testOpHeadroomEvalOperandDisallowed() external {
//         checkUnhappyParse("_: headroom<0>(1);", abi.encodeWithSelector(UnexpectedOperand.selector));
//     }
// }
