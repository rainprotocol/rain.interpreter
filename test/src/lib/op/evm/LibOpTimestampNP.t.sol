// SPDX-License-Identifier: CAL
pragma solidity =0.8.25;

// // import {OpTest} from "test/abstract/OpTest.sol";
// // import {Pointer, LibPointer} from "rain.solmem/lib/LibPointer.sol";
// // import {LibStackPointer} from "rain.solmem/lib/LibStackPointer.sol";
// // import {LibInterpreterState} from "src/lib/state/LibInterpreterState.sol";
// // import {
// //     IInterpreterV4,
// //     Operand,
// //     SourceIndexV2,
// //     EvalV4
// // } from "rain.interpreter.interface/interface/unstable/IInterpreterV4.sol";
// // import {InterpreterState} from "src/lib/state/LibInterpreterState.sol";
// // import {IntegrityCheckState, BadOpInputsLength} from "src/lib/integrity/LibIntegrityCheckNP.sol";
// // import {
// //     IInterpreterStoreV2, FullyQualifiedNamespace
// // } from "rain.interpreter.interface/interface/IInterpreterStoreV2.sol";
// // import {SignedContextV1} from "rain.interpreter.interface/interface/IInterpreterCallerV3.sol";
// // import {LibContext} from "rain.interpreter.interface/lib/caller/LibContext.sol";

// // import {LibOpTimestampNP} from "src/lib/op/evm/LibOpTimestampNP.sol";
// // import {LibOperand} from "test/lib/operand/LibOperand.sol";

// // /// @title LibOpTimestampNPTest
// // /// @notice Test the runtime and integrity time logic of LibOpTimestampNP.
// // contract LibOpTimestampNPTest is OpTest {
// //     using LibPointer for Pointer;
// //     using LibStackPointer for Pointer;
// //     using LibInterpreterState for InterpreterState;

// //     function timestampWords() internal pure returns (string[] memory) {
// //         string[] memory words = new string[](2);
// //         words[0] = "block-timestamp";
// //         words[1] = "now";
// //         return words;
// //     }

//     /// Directly test the integrity logic of LibOpTimestampNP.
//     function testOpTimestampNPIntegrity(
//         IntegrityCheckState memory state,
//         uint8 inputs,
//         uint8 outputs,
//         uint16 operandData
//     ) external pure {
//         inputs = uint8(bound(inputs, 0, 0x0F));
//         outputs = uint8(bound(outputs, 0, 0x0F));
//         (uint256 calcInputs, uint256 calcOutputs) =
//             LibOpTimestampNP.integrity(state, LibOperand.build(inputs, outputs, operandData));

// //         assertEq(calcInputs, 0);
// //         assertEq(calcOutputs, 1);
// //     }

// //     /// Directly test the runtime logic of LibOpTimestamp. This tests that the
// //     /// opcode correctly pushes the timestamp onto the stack.
// //     function testOpTimestampNPRun(uint256 blockTimestamp) external {
// //         blockTimestamp = bound(blockTimestamp, 0, type(uint256).max / 1e18);
// //         InterpreterState memory state = opTestDefaultInterpreterState();
// //         vm.warp(blockTimestamp);
// //         uint256[] memory inputs = new uint256[](0);
// //         Operand operand = LibOperand.build(0, 1, 0);
// //         opReferenceCheck(
// //             state, operand, LibOpTimestampNP.referenceFn, LibOpTimestampNP.integrity, LibOpTimestampNP.run, inputs
// //         );
// //     }

// //     /// Test the eval of a timestamp opcode parsed from a string.
// //     function testOpTimestampNPEval(uint256 blockTimestamp) external {
// //         string[] memory words = timestampWords();

// //         for (uint256 i; i < words.length; ++i) {
// //             blockTimestamp = bound(blockTimestamp, 0, type(uint256).max / 1e18);
// //             vm.warp(blockTimestamp);
// //             bytes memory bytecode = iDeployer.parse2(bytes(string.concat("_: ", words[i], "();")));
// //             (uint256[] memory stack, uint256[] memory kvs) = iInterpreter.eval4(
// //                 EvalV4({
// //                     store: iStore,
// //                     namespace: FullyQualifiedNamespace.wrap(0),
// //                     bytecode: bytecode,
// //                     sourceIndex: SourceIndexV2.wrap(0),
// //                     context: LibContext.build(new uint256[][](0), new SignedContextV1[](0)),
// //                     inputs: new uint256[](0),
// //                     stateOverlay: new uint256[](0)
// //                 })
// //             );
// //             assertEq(stack.length, 1);
// //             assertEq(stack[0], blockTimestamp * 1e18);
// //             assertEq(kvs.length, 0);
// //         }
// //     }

// //     /// Test that a block timestamp with inputs fails integrity check.
// //     function testOpBlockTimestampNPEvalFail() external {
// //         string[] memory words = timestampWords();

// //         for (uint256 i; i < words.length; ++i) {
// //             vm.expectRevert(abi.encodeWithSelector(BadOpInputsLength.selector, 1, 0, 1));
// //             bytes memory bytecode = iDeployer.parse2(bytes(string.concat("_: ", words[i], "(0x00);")));
// //             (bytecode);
// //         }
// //     }

// //     function testOpBlockTimestampNPZeroOutputs() external {
// //         string[] memory words = timestampWords();

// //         for (uint256 i; i < words.length; ++i) {
// //             checkBadOutputs(bytes(string.concat(": ", words[i], "();")), 0, 1, 0);
// //         }
// //     }

// //     function testOpBlockTimestampNPTwoOutputs() external {
// //         string[] memory words = timestampWords();

// //         for (uint256 i; i < words.length; ++i) {
// //             checkBadOutputs(bytes(string.concat("_ _: ", words[i], "();")), 0, 1, 2);
// //         }
// //     }
// // }
