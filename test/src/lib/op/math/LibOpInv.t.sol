// SPDX-License-Identifier: CAL
pragma solidity =0.8.25;

// import {OpTest, IntegrityCheckState, Operand, InterpreterState, UnexpectedOperand} from "test/abstract/OpTest.sol";
// import {LibOpInv} from "src/lib/op/math/LibOpInv.sol";
// import {LibOperand} from "test/lib/operand/LibOperand.sol";

// contract LibOpInvTest is OpTest {
//     /// Directly test the integrity logic of LibOpInv.
//     /// Inputs are always 1, outputs are always 1.
//     function testOpInvIntegrity(IntegrityCheckState memory state, Operand operand) external pure {
//         (uint256 calcInputs, uint256 calcOutputs) = LibOpInv.integrity(state, operand);
//         assertEq(calcInputs, 1);
//         assertEq(calcOutputs, 1);
//     }

//     /// Directly test the runtime logic of LibOpInv.
//     function testOpInvRun(uint256 a, uint16 operandData) public view {
//         // 0 is division by 0.
//         a = bound(a, 1, type(uint64).max - 1e18);
//         InterpreterState memory state = opTestDefaultInterpreterState();

//         Operand operand = LibOperand.build(1, 1, operandData);
//         uint256[] memory inputs = new uint256[](1);
//         inputs[0] = a;

//         opReferenceCheck(state, operand, LibOpInv.referenceFn, LibOpInv.integrity, LibOpInv.run, inputs);
//     }

// /// Test the eval of `inv`.
// function testOpInvEval() external view {
//     checkHappy("_: inv(1);", 1e18, "1");
//     checkHappy("_: inv(0.5);", 2e18, "0.5");
//     checkHappy("_: inv(2);", 0.5e18, "2");
//     checkHappy("_: inv(3);", 333333333333333333, "3");
// }

//     /// Test the eval of `inv` for bad inputs.
//     function testOpInvZeroInputs() external {
//         checkBadInputs("_: inv();", 0, 1, 0);
//     }

//     function testOpInvTwoInputs() external {
//         checkBadInputs("_: inv(1 1);", 2, 1, 2);
//     }

//     function testOpInvZeroOutputs() external {
//         checkBadOutputs(": inv(1);", 1, 1, 0);
//     }

//     function testOpInvTwoOutputs() external {
//         checkBadOutputs("_ _: inv(1);", 1, 1, 2);
//     }

//     /// Test that operand is disallowed.
//     function testOpExpEvalOperandDisallowed() external {
//         checkUnhappyParse("_: inv<0>(1);", abi.encodeWithSelector(UnexpectedOperand.selector));
//     }
// }
