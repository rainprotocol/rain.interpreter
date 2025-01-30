// SPDX-License-Identifier: CAL
pragma solidity =0.8.25;

// import {OpTest, IntegrityCheckState, Operand, InterpreterState, UnexpectedOperand} from "test/abstract/OpTest.sol";
// import {LibOpLinearGrowth} from "src/lib/op/math/growth/LibOpLinearGrowth.sol";
// import {LibOperand} from "test/lib/operand/LibOperand.sol";

// contract LibOpLinearGrowthTest is OpTest {
//     /// Directly test the integrity logic of LibOpLinearGrowth.
//     /// Inputs are always 3, outputs are always 1.
//     function testOpLinearGrowthIntegrity(IntegrityCheckState memory state, Operand operand) external pure {
//         (uint256 calcInputs, uint256 calcOutputs) = LibOpLinearGrowth.integrity(state, operand);
//         assertEq(calcInputs, 3);
//         assertEq(calcOutputs, 1);
//     }

//     /// Directly test the runtime logic of LibOpLinearGrowth.
//     function testOpLinearGrowthRun(uint256 a, uint256 r, uint256 t, uint16 operandData) public view {
//         // @TODO This is a hack to cover some range that we can definitely
//         // handle but it doesn't cover the full range of the function.
//         a = bound(a, 0, type(uint128).max);
//         r = bound(r, 0, type(uint128).max);
//         // PRB math can't reliably handle t beyond 44e18 with a and r both up to
//         // ~18e18 (uint64 max).
//         t = bound(t, 0, type(uint64).max);
//         InterpreterState memory state = opTestDefaultInterpreterState();

//         Operand operand = LibOperand.build(3, 1, operandData);
//         uint256[] memory inputs = new uint256[](3);
//         inputs[0] = a;
//         inputs[1] = r;
//         inputs[2] = t;

//         opReferenceCheck(
//             state, operand, LibOpLinearGrowth.referenceFn, LibOpLinearGrowth.integrity, LibOpLinearGrowth.run, inputs
//         );
//     }

// /// Test the eval of `linear-growth`.
// function testOpLinearGrowthEval() external view {
//     checkHappy("_: linear-growth(0 0 0);", 0, "0 0 0");
//     checkHappy("_: linear-growth(0 0.1 0);", 0, "0 0.1 0");
//     checkHappy("_: linear-growth(0 0.1 1);", 1e17, "0 0.1 1");
//     checkHappy("_: linear-growth(1 0.1 0);", 1e18, "1 0.1 0");
//     checkHappy("_: linear-growth(1 0.1 1);", 1.1e18, "1 0.1 1");
//     checkHappy("_: linear-growth(1 0.1 2);", 1.2e18, "1 0.1 2");
//     checkHappy("_: linear-growth(1 0.1 2.5);", 1.25e18, "1 0.1 2.5");
//     checkHappy("_: linear-growth(1 0 2);", 1e18, "1 0 2");
//     checkHappy("_: linear-growth(1 0.1 0.5);", 1.05e18, "1 0.1 0.5");
//     checkHappy("_: linear-growth(2 0.1 0);", 2e18, "2 0.1 0");
//     checkHappy("_: linear-growth(2 0.1 1);", 2.1e18, "2 0.1 1");
//     checkHappy("_: linear-growth(2 0.1 2);", 2.2e18, "2 0.1 2");
// }

//     function testOpLinearGrowthEvalZeroInputs() external {
//         checkBadInputs(": linear-growth();", 0, 3, 0);
//     }

//     function testOpLinearGrowthEvalOneInput() external {
//         checkBadInputs("_: linear-growth(1);", 1, 3, 1);
//     }

//     function testOpLinearGrowthEvalTwoInputs() external {
//         checkBadInputs("_: linear-growth(1 0);", 2, 3, 2);
//     }

//     function testOpLinearGrowthEvalFourInputs() external {
//         checkBadInputs("_: linear-growth(1 0 0 1);", 4, 3, 4);
//     }

//     function testOpLinearGrowthEvalZeroOutputs() external {
//         checkBadOutputs(": linear-growth(1 0 0);", 3, 1, 0);
//     }

//     function testOpLinearGrowthEvalTwoOutputs() external {
//         checkBadOutputs("_ _: linear-growth(1 0 0);", 3, 1, 2);
//     }

//     /// Test that operand is disallowed.
//     function testOpLinearGrowthEvalOperandDisallowed() external {
//         checkUnhappyParse("_: linear-growth<0>(1 0 0);", abi.encodeWithSelector(UnexpectedOperand.selector));
//     }
// }
