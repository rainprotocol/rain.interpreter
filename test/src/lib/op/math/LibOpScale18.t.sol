// SPDX-License-Identifier: CAL
pragma solidity =0.8.25;

// import {OpTest, IntegrityCheckState, InterpreterState, Operand, stdError} from "test/abstract/OpTest.sol";
// import {LibWillOverflow} from "rain.math.fixedpoint/lib/LibWillOverflow.sol";
// import {LibOpScale18} from "src/lib/op/math/LibOpScale18.sol";
// import {LibOperand} from "test/lib/operand/LibOperand.sol";

// contract LibOpScale18Test is OpTest {
//     /// Directly test the integrity logic of LibOpScale18.
//     /// Inputs are always 1, outputs are always 1.
//     function testOpScale18Integrity(IntegrityCheckState memory state, uint8 inputs, uint16 op) external pure {
//         inputs = uint8(bound(inputs, 1, 0x0F));
//         (uint256 calcInputs, uint256 calcOutputs) = LibOpScale18.integrity(state, LibOperand.build(inputs, 1, op));
//         assertEq(calcInputs, 1);
//         assertEq(calcOutputs, 1);
//     }

//     /// Directly test the runtime logic of LibOpScale18.
//     function testOpScale18Run(uint256 scale, uint256 round, uint256 saturate, uint256 value) public {
//         scale = bound(scale, 0, type(uint8).max);
//         round = bound(round, 0, 1);
//         saturate = bound(saturate, 0, 1);
//         uint256 flags = round | (saturate << 1);
//         InterpreterState memory state = opTestDefaultInterpreterState();

//         Operand operand = LibOperand.build(1, 1, uint16((flags << 8) | scale));
//         uint256[] memory inputs = new uint256[](1);
//         inputs[0] = value;

//         if (LibWillOverflow.scale18WillOverflow(value, scale, flags)) {
//             vm.expectRevert(stdError.arithmeticError);
//         }

//         opReferenceCheck(state, operand, LibOpScale18.referenceFn, LibOpScale18.integrity, LibOpScale18.run, inputs);
//     }

//     /// Test the eval of `scale-18`.
//     function testOpScale18Eval() external {
//         // Scale 0 value 0 round 0 saturate 0
//         checkHappy("_: scale-18<0>(0);", 0, "0 0 0 0");
//         // Scale 0 value 0 round 0 saturate 1
//         checkHappy("_: scale-18<0 0 1>(0);", 0, "0 0 0 1");
//         // Scale 0 value 0 round 1 saturate 0
//         checkHappy("_: scale-18<0 1 0>(0);", 0, "0 0 1 0");
//         // Scale 0 value 0 round 1 saturate 1
//         checkHappy("_: scale-18<0 1 1>(0);", 0, "0 0 1 1");
//         // Scale 0 value 1 round 0 saturate 0
//         checkHappy("_: scale-18<0>(1e-18);", 1e18, "0 1 0 0");
//         // Scale 0 value 1 round 0 saturate 1
//         checkHappy("_: scale-18<0 0 1>(1e-18);", 1e18, "0 1 0 1");
//         // Scale 0 value 1 round 1 saturate 0
//         checkHappy("_: scale-18<0 1 0>(1e-18);", 1e18, "0 1 1 0");
//         // Scale 0 value 1 round 1 saturate 1
//         checkHappy("_: scale-18<0 1 1>(1e-18);", 1e18, "0 1 1 1");
//         // Scale 1 value 0 round 0 saturate 0
//         checkHappy("_: scale-18<1>(0);", 0, "1 0 0 0");
//         // Scale 1 value 0 round 0 saturate 1
//         checkHappy("_: scale-18<1 0 1>(0);", 0, "1 0 0 1");
//         // Scale 1 value 0 round 1 saturate 0
//         checkHappy("_: scale-18<1 1 0>(0);", 0, "1 0 1 0");
//         // Scale 1 value 0 round 1 saturate 1
//         checkHappy("_: scale-18<1 1 1>(0);", 0, "1 0 1 1");
//         // Scale 1 value 1 round 0 saturate 0
//         checkHappy("_: scale-18<1>(1e-18);", 1e17, "1 1 0 0");
//         // Scale 1 value 1 round 0 saturate 1
//         checkHappy("_: scale-18<1 0 1>(1e-18);", 1e17, "1 1 0 1");
//         // Scale 1 value 1 round 1 saturate 0
//         checkHappy("_: scale-18<1 1 0>(1e-18);", 1e17, "1 1 1 0");
//         // Scale 1 value 1 round 1 saturate 1
//         checkHappy("_: scale-18<1 1 1>(1e-18);", 1e17, "1 1 1 1");
//         // Scale 18 value 1 round 0 saturate 0
//         checkHappy("_: scale-18<18>(1e-18);", 1, "18 1 0 0");
//         // Scale 18 value 1 round 0 saturate 1
//         checkHappy("_: scale-18<18 0 1>(1e-18);", 1, "18 1 0 1");
//         // Scale 18 value 1 round 1 saturate 0
//         checkHappy("_: scale-18<18 1 0>(1e-18);", 1, "18 1 1 0");
//         // Scale 18 value 1 round 1 saturate 1
//         checkHappy("_: scale-18<18 1 1>(1e-18);", 1, "18 1 1 1");
//         // Scale 18 value 1e18 round 0 saturate 0
//         checkHappy("_: scale-18<18>(1);", 1e18, "18 1e18 0 0");
//         // Scale 18 value 1e18 round 0 saturate 1
//         checkHappy("_: scale-18<18 0 1>(1);", 1e18, "18 1e18 0 1");
//         // Scale 18 value 1e18 round 1 saturate 0
//         checkHappy("_: scale-18<18 1 0>(1);", 1e18, "18 1e18 1 0");
//         // Scale 18 value 1e18 round 1 saturate 1
//         checkHappy("_: scale-18<18 1 1>(1);", 1e18, "18 1e18 1 1");
//         // Scale 19 value 1e18 round 0 saturate 0
//         checkHappy("_: scale-18<19>(1);", 1e17, "19 1e18 0 0");
//         // Scale 19 value 1e18 round 0 saturate 1
//         checkHappy("_: scale-18<19 0 1>(1);", 1e17, "19 1e18 0 1");
//         // Scale 19 value 1e18 round 1 saturate 0
//         checkHappy("_: scale-18<19 1 0>(1);", 1e17, "19 1e18 1 0");
//         // Scale 19 value 1e18 round 1 saturate 1
//         checkHappy("_: scale-18<19 1 1>(1);", 1e17, "19 1e18 1 1");

