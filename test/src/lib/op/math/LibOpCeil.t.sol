// SPDX-License-Identifier: CAL
pragma solidity =0.8.25;

// import {OpTest, IntegrityCheckState, Operand, InterpreterState, UnexpectedOperand} from "test/abstract/OpTest.sol";
// import {LibOpCeil} from "src/lib/op/math/LibOpCeil.sol";
// import {LibOperand} from "test/lib/operand/LibOperand.sol";

// contract LibOpCeilTest is OpTest {
//     /// Directly test the integrity logic of LibOpCeil.
//     /// Inputs are always 1, outputs are always 1.
//     function testOpCeilIntegrity(IntegrityCheckState memory state, Operand operand) external pure {
//         (uint256 calcInputs, uint256 calcOutputs) = LibOpCeil.integrity(state, operand);
//         assertEq(calcInputs, 1);
//         assertEq(calcOutputs, 1);
//     }

//     /// Directly test the runtime logic of LibOpCeil.
//     function testOpCeilRun(uint256 a, uint16 operandData) public view {
//         a = bound(a, 0, type(uint64).max - 1e18);
//         InterpreterState memory state = opTestDefaultInterpreterState();

//         Operand operand = LibOperand.build(1, 1, operandData);
//         uint256[] memory inputs = new uint256[](1);
//         inputs[0] = a;

//         opReferenceCheck(state, operand, LibOpCeil.referenceFn, LibOpCeil.integrity, LibOpCeil.run, inputs);
//     }

// /// Test the eval of `ceil`.
// function testOpCeilEval() external view {
//     checkHappy("_: ceil(0);", 0, "0");
//     checkHappy("_: ceil(1);", 1e18, "1");
//     checkHappy("_: ceil(0.5);", 1e18, "0.5");
//     checkHappy("_: ceil(2);", 2e18, "2");
//     checkHappy("_: ceil(2.5);", 3e18, "2.5");
// }

//     /// Test the eval of `ceil` for bad inputs.
//     function testOpCeilZeroInputs() external {
//         checkBadInputs("_: ceil();", 0, 1, 0);
//     }

//     function testOpCeilTwoInputs() external {
//         checkBadInputs("_: ceil(1 1);", 2, 1, 2);
//     }

//     function testOpCeilZeroOutputs() external {
//         checkBadOutputs(": ceil(1);", 1, 1, 0);
//     }

//     function testOpCeilTwoOutputs() external {
//         checkBadOutputs("_ _: ceil(1);", 1, 1, 2);
//     }

//     /// Test that operand is disallowed.
//     function testOpCeilEvalOperandDisallowed() external {
//         checkUnhappyParse("_: ceil<0>(1);", abi.encodeWithSelector(UnexpectedOperand.selector));
//     }
// }
