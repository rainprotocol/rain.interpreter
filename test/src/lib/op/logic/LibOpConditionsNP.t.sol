// SPDX-License-Identifier: CAL
pragma solidity =0.8.25;

// // import {LibUint256Array} from "rain.solmem/lib/LibUint256Array.sol";

// // import {OpTest, UnexpectedOperand} from "test/abstract/OpTest.sol";
// // import {LibContext} from "rain.interpreter.interface/lib/caller/LibContext.sol";
// // import {LibOpConditionsNP} from "src/lib/op/logic/LibOpConditionsNP.sol";
// // import {IntegrityCheckState, BadOpInputsLength} from "src/lib/integrity/LibIntegrityCheckNP.sol";
// // import {InterpreterState} from "src/lib/state/LibInterpreterState.sol";
// // import {
// //     IInterpreterV4,
// //     Operand,
// //     SourceIndexV2,
// //     FullyQualifiedNamespace
// // } from "rain.interpreter.interface/interface/unstable/IInterpreterV4.sol";
// // import {IInterpreterStoreV2} from "rain.interpreter.interface/interface/IInterpreterStoreV2.sol";
// // import {SignedContextV1} from "rain.interpreter.interface/interface/IInterpreterCallerV3.sol";
// // import {LibIntOrAString, IntOrAString} from "rain.intorastring/src/lib/LibIntOrAString.sol";
// // import {LibOperand} from "test/lib/operand/LibOperand.sol";

// // contract LibOpConditionsNPTest is OpTest {
// //     using LibUint256Array for uint256[];

//     /// Directly test the integrity logic of LibOpConditionsNP. This tests the happy
//     /// path where the operand is valid.
//     function testOpConditionsNPIntegrityHappy(
//         IntegrityCheckState memory state,
//         uint8 inputs,
//         uint8 outputs,
//         uint16 operandData
//     ) external pure {
//         inputs = uint8(bound(inputs, 0, 0x0F));
//         outputs = uint8(bound(outputs, 0, 0x0F));
//         (uint256 calcInputs, uint256 calcOutputs) =
//             LibOpConditionsNP.integrity(state, LibOperand.build(inputs, outputs, operandData));

// //         uint256 expectedCalcInputs = inputs;
// //         // Calc inputs will be minimum 2.
// //         if (inputs < 2) {
// //             expectedCalcInputs = 2;
// //         }
// //         assertEq(calcInputs, expectedCalcInputs, "calc inputs");
// //         assertEq(calcOutputs, 1);
// //     }

//     /// Directly test the runtime logic of LibOpConditionsNP.
//     function testOpConditionsNPRun(uint256[] memory inputs, uint256 finalNonZero) external view {
//         InterpreterState memory state = opTestDefaultInterpreterState();

// //         // Ensure that we have inputs that are a valid pairwise conditions.
// //         vm.assume(inputs.length > 1);
// //         vm.assume(inputs.length <= 0x0F);
// //         if (inputs.length % 2 != 0) {
// //             inputs.truncate(inputs.length - 1);
// //         }
// //         // Ensure the final condition is nonzero so that we don't error.
// //         if (inputs[inputs.length - 2] == 0) {
// //             vm.assume(finalNonZero != 0);
// //             inputs[inputs.length - 2] = finalNonZero;
// //         }
// //         Operand operand = LibOperand.build(uint8(inputs.length), 1, 0);
// //         opReferenceCheck(
// //             state, operand, LibOpConditionsNP.referenceFn, LibOpConditionsNP.integrity, LibOpConditionsNP.run, inputs
// //         );
// //     }

// //     /// Test the error case where no conditions are met.
// //     function testOpConditionsNPRunNoConditionsMet(uint256[] memory inputs, string memory reason) external {
// //         vm.assume(bytes(reason).length <= 31);
// //         InterpreterState memory state = opTestDefaultInterpreterState();
// //         // Ensure that we have inputs that are a valid pairwise conditions.
// //         vm.assume(inputs.length > 1);
// //         if (inputs.length > 0x0F) {
// //             inputs.truncate(0x0F);
// //         }