//         // Test rounding down while scaling down.
//         checkHappy("_: scale-18<19>(1e-18);", 0, "19 1 0 0");
//         // Test rounding up while scaling down.
//         checkHappy("_: scale-18<19 1>(1e-18);", 1, "19 1 1 0");
//         // Test saturating while scaling up.
//         checkHappy("_: scale-18<0 0 1>(1e52);", type(uint256).max, "0 1e70 0 1");
//         // Test error while scaling up.
//         checkUnhappy("_: scale-18<0>(1e52);", stdError.arithmeticError);
//     }

// /// Test the eval of `uint256-to-decimal18` which is an alias of `scale-18<0>`.
// function testOpUint256ToDecimal18Eval() external view {
//     checkHappy("_: uint256-to-decimal18(0);", 0, "0");
//     checkHappy("_: uint256-to-decimal18(1e-18);", 1e18, "1");
//     checkHappy("_: uint256-to-decimal18(2e-18);", 2e18, "2");
//     checkHappy("_: uint256-to-decimal18(1);", 1e36, "1e18");
// }

//     /// Test the eval of `scale-18` opcode parsed from a string.
//     /// Tests zero inputs.
//     function testOpScale18EvalZeroInputs() external {
//         checkBadInputs("_: scale-18<0>();", 0, 1, 0);
//     }

//     /// Test the eval of `scale-18` opcode parsed from a string.
//     /// Tests two inputs.
//     function testOpScale18EvalOneInput() external {
//         checkBadInputs("_: scale-18<0>(0 5);", 2, 1, 2);
//         checkBadInputs("_: scale-18<0>(0 0);", 2, 1, 2);
//         checkBadInputs("_: scale-18<0>(0 1);", 2, 1, 2);
//         checkBadInputs("_: scale-18<0>(0 max-value());", 2, 1, 2);
//     }

//     function testOpScale18ZeroOutputs() external {
//         checkBadOutputs(": scale-18<0>(0);", 1, 1, 0);
//     }

//     function testOpScale18TwoOutputs() external {
//         checkBadOutputs("_ _: scale-18<0>(0);", 1, 1, 2);
//     }
// }
