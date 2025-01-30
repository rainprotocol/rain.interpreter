// SPDX-License-Identifier: CAL
pragma solidity =0.8.25;

// import {OpTest, IntegrityCheckState, Operand, InterpreterState, UnexpectedOperand} from "test/abstract/OpTest.sol";
// import {LibOpSnapToUnit} from "src/lib/op/math/LibOpSnapToUnit.sol";
// import {LibOperand} from "test/lib/operand/LibOperand.sol";

// contract LibOpSnapToUnitTest is OpTest {
//     /// Directly test the integrity logic of LibOpSnapToUnit.
//     /// Inputs are always 2, outputs are always 1.
//     function testOpSnapToUnitIntegrity(IntegrityCheckState memory state, Operand operand) external pure {
//         (uint256 calcInputs, uint256 calcOutputs) = LibOpSnapToUnit.integrity(state, operand);
//         assertEq(calcInputs, 2);
//         assertEq(calcOutputs, 1);
//     }

//     /// Directly test the runtime logic of LibOpSnapToUnit.
//     function testOpSnapToUnitRun(uint256 threshold, uint256 value) public view {
//         InterpreterState memory state = opTestDefaultInterpreterState();
//         value = bound(value, 0, type(uint64).max - 1e18);

//         Operand operand = LibOperand.build(2, 1, 0);
//         uint256[] memory inputs = new uint256[](2);
//         inputs[0] = threshold;
//         inputs[1] = value;

//         opReferenceCheck(
//             state, operand, LibOpSnapToUnit.referenceFn, LibOpSnapToUnit.integrity, LibOpSnapToUnit.run, inputs
//         );
//     }

// /// Test the eval of `snap-to-unit`.
// function testOpSnapToUnitEval() external view {
//     // If the threshold is 1 then we always floor.
//     checkHappy("_: snap-to-unit(1 1);", 1e18, "1 1");
//     checkHappy("_: snap-to-unit(1 0.5);", 0, "1 0.5");
//     checkHappy("_: snap-to-unit(1 2);", 2e18, "1 2");
//     checkHappy("_: snap-to-unit(1 2.5);", 2e18, "1 2.5");

//         // If the threshold is 0.2 then we floor or ceil anything within the
//         // threshold.
//         checkHappy("_: snap-to-unit(0.2 1);", 1e18, "0.2 1");
//         checkHappy("_: snap-to-unit(0.2 0.5);", 5e17, "0.2 0.5");
//         checkHappy("_: snap-to-unit(0.2 2);", 2e18, "0.2 2");
//         checkHappy("_: snap-to-unit(0.2 0.2);", 0, "0.2 0.2");
//         checkHappy("_: snap-to-unit(0.2 0.8);", 1e18, "0.2 0.8");
//         checkHappy("_: snap-to-unit(0.2 2.5);", 2.5e18, "0.2 2.5");
//         checkHappy("_: snap-to-unit(0.2 3);", 3e18, "0.2 3");
//         checkHappy("_: snap-to-unit(0.2 3.1);", 3e18, "0.2 3.1");
//         checkHappy("_: snap-to-unit(0.2 3.9);", 4e18, "0.2 3.9");
//     }

//     /// Test the eval of `snap-to-unit` for bad inputs.
//     function testOpSnapToUnitEvalBad() external {
//         checkBadInputs("_: snap-to-unit();", 0, 2, 0);
//         checkBadInputs("_: snap-to-unit(1);", 1, 2, 1);
//         checkBadInputs("_: snap-to-unit(1 1 1);", 3, 2, 3);
//     }

//     function testOpSnapToUnitEvalZeroOutputs() external {
//         checkBadOutputs(": snap-to-unit(1 1);", 2, 1, 0);
//     }

//     function testOpSnapToUnitEvalTwoOutputs() external {
//         checkBadOutputs("_ _: snap-to-unit(1 1);", 2, 1, 2);
//     }

//     /// Test that operand is disallowed.
//     function testOpSnapToUnitEvalOperandDisallowed() external {
//         checkUnhappyParse("_: snap-to-unit<0>(1 1);", abi.encodeWithSelector(UnexpectedOperand.selector));
//     }
// }
