// SPDX-License-Identifier: CAL
pragma solidity =0.8.25;

// import {OpTest, IntegrityCheckState, Operand, InterpreterState, UnexpectedOperand} from "test/abstract/OpTest.sol";
// import {LibOpExponentialGrowth} from "src/lib/op/math/growth/LibOpExponentialGrowth.sol";
// import {LibOperand} from "test/lib/operand/LibOperand.sol";

// contract LibOpExponentialGrowthTest is OpTest {
//     /// Directly test the integrity logic of LibOpExponentialGrowth.
//     /// Inputs are always 3, outputs are always 1.
//     function testOpExponentialGrowthIntegrity(IntegrityCheckState memory state, Operand operand) external pure {
//         (uint256 calcInputs, uint256 calcOutputs) = LibOpExponentialGrowth.integrity(state, operand);
//         assertEq(calcInputs, 3);
//         assertEq(calcOutputs, 1);
//     }

//     /// Directly test the runtime logic of LibOpExponentialGrowth.
//     function testOpExponentialGrowthRun(uint256 a, uint256 r, uint256 t, uint16 operandData) public view {
//         // @TODO This is a hack to cover some range that we can definitely
//         // handle but it doesn't cover the full range of the function.
//         a = bound(a, 0, type(uint64).max);
//         r = bound(r, 0, type(uint64).max);
//         // PRB math can't reliably handle t beyond 44e18 with a and r both up to
//         // ~18e18 (uint64 max).
//         t = bound(t, 0, 44e18);
//         InterpreterState memory state = opTestDefaultInterpreterState();

//         Operand operand = LibOperand.build(3, 1, operandData);
//         uint256[] memory inputs = new uint256[](3);
//         inputs[0] = a;
//         inputs[1] = r;
//         inputs[2] = t;

//         opReferenceCheck(
//             state,
//             operand,
//             LibOpExponentialGrowth.referenceFn,
//             LibOpExponentialGrowth.integrity,
//             LibOpExponentialGrowth.run,
//             inputs
//         );
//     }

// /// Test the eval of `exponential-growth`.
// function testOpExponentialGrowthEval() external view {
//     checkHappy("_: exponential-growth(0 0 0);", 0, "0 0 0");
//     checkHappy("_: exponential-growth(0 0.1 0);", 0, "0 0.1 0");
//     checkHappy("_: exponential-growth(0 0.1 1);", 0, "0 0.1 1");
//     checkHappy("_: exponential-growth(1 0.1 0);", 1e18, "1 0.1 0");
//     checkHappy("_: exponential-growth(1 0.1 1);", 1.1e18, "1 0.1 1");
//     // Not exactly 1.21
//     checkHappy("_: exponential-growth(1 0.1 2);", 1209999999999999974, "1 0.1 2");
//     // Not exactly 1.26905870629
//     checkHappy("_: exponential-growth(1 0.1 2.5);", 1269058706285883337, "1 0.1 2.5");
//     checkHappy("_: exponential-growth(1 0 2);", 1e18, "1 0 2");
//     checkHappy("_: exponential-growth(1 0.1 0.5);", 1048808848170151541, "1 0.1 0.5");
//     checkHappy("_: exponential-growth(2 0.1 0);", 2e18, "2 0.1 0");
//     checkHappy("_: exponential-growth(2 0.1 1);", 2.2e18, "2 0.1 1");
//     // Not exactly 2.42
//     checkHappy("_: exponential-growth(2 0.1 2);", 2419999999999999948, "2 0.1 2");
// }

//     function testOpExponentialGrowthEvalZeroInputs() external {
//         checkBadInputs(": exponential-growth();", 0, 3, 0);
//     }

//     function testOpExponentialGrowthEvalOneInput() external {
//         checkBadInputs("_: exponential-growth(1);", 1, 3, 1);
//     }

//     function testOpExponentialGrowthEvalTwoInputs() external {
//         checkBadInputs("_: exponential-growth(1 0);", 2, 3, 2);
//     }

//     function testOpExponentialGrowthEvalFourInputs() external {
//         checkBadInputs("_: exponential-growth(1 0 0 1);", 4, 3, 4);
//     }

//     function testOpExponentialGrowthEvalZeroOutputs() external {
//         checkBadOutputs(": exponential-growth(1 0 0);", 3, 1, 0);
//     }

//     function testOpExponentialGrowthEvalTwoOutputs() external {
//         checkBadOutputs("_ _: exponential-growth(1 0 0);", 3, 1, 2);
//     }

//     /// Test that operand is disallowed.
//     function testOpExponentialGrowthEvalOperandDisallowed() external {
//         checkUnhappyParse("_: exponential-growth<0>(1 0 0);", abi.encodeWithSelector(UnexpectedOperand.selector));
//     }
// }
