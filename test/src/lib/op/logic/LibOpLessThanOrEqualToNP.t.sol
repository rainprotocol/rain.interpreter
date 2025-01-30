// SPDX-License-Identifier: CAL
pragma solidity =0.8.25;

// // import {OpTest} from "test/abstract/OpTest.sol";
// // import {LibOpLessThanOrEqualToNP} from "src/lib/op/logic/LibOpLessThanOrEqualToNP.sol";
// // import {IntegrityCheckState, BadOpInputsLength} from "src/lib/integrity/LibIntegrityCheckNP.sol";
// // import {
// //     IInterpreterV4,
// //     Operand,
// //     SourceIndexV2,
// //     FullyQualifiedNamespace,
// //     EvalV4
// // } from "rain.interpreter.interface/interface/unstable/IInterpreterV4.sol";
// // import {InterpreterState} from "src/lib/state/LibInterpreterState.sol";
// // import {IInterpreterStoreV2} from "rain.interpreter.interface/interface/IInterpreterStoreV2.sol";
// // import {SignedContextV1} from "rain.interpreter.interface/interface/IInterpreterCallerV3.sol";
// // import {LibContext} from "rain.interpreter.interface/lib/caller/LibContext.sol";
// // import {LibOperand} from "test/lib/operand/LibOperand.sol";

// contract LibOpLessThanOrEqualToNPTest is OpTest {
//     /// Directly test the integrity logic of LibOpLessThanOrEqualToNP. No matter the
//     /// operand inputs, the calc inputs must be 2, and the calc outputs must be
//     /// 1.
//     function testOpLessThanOrEqualToNPIntegrityHappy(
//         IntegrityCheckState memory state,
//         uint8 inputs,
//         uint8 outputs,
//         uint16 operandData
//     ) external pure {
//         inputs = uint8(bound(inputs, 0, 0x0F));
//         outputs = uint8(bound(outputs, 0, 0x0F));
//         (uint256 calcInputs, uint256 calcOutputs) =
//             LibOpLessThanOrEqualToNP.integrity(state, LibOperand.build(inputs, outputs, operandData));

// //         // The inputs from the operand are ignored. The op is always 2 inputs.
// //         assertEq(calcInputs, 2);
// //         assertEq(calcOutputs, 1);
// //     }

//     /// Directly test the runtime logic of LibOpLessThanOrEqualToNP.
//     function testOpLessThanOrEqualToNPRun(uint256 input1, uint256 input2) external view {
//         InterpreterState memory state = opTestDefaultInterpreterState();
//         uint256[] memory inputs = new uint256[](2);
//         inputs[0] = input1;
//         inputs[1] = input2;
//         Operand operand = LibOperand.build(uint8(inputs.length), 1, 0);
//         opReferenceCheck(
//             state,
//             operand,
//             LibOpLessThanOrEqualToNP.referenceFn,
//             LibOpLessThanOrEqualToNP.integrity,
//             LibOpLessThanOrEqualToNP.run,
//             inputs
//         );
//     }

//     /// Test the eval of greater than or equal to opcode parsed from a string.
//     /// Tests 2 inputs. Both inputs are 0.
//     function testOpLessThanOrEqualToNPEval2ZeroInputs() external view {
//         bytes memory bytecode = iDeployer.parse2("_: less-than-or-equal-to(0 0);");
//         (uint256[] memory stack, uint256[] memory kvs) = iInterpreter.eval4(
//             EvalV4({
//                 store: iStore,
//                 namespace: FullyQualifiedNamespace.wrap(0),
//                 bytecode: bytecode,
//                 sourceIndex: SourceIndexV2.wrap(0),
//                 context: LibContext.build(new uint256[][](0), new SignedContextV1[](0)),
//                 inputs: new uint256[](0),
//                 stateOverlay: new uint256[](0)
//             })
//         );

// //         assertEq(stack.length, 1);
// //         assertEq(stack[0], 1);
// //         assertEq(kvs.length, 0);
// //     }

