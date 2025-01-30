// SPDX-License-Identifier: CAL
pragma solidity =0.8.25;

// // import {OpTest} from "test/abstract/OpTest.sol";

// import {LibPointer, Pointer} from "rain.solmem/lib/LibPointer.sol";
// import {
//     IInterpreterV4,
//     Operand,
//     SourceIndexV2,
//     FullyQualifiedNamespace
// } from "rain.interpreter.interface/interface/unstable/IInterpreterV4.sol";
// import {LibStackPointer} from "rain.solmem/lib/LibStackPointer.sol";
// import {IMetaV1} from "rain.metadata/interface/deprecated/IMetaV1.sol";
// import {IInterpreterStoreV2} from "rain.interpreter.interface/interface/IInterpreterStoreV2.sol";
// import {LibInterpreterState, InterpreterState} from "src/lib/state/LibInterpreterState.sol";
// import {IntegrityCheckState, BadOpInputsLength} from "src/lib/integrity/LibIntegrityCheckNP.sol";
// import {LibContext} from "rain.interpreter.interface/lib/caller/LibContext.sol";
// import {SignedContextV1} from "rain.interpreter.interface/interface/IInterpreterCallerV3.sol";
// import {LibOpBlockNumberNP} from "src/lib/op/evm/LibOpBlockNumberNP.sol";
// import {LibOperand} from "test/lib/operand/LibOperand.sol";

// // /// @title LibOpBlockNumberNPTest
// // /// @notice Test the runtime and integrity time logic of LibOpBlockNumberNP.
// // contract LibOpBlockNumberNPTest is OpTest {
// //     using LibPointer for Pointer;
// //     using LibStackPointer for Pointer;
// //     using LibInterpreterState for InterpreterState;

//     /// Directly test the integrity logic of LibOpBlockNumberNP.
//     function testOpBlockNumberNPIntegrity(
//         IntegrityCheckState memory state,
//         uint8 inputs,
//         uint8 outputs,
//         uint16 operandData
//     ) external pure {
//         inputs = uint8(bound(inputs, 0, 0x0F));
//         outputs = uint8(bound(outputs, 0, 0x0F));
//         (uint256 calcInputs, uint256 calcOutputs) =
//             LibOpBlockNumberNP.integrity(state, LibOperand.build(inputs, outputs, operandData));

// //         assertEq(calcInputs, 0);
// //         assertEq(calcOutputs, 1);
// //     }

// //     /// Directly test the runtime logic of LibOpBlockNumberNP. This tests that the
// //     /// opcode correctly pushes the block number onto the stack.
// //     function testOpBlockNumberNPRun(uint256 blockNumber, uint16 operandData) external {
// //         blockNumber = bound(blockNumber, 0, type(uint256).max / 1e18);
// //         InterpreterState memory state = opTestDefaultInterpreterState();
// //         vm.roll(blockNumber);
// //         uint256[] memory inputs = new uint256[](0);
// //         Operand operand = LibOperand.build(0, 1, operandData);
// //         opReferenceCheck(
// //             state, operand, LibOpBlockNumberNP.referenceFn, LibOpBlockNumberNP.integrity, LibOpBlockNumberNP.run, inputs
// //         );
// //     }

// //     /// Test the eval of a block number opcode parsed from a string.
// //     function testOpBlockNumberNPEval(uint256 blockNumber) public {
// //         blockNumber = bound(blockNumber, 0, type(uint256).max / 1e18);
// //         vm.roll(blockNumber);
// //         checkHappy("_: block-number();", blockNumber * 1e18, "");
// //     }

// //     function testOpBlockNumberNPEvalOneInput() external {
// //         checkBadInputs("_: block-number(0x00);", 1, 0, 1);
// //     }

// //     function testOpBlockNumberNPEvalZeroOutputs() external {
// //         checkBadOutputs(": block-number();", 0, 1, 0);
// //     }

// //     function testOpBlockNumberNPEvalTwoOutputs() external {
// //         checkBadOutputs("_ _: block-number();", 0, 1, 2);
// //     }
// // }
