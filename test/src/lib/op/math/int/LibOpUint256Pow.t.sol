// SPDX-License-Identifier: CAL
pragma solidity =0.8.25;

// import {stdError} from "forge-std/Test.sol";

// import {LibUint256Array} from "rain.solmem/lib/LibUint256Array.sol";

// import {OpTest} from "test/abstract/OpTest.sol";
// import {LibContext} from "rain.interpreter.interface/lib/caller/LibContext.sol";
// import {UnexpectedOperand} from "src/error/ErrParse.sol";
// import {LibOpUint256Pow} from "src/lib/op/math/uint256/LibOpUint256Pow.sol";
// import {IntegrityCheckState} from "src/lib/integrity/LibIntegrityCheckNP.sol";
// import {InterpreterState} from "src/lib/state/LibInterpreterState.sol";
// import {OperandV2} from "rain.interpreter.interface/interface/unstable/IInterpreterV4.sol";
// import {LibOperand} from "test/lib/operand/LibOperand.sol";

// contract LibOpUint256PowTest is OpTest {
//     using LibUint256Array for uint256[];

// /// Directly test the integrity logic of LibOpUint256Exp. This tests the happy
// /// path where the inputs input and calc match.
// function testOpUint256ExpIntegrityHappy(IntegrityCheckState memory state, uint8 inputs, uint16 operandData)
//     external
//     pure
// {
//     inputs = uint8(bound(inputs, 2, 0x0F));
//     (uint256 calcInputs, uint256 calcOutputs) =
//         LibOpUint256Pow.integrity(state, LibOperand.build(inputs, 1, operandData));

//         assertEq(calcInputs, inputs);
//         assertEq(calcOutputs, 1);
//     }

// /// Directly test the integrity logic of LibOpUint256Pow. This tests the unhappy
// /// path where the operand is invalid due to 0 inputs.
// function testOpUint256PowIntegrityUnhappyZeroInputs(IntegrityCheckState memory state) external pure {
//     (uint256 calcInputs, uint256 calcOutputs) = LibOpUint256Pow.integrity(state, Operand.wrap(0));
//     // Calc inputs will be minimum 2.
//     assertEq(calcInputs, 2);
//     assertEq(calcOutputs, 1);
// }

// /// Directly test the integrity logic of LibOpUint256Pow. This tests the unhappy
// /// path where the operand is invalid due to 1 inputs.
// function testOpUint256PowIntegrityUnhappyOneInput(IntegrityCheckState memory state) external pure {
//     (uint256 calcInputs, uint256 calcOutputs) = LibOpUint256Pow.integrity(state, Operand.wrap(0x010000));
//     // Calc inputs will be minimum 2.
//     assertEq(calcInputs, 2);
//     assertEq(calcOutputs, 1);
// }

//     /// Directly test the runtime logic of LibOpUint256Pow.
//     function testOpUint256PowRun(uint256[] memory inputs) external {
//         InterpreterState memory state = opTestDefaultInterpreterState();
//         vm.assume(inputs.length >= 2);
//         vm.assume(inputs.length <= 0x0F);
//         Operand operand = LibOperand.build(uint8(inputs.length), 1, 0);
//         uint256 overflows = 0;
//         unchecked {
//             uint256 a = inputs[0];
//             for (uint256 i = 1; i < inputs.length; i++) {
//                 uint256 b = inputs[i];
//                 if (b == 0) {
//                     a = 1;
//                     continue;
//                 } else if (b == 1 || a == 0) {
//                     continue;
//                 } else {
//                     uint256 c = a;
//                     for (uint256 j = 1; j < b; j++) {
//                         uint256 d = a * c;
//                         if (d / c != a) {
//                             overflows++;
//                             break;
//                         }
//                         if (d == a) {
//                             break;
//                         }
//                         a = d;
//                     }
//                 }
//             }
//         }
//         if (overflows > 0) {
//             vm.expectRevert(stdError.arithmeticError);
//         }
//         opReferenceCheck(
//             state, operand, LibOpUint256Pow.referenceFn, LibOpUint256Pow.integrity, LibOpUint256Pow.run, inputs
//         );
//     }

//     /// Test the eval of `uint256-power` opcode parsed from a string. Tests zero inputs.
//     function testOpUint256PowEvalZeroInputs() external {
//         checkBadInputs("_: uint256-power();", 0, 2, 0);
//     }

//     /// Test the eval of `uint256-power` opcode parsed from a string. Tests one input.
//     function testOpUint256PowEvalOneInput() external {
//         checkBadInputs("_: uint256-power(5e-18);", 1, 2, 1);
//         checkBadInputs("_: uint256-power(0);", 1, 2, 1);
//         checkBadInputs("_: uint256-power(1e-18);", 1, 2, 1);
//         checkBadInputs("_: uint256-power(max-value());", 1, 2, 1);
//     }

//     function testOpUint256PowEvalZeroOutputs() external {
//         checkBadOutputs(": uint256-power(0 0);", 2, 1, 0);
//     }

