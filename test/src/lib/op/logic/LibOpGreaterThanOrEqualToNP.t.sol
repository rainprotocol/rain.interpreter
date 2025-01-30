// SPDX-License-Identifier: CAL
pragma solidity =0.8.25;

// // import {OpTest} from "test/abstract/OpTest.sol";
// // import {LibContext} from "rain.interpreter.interface/lib/caller/LibContext.sol";
// // import {LibOpGreaterThanOrEqualToNP} from "src/lib/op/logic/LibOpGreaterThanOrEqualToNP.sol";
// // import {IntegrityCheckState, BadOpInputsLength} from "src/lib/integrity/LibIntegrityCheckNP.sol";
// // import {
// //     IInterpreterV4,
// //     Operand,
// //     SourceIndexV2,
// //     FullyQualifiedNamespace
// // } from "rain.interpreter.interface/interface/unstable/IInterpreterV4.sol";
// // import {InterpreterState} from "src/lib/state/LibInterpreterState.sol";
// // import {IInterpreterStoreV2} from "rain.interpreter.interface/interface/IInterpreterStoreV2.sol";
// // import {SignedContextV1} from "rain.interpreter.interface/interface/IInterpreterCallerV3.sol";
// // import {LibOperand} from "test/lib/operand/LibOperand.sol";

// contract LibOpGreaterThanOrEqualToNPTest is OpTest {
//     /// Directly test the integrity logic of LibOpGreaterThanOrEqualToNP. No matter the
//     /// operand inputs, the calc inputs must be 2, and the calc outputs must be
//     /// 1.
//     function testOpGreaterThanOrEqualToNPIntegrityHappy(IntegrityCheckState memory state, uint8 inputs)
//         external
//         pure
//     {
//         (uint256 calcInputs, uint256 calcOutputs) =
//             LibOpGreaterThanOrEqualToNP.integrity(state, Operand.wrap(uint256(inputs) << 0x10));

// //         // The inputs from the operand are ignored. The op is always 2 inputs.
// //         assertEq(calcInputs, 2);
// //         assertEq(calcOutputs, 1);
// //     }

//     /// Directly test the runtime logic of LibOpGreaterThanOrEqualToNP.
//     function testOpGreaterThanOrEqualToNPRun(uint256 input1, uint256 input2) external view {
//         InterpreterState memory state = opTestDefaultInterpreterState();
//         uint256[] memory inputs = new uint256[](2);
//         inputs[0] = input1;
//         inputs[1] = input2;
//         Operand operand = LibOperand.build(uint8(inputs.length), 1, 0);
//         opReferenceCheck(
//             state,
//             operand,
//             LibOpGreaterThanOrEqualToNP.referenceFn,
//             LibOpGreaterThanOrEqualToNP.integrity,
//             LibOpGreaterThanOrEqualToNP.run,
//             inputs
//         );
//     }

// //     /// Test the eval of greater than or equal to opcode parsed from a string.
// //     /// Tests 2 inputs. Both inputs are 0.
// //     function testOpGreaterThanOrEqualToNPEval2ZeroInputs() external {
// //         checkHappy("_: greater-than-or-equal-to(0 0);", 1, "");
// //     }

// //     /// Test the eval of greater than or equal to opcode parsed from a string.
// //     /// Tests 2 inputs. The first input is 0, the second input is 1.
// //     function testOpGreaterThanOrEqualToNPEval2InputsFirstZeroSecondOne() external {
// //         checkHappy("_: greater-than-or-equal-to(0 1);", 0, "");
// //     }

// //     /// Test the eval of greater than or equal to opcode parsed from a string.
// //     /// Tests 2 inputs. The first input is 1, the second input is 0.
// //     function testOpGreaterThanOrEqualToNPEval2InputsFirstOneSecondZero() external {
// //         checkHappy("_: greater-than-or-equal-to(1 0);", 1, "");
// //     }

// //     /// Test the eval of greater than or equal to opcode parsed from a string.
// //     /// Tests 2 inputs. Both inputs are 1.
// //     function testOpGreaterThanOrEqualToNPEval2InputsBothOne() external {
// //         checkHappy("_: greater-than-or-equal-to(1 1);", 1, "");
// //     }

// //     /// Test that a greater than or equal to without inputs fails integrity check.
// //     function testOpGreaterThanOrEqualToNPEvalFail0Inputs() public {
// //         vm.expectRevert(abi.encodeWithSelector(BadOpInputsLength.selector, 0, 2, 0));
// //         bytes memory bytecode = iDeployer.parse2("_: greater-than-or-equal-to();");
// //         (bytecode);
// //     }

// //     /// Test that a greater than or equal to with 1 input fails integrity check.
// //     function testOpGreaterThanOrEqualToNPEvalFail1Input() public {
// //         vm.expectRevert(abi.encodeWithSelector(BadOpInputsLength.selector, 1, 2, 1));
// //         bytes memory bytecode = iDeployer.parse2("_: greater-than-or-equal-to(0x00);");
// //         (bytecode);
// //     }

// //     /// Test that a greater than or equal to with 3 inputs fails integrity check.
// //     function testOpGreaterThanOrEqualToNPEvalFail3Inputs() public {
// //         vm.expectRevert(abi.encodeWithSelector(BadOpInputsLength.selector, 3, 2, 3));
// //         bytes memory bytecode = iDeployer.parse2("_: greater-than-or-equal-to(0x00 0x00 0x00);");
// //         (bytecode);
// //     }

// //     function testOpGreaterThanOrEqualToNPZeroOutputs() external {
// //         checkBadOutputs(": greater-than-or-equal-to(1 2);", 2, 1, 0);
// //     }

// //     function testOpGreaterThanOrEqualToNPTwoOutputs() external {
// //         checkBadOutputs("_ _: greater-than-or-equal-to(1 2);", 2, 1, 2);
// //     }
// // }
