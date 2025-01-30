// SPDX-License-Identifier: CAL
pragma solidity =0.8.25;

// import {OpTest, IntegrityCheckState, Operand, InterpreterState, UnexpectedOperand} from "test/abstract/OpTest.sol";
// import {LibOpGm} from "src/lib/op/math/LibOpGm.sol";
// import {LibOperand} from "test/lib/operand/LibOperand.sol";

// contract LibOpGmTest is OpTest {
//     /// Directly test the integrity logic of LibOpGm.
//     /// Inputs are always 2, outputs are always 1.
//     function testOpGmIntegrity(IntegrityCheckState memory state, Operand operand) external pure {
//         (uint256 calcInputs, uint256 calcOutputs) = LibOpGm.integrity(state, operand);
//         assertEq(calcInputs, 2);
//         assertEq(calcOutputs, 1);
//     }

//     /// Directly test the runtime logic of LibOpGm.
//     function testOpGmRun(uint256 a, uint256 b, uint16 operandData) public view {
//         // @TODO This is a hack to get around the fact that we are very likely
//         // to overflow uint256 if we just fuzz it, and that it's clunky to
//         // determine whether it will overflow or not. Basically the overflow
//         // check is exactly the same as the implementation, including all the
//         // intermediate squaring, so it seems like a bit of circular logic to
//         // do things that way.
//         a = bound(a, 0, type(uint64).max);
//         b = bound(b, 0, 10);
//         InterpreterState memory state = opTestDefaultInterpreterState();

//         Operand operand = LibOperand.build(2, 1, operandData);
//         uint256[] memory inputs = new uint256[](2);
//         inputs[0] = a;
//         inputs[1] = b;

//         opReferenceCheck(state, operand, LibOpGm.referenceFn, LibOpGm.integrity, LibOpGm.run, inputs);
//     }

// /// Test the eval of `gm`.
// function testOpGmEval() external view {
//     checkHappy("_: gm(0 0);", 0, "0 0");
//     checkHappy("_: gm(0 1);", 0, "0 1");
//     checkHappy("_: gm(1 0);", 0, "1 0");
//     checkHappy("_: gm(1 1);", 1e18, "1 1");
//     checkHappy("_: gm(1 2);", 1414213562373095048, "1 2");
//     checkHappy("_: gm(2 2);", 2e18, "2 2");
//     checkHappy("_: gm(2 3);", 2449489742783178098, "2 3");
//     checkHappy("_: gm(2 4);", 2828427124746190097, "2 4");
//     checkHappy("_: gm(4 0.5);", 1414213562373095048, "4 0.5");
// }

//     /// Test the eval of `gm` for bad inputs.
//     function testOpGmOneInput() external {
//         checkBadInputs("_: gm(1e18);", 1, 2, 1);
//     }

//     function testOpGmThreeInputs() external {
//         checkBadInputs("_: gm(1 1 1);", 3, 2, 3);
//     }

//     function testOpGmZeroOutputs() external {
//         checkBadOutputs(": gm(1 1);", 2, 1, 0);
//     }

//     function testOpGmTwoOutputs() external {
//         checkBadOutputs("_ _: gm(1 1);", 2, 1, 2);
//     }

//     /// Test that operand is disallowed.
//     function testOpGmEvalOperandDisallowed() external {
//         checkUnhappyParse("_: gm<0>(1 1);", abi.encodeWithSelector(UnexpectedOperand.selector));
//     }
// }