//     function testOpUint256PowEvalTwoOutputs() external {
//         checkBadOutputs("_ _: uint256-power(0 0);", 2, 1, 2);
//     }

// /// Test the eval of `uint256-power` opcode parsed from a string. Tests two inputs.
// /// Tests the happy path where we do not overflow.
// function testOpUint256PowEval2InputsHappy() external view {
//     // Anything exp 0 is 1.
//     checkHappy("_: uint256-power(0 0);", 1, "0 ** 0");
//     checkHappy("_: uint256-power(1e-18 0);", 1, "1 ** 0");
//     checkHappy("_: uint256-power(max-value() 0);", 1, "max-value() ** 0");

//         // 1 exp anything is 1.
//         checkHappy("_: uint256-power(1e-18 0);", 1, "1 ** 0");
//         checkHappy("_: uint256-power(1e-18 1e-18);", 1, "1 ** 1");
//         checkHappy("_: uint256-power(1e-18 2e-18);", 1, "1 ** 2");
//         checkHappy("_: uint256-power(1e-18 3e-18);", 1, "1 ** 3");
//         checkHappy("_: uint256-power(1e-18 max-value());", 1, "1 ** max-value()");

//         // Anything exp 1 is itself.
//         checkHappy("_: uint256-power(0 1e-18);", 0, "0 ** 1");
//         checkHappy("_: uint256-power(1e-18 1e-18);", 1, "1 ** 1");
//         checkHappy("_: uint256-power(max-value() 1e-18);", type(uint256).max, "max-value() ** 1");

//         // Anything exp 2 is itself squared.
//         checkHappy("_: uint256-power(0 2e-18);", 0, "0 ** 2");
//         checkHappy("_: uint256-power(1e-18 2e-18);", 1, "1 ** 2");
//         checkHappy("_: uint256-power(2e-18 2e-18);", 4, "2 ** 2");
//         checkHappy("_: uint256-power(3e-18 2e-18);", 9, "3 ** 2");

//         // Anything exp 3 is itself cubed.
//         checkHappy("_: uint256-power(0 3e-18);", 0, "0 ** 3");
//         checkHappy("_: uint256-power(1e-18 3e-18);", 1, "1 ** 3");
//         checkHappy("_: uint256-power(2e-18 3e-18);", 8, "2 ** 3");
//         checkHappy("_: uint256-power(3e-18 3e-18);", 27, "3 ** 3");
//     }

//     /// Test the eval of `uint256-power` opcode parsed from a string. Tests two inputs.
//     /// Tests the unhappy path where we overflow.
//     function testOpUint256PowEval2InputsUnhappy() external {
//         checkUnhappyOverflow("_: uint256-power(2e-18 max-value());");
//         checkUnhappyOverflow("_: uint256-power(3e-18 max-value());");
//         checkUnhappyOverflow("_: uint256-power(max-value() max-value());");
//     }

// /// Test the eval of `uint256-power` opcode parsed from a string. Tests three inputs.
// /// Tests the happy path where we do not divide by zero.
// function testOpUint256PowEval3InputsHappy() external view {
//     // Anything exp 0 is 1.
//     checkHappy("_: uint256-power(0 0 0);", 1, "0 ** 0 ** 0");
//     checkHappy("_: uint256-power(1e-18 0 0);", 1, "1 ** 0 ** 0");
//     checkHappy("_: uint256-power(max-value() 0 0);", 1, "max-value() ** 0 ** 0");
//     checkHappy("_: uint256-power(0 1e-18 0);", 1, "0 ** 1 ** 0");
//     checkHappy("_: uint256-power(1e-18 1e-18 0);", 1, "1 ** 1 ** 0");
//     checkHappy("_: uint256-power(0 0 1e-18);", 1, "0 ** 0 ** 1");
//     checkHappy("_: uint256-power(1e-18 0 1e-18);", 1, "1 ** 0 ** 1");
//     checkHappy("_: uint256-power(max-value() 0 1e-18);", 1, "max-value() ** 0 ** 1");

//         // 1 exp anything is 1.
//         checkHappy("_: uint256-power(1e-18 0 0);", 1, "1 ** 0 ** 0");
//         checkHappy("_: uint256-power(1e-18 0 1e-18);", 1, "1 ** 0 ** 1");
//         checkHappy("_: uint256-power(1e-18 1e-18 0);", 1, "1 ** 1 ** 0");
//         checkHappy("_: uint256-power(1e-18 1e-18 1e-18);", 1, "1 ** 1 ** 1");
//         checkHappy("_: uint256-power(1e-18 2e-18 0);", 1, "1 ** 2 ** 0");
//         checkHappy("_: uint256-power(1e-18 2e-18 1e-18);", 1, "1 ** 2 ** 1");
//         checkHappy("_: uint256-power(1e-18 2e-18 2e-18);", 1, "1 ** 2 ** 2");
//         checkHappy("_: uint256-power(1e-18 3e-18 0);", 1, "1 ** 3 ** 0");