//     /// Test the eval of greater than or equal to opcode parsed from a string.
//     /// Tests 2 inputs. The first input is 0, the second input is 1.
//     function testOpLessThanOrEqualToNPEval2InputsFirstZeroSecondOne() external view {
//         bytes memory bytecode = iDeployer.parse2("_: less-than-or-equal-to(0 1);");
//         (uint256[] memory stack, uint256[] memory kvs) = iInterpreter.eval4(
//             EvalV4({
//                 store: iStore,
//                 namespace: FullyQualifiedNamespace.wrap(0),
//                 bytecode: bytecode,
//                 sourceIndex: SourceIndexV2.wrap(0),
//                 context: LibContext.build(new uint256[][](0), new SignedContextV1[](0)),
//                 inputs: new uint256[](0),
//                 stateOverlay: new uint256[](0)
//             })
//         );

// //         assertEq(stack.length, 1);
// //         assertEq(stack[0], 1);
// //         assertEq(kvs.length, 0);
// //     }

//     /// Test the eval of greater than or equal to opcode parsed from a string.
//     /// Tests 2 inputs. The first input is 1, the second input is 0.
//     function testOpLessThanOrEqualToNPEval2InputsFirstOneSecondZero() external view {
//         bytes memory bytecode = iDeployer.parse2("_: less-than-or-equal-to(1 0);");
//         (uint256[] memory stack, uint256[] memory kvs) = iInterpreter.eval4(
//             EvalV4({
//                 store: iStore,
//                 namespace: FullyQualifiedNamespace.wrap(0),
//                 bytecode: bytecode,
//                 sourceIndex: SourceIndexV2.wrap(0),
//                 context: LibContext.build(new uint256[][](0), new SignedContextV1[](0)),
//                 inputs: new uint256[](0),
//                 stateOverlay: new uint256[](0)
//             })
//         );

// //         assertEq(stack.length, 1);
// //         assertEq(stack[0], 0);
// //         assertEq(kvs.length, 0);
// //     }

//     /// Test the eval of greater than or equal to opcode parsed from a string.
//     /// Tests 2 inputs. Both inputs are 1.
//     function testOpLessThanOrEqualToNPEval2InputsBothOne() external view {
//         bytes memory bytecode = iDeployer.parse2("_: less-than-or-equal-to(1 1);");
//         (uint256[] memory stack, uint256[] memory kvs) = iInterpreter.eval4(
//             EvalV4({
//                 store: iStore,
//                 namespace: FullyQualifiedNamespace.wrap(0),
//                 bytecode: bytecode,
//                 sourceIndex: SourceIndexV2.wrap(0),
//                 context: LibContext.build(new uint256[][](0), new SignedContextV1[](0)),
//                 inputs: new uint256[](0),
//                 stateOverlay: new uint256[](0)
//             })
//         );

// //         assertEq(stack.length, 1);
// //         assertEq(stack[0], 1);
// //         assertEq(kvs.length, 0);
// //     }

// //     /// Test that a less than or equal to without inputs fails integrity check.
// //     function testOpLessThanOrEqualToNPEvalFail0Inputs() public {
// //         vm.expectRevert(abi.encodeWithSelector(BadOpInputsLength.selector, 0, 2, 0));
// //         bytes memory bytecode = iDeployer.parse2("_: less-than-or-equal-to();");
// //         (bytecode);
// //     }

// //     /// Test that a less than or equal to with 1 input fails integrity check.
// //     function testOpLessThanOrEqualToNPEvalFail1Input() public {
// //         vm.expectRevert(abi.encodeWithSelector(BadOpInputsLength.selector, 1, 2, 1));
// //         bytes memory bytecode = iDeployer.parse2("_: less-than-or-equal-to(0x00);");
// //         (bytecode);
// //     }

// //     /// Test that a less than or equal to with 3 inputs fails integrity check.
// //     function testOpLessThanOrEqualToNPEvalFail3Inputs() public {
// //         vm.expectRevert(abi.encodeWithSelector(BadOpInputsLength.selector, 3, 2, 3));

// //         bytes memory bytecode = iDeployer.parse2("_: less-than-or-equal-to(0x00 0x00 0x00);");
// //         (bytecode);
// //     }

// //     function testOpLessThanOrEqualToNPZeroOutputs() external {
// //         checkBadOutputs(": less-than-or-equal-to(1 2);", 2, 1, 0);
// //     }

// //     function testOpLessThanOrEqualToNPTwoOutputs() external {
// //         checkBadOutputs("_ _: less-than-or-equal-to(1 2);", 2, 1, 2);
// //     }
// // }