// //         Operand operand = LibOperand.build(uint8(inputs.length), 1, 0);

// //         // Ensure all the conditions are zero so that we error.
// //         for (uint256 i = 0; i < inputs.length; i += 2) {
// //             inputs[i] = 0;
// //         }

// //         if (inputs.length % 2 != 0) {
// //             inputs[inputs.length - 1] = IntOrAString.unwrap(LibIntOrAString.fromString2(reason));
// //         } else {
// //             reason = "";
// //         }

// //         vm.expectRevert(bytes(reason));
// //         opReferenceCheck(
// //             state, operand, LibOpConditionsNP.referenceFn, LibOpConditionsNP.integrity, LibOpConditionsNP.run, inputs
// //         );
// //     }

// //     /// Test the eval of conditions opcode parsed from a string. Tests 1 true input 1 zero output.
// //     function testOpConditionsNPEval1TrueInputZeroOutput() external {
// //         checkHappy("_: conditions(5 0);", 0, "");
// //     }

// //     /// Test the eval of conditions opcode parsed from a string. Tests 1 nonzero
// //     /// input 1 nonzero output.
// //     function testOpConditionsNPEval2MixedInputs() external {
// //         checkHappy("_: conditions(5 6);", 6e18, "");
// //     }

// //     /// Test that if conditions are NOT met, the expression reverts.
// //     function testOpConditionsNPEval1FalseInputRevert() external {
// //         checkUnhappy("_: conditions(0 5);", "");
// //     }

// //     /// Test that conditions can take an error code as an operand.
// //     function testOpConditionsNPEvalErrorCode() external {
// //         checkUnhappy("_: conditions(0x00 0x00 0x00 0x00 \"fail\");", "fail");
// //     }

// //     /// Test the eval of conditions opcode parsed from a string. Tests 1 zero
// //     /// then 1 nonzero condition.
// //     function testOpConditionsNPEval1FalseInput1TrueInput() external {
// //         checkHappy("_: conditions(0 9 3 4);", 4e18, "");
// //     }

// //     /// Test the eval of conditions opcode parsed from a string. Tests 2 true
// //     /// conditions. The first should be used.
// //     function testOpConditionsNPEval2TrueInputs() external {
// //         checkHappy("_: conditions(5 6 7 8);", 6e18, "");
// //     }

// //     /// Test the eval of conditions opcode parsed from a string. Tests 1 nonzero
// //     /// condition then 1 zero condition.
// //     function testOpConditionsNPEval1TrueInput1FalseInput() external {
// //         checkHappy("_: conditions(5 6 0 9);", 6e18, "");
// //     }

// //     /// Test that conditions without inputs fails integrity check.
// //     function testOpConditionsNPEvalFail0Inputs() public {
// //         vm.expectRevert(abi.encodeWithSelector(BadOpInputsLength.selector, 0, 2, 0));
// //         bytes memory bytecode = iDeployer.parse2("_: conditions();");
// //         (bytecode);
// //     }

// //     /// Test that conditions with 1 inputs fails integrity check.
// //     function testOpConditionsNPEvalFail1Inputs() public {
// //         vm.expectRevert(abi.encodeWithSelector(BadOpInputsLength.selector, 1, 2, 1));
// //         bytes memory bytecode = iDeployer.parse2("_: conditions(0x00);");
// //         (bytecode);
// //     }

// //     /// Test the eval of `conditions` parsed from a string. Tests the unhappy path
// //     /// where an operand is provided.
// //     function testOpConditionsNPEvalUnhappyOperand() external {
// //         checkUnhappyParse("_ :conditions<0>(1 1 \"foo\");", abi.encodeWithSelector(UnexpectedOperand.selector));
// //     }

// //     function testOpConditionsNPZeroOutputs() external {
// //         checkBadOutputs(": conditions(0x00 0x00);", 2, 1, 0);
// //     }

// //     function testOpConditionsNPTwoOutputs() external {
// //         checkBadOutputs("_ _: conditions(0x00 0x00);", 2, 1, 2);
// //     }
// // }
