// SPDX-License-Identifier: CAL
pragma solidity =0.8.25;

// import {OpTest, IntegrityCheckState, Operand, InterpreterState, UnexpectedOperand} from "test/abstract/OpTest.sol";
// import {LibOpFloor} from "src/lib/op/math/LibOpFloor.sol";
// import {LibOperand} from "test/lib/operand/LibOperand.sol";

// contract LibOpFloorTest is OpTest {
//     /// Directly test the integrity logic of LibOpFloor.
//     /// Inputs are always 1, outputs are always 1.
//     function testOpFloorIntegrity(IntegrityCheckState memory state, Operand operand) external pure {
//         (uint256 calcInputs, uint256 calcOutputs) = LibOpFloor.integrity(state, operand);
//         assertEq(calcInputs, 1);
//         assertEq(calcOutputs, 1);
//     }

//     /// Directly test the runtime logic of LibOpFloor.
//     function testOpFloorRun(uint256 a, uint16 operandData) public view {
//         a = bound(a, 0, type(uint64).max - 1e18);
//         InterpreterState memory state = opTestDefaultInterpreterState();

//         Operand operand = LibOperand.build(1, 1, operandData);
//         uint256[] memory inputs = new uint256[](1);
//         inputs[0] = a;

//         opReferenceCheck(state, operand, LibOpFloor.referenceFn, LibOpFloor.integrity, LibOpFloor.run, inputs);
//     }

// /// Test the eval of `floor`.
// function testOpFloorEval() external view {
//     checkHappy("_: floor(0);", 0, "0");
//     checkHappy("_: floor(1);", 1e18, "1");
//     checkHappy("_: floor(0.5);", 0, "0.5");
//     checkHappy("_: floor(2);", 2e18, "2");
//     checkHappy("_: floor(3);", 3e18, "3");
//     checkHappy("_: floor(3.8);", 3e18, "3.8");
// }

//     /// Test the eval of `floor` for bad inputs.
//     function testOpFloorZeroInputs() external {
//         checkBadInputs("_: floor();", 0, 1, 0);
//     }

//     function testOpFloorTwoInputs() external {
//         checkBadInputs("_: floor(1 1);", 2, 1, 2);
//     }

//     function testOpFloorZeroOutputs() external {
//         checkBadOutputs(": floor(1);", 1, 1, 0);
//     }

//     function testOpFloorTwoOutputs() external {
//         checkBadOutputs("_ _: floor(1);", 1, 1, 2);
//     }

//     /// Test that operand is disallowed.
//     function testOpFloorEvalOperandDisallowed() external {
//         checkUnhappyParse("_: floor<0>(1);", abi.encodeWithSelector(UnexpectedOperand.selector));
//     }
// }