//         // Anything exp 1 is itself.
//         checkHappy("_: uint256-power(0 1e-18 1e-18);", 0, "0 ** 1 ** 1");
//         checkHappy("_: uint256-power(1e-18 1e-18 1e-18);", 1, "1 ** 1 ** 1");
//         checkHappy("_: uint256-power(max-value() 1e-18 1e-18);", type(uint256).max, "max-value() ** 1 ** 1");

//         // Anything exp 2 1 is itself squared.
//         checkHappy("_: uint256-power(0 2e-18 1e-18);", 0, "0 ** 2 ** 0");
//         checkHappy("_: uint256-power(1e-18 2e-18 1e-18);", 1, "1 ** 2 ** 0");
//         checkHappy("_: uint256-power(2e-18 2e-18 1e-18);", 4, "2 ** 2 ** 0");
//         checkHappy("_: uint256-power(3e-18 2e-18 1e-18);", 9, "3 ** 2 ** 0");

//         // Anything exp 2 2 is itself squared squared.
//         checkHappy("_: uint256-power(0 2e-18 2e-18);", 0, "0 ** 2 ** 2");
//         checkHappy("_: uint256-power(1e-18 2e-18 2e-18);", 1, "1 ** 2 ** 2");
//         checkHappy("_: uint256-power(2e-18 2e-18 2e-18);", 16, "2 ** 2 ** 2");
//         checkHappy("_: uint256-power(3e-18 2e-18 2e-18);", 81, "3 ** 2 ** 2");

//         // Anything exp 3 1 is itself cubed.
//         checkHappy("_: uint256-power(0 3e-18 1e-18);", 0, "0 ** 3 ** 0");
//         checkHappy("_: uint256-power(1e-18 3e-18 1e-18);", 1, "1 ** 3 ** 0");
//         checkHappy("_: uint256-power(2e-18 3e-18 1e-18);", 8, "2 ** 3 ** 0");
//         checkHappy("_: uint256-power(3e-18 3e-18 1e-18);", 27, "3 ** 3 ** 0");

//         // Anything exp 3 2 is itself cubed squared.
//         checkHappy("_: uint256-power(0 3e-18 2e-18);", 0, "0 ** 3 ** 2");
//         checkHappy("_: uint256-power(1e-18 3e-18 2e-18);", 1, "1 ** 3 ** 2");
//         checkHappy("_: uint256-power(2e-18 3e-18 2e-18);", 64, "2 ** 3 ** 2");
//         checkHappy("_: uint256-power(3e-18 3e-18 2e-18);", 729, "3 ** 3 ** 2");

//         // Anything exp 3 3 is itself cubed cubed.
//         checkHappy("_: uint256-power(0 3e-18 3e-18);", 0, "0 ** 3 ** 3");
//         checkHappy("_: uint256-power(1e-18 3e-18 3e-18);", 1, "1 ** 3 ** 3");
//         checkHappy("_: uint256-power(2e-18 3e-18 3e-18);", 512, "2 ** 3 ** 3");
//         checkHappy("_: uint256-power(3e-18 3e-18 3e-18);", 19683, "3 ** 3 ** 3");
//     }

//     /// Test the eval of `uint256-power` opcode parsed from a string. Tests three inputs.
//     /// Tests the unhappy path where we overflow.
//     function testOpUint256PowEval3InputsUnhappy() external {
//         checkUnhappyOverflow("_: uint256-power(2e-18 max-value() 0);");
//         checkUnhappyOverflow("_: uint256-power(3e-18 max-value() 0);");
//         checkUnhappyOverflow("_: uint256-power(max-value() max-value() 0);");
//         checkUnhappyOverflow("_: uint256-power(2e-18 max-value() 1e-18);");
//         checkUnhappyOverflow("_: uint256-power(3e-18 max-value() 1e-18);");
//         checkUnhappyOverflow("_: uint256-power(max-value() max-value() 1e-18);");
//         checkUnhappyOverflow("_: uint256-power(2e-18 max-value() 2e-18);");
//         checkUnhappyOverflow("_: uint256-power(3e-18 max-value() 2e-18);");
//         checkUnhappyOverflow("_: uint256-power(max-value() max-value() 2e-18);");
//         checkUnhappyOverflow("_: uint256-power(2e-18 max-value() 3e-18);");
//         checkUnhappyOverflow("_: uint256-power(3e-18 max-value() 3e-18);");
//         checkUnhappyOverflow("_: uint256-power(max-value() max-value() 3e-18);");
//     }

//     /// Test the eval of `uint256-power` opcode parsed from a string.
//     /// Tests that operands are disallowed.
//     function testOpUint256PowEvalOperandDisallowed() external {
//         checkDisallowedOperand("_: uint256-power<0>(0 0 0);");
//         checkDisallowedOperand("_: uint256-power<1>(0 0 0);");
//         checkDisallowedOperand("_: uint256-power<2>(0 0 0);");
//         checkDisallowedOperand("_: uint256-power<3 1>(0 0 0);");
//     }
// }
