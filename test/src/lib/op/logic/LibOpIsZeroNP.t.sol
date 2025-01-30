// SPDX-License-Identifier: CAL
pragma solidity =0.8.25;

// // import {OpTest} from "test/abstract/OpTest.sol";
// // import {LibContext} from "rain.interpreter.interface/lib/caller/LibContext.sol";
// // import {IntegrityCheckState, BadOpInputsLength} from "src/lib/integrity/LibIntegrityCheckNP.sol";
// // import {LibUint256Array} from "rain.solmem/lib/LibUint256Array.sol";
// // import {LibOpIsZeroNP} from "src/lib/op/logic/LibOpIsZeroNP.sol";
// // import {InterpreterState} from "src/lib/state/LibInterpreterState.sol";
// // import {
// //     IInterpreterV4,
// //     Operand,
// //     SourceIndexV2,
// //     FullyQualifiedNamespace
// // } from "rain.interpreter.interface/interface/unstable/IInterpreterV4.sol";
// // import {IInterpreterStoreV2} from "rain.interpreter.interface/interface/IInterpreterStoreV2.sol";
// // import {SignedContextV1} from "rain.interpreter.interface/interface/IInterpreterCallerV3.sol";
// // import {LibOperand} from "test/lib/operand/LibOperand.sol";

// // contract LibOpIsZeroNPTest is OpTest {
// //     using LibUint256Array for uint256[];

//     /// Directly test the integrity logic of LibOpIsZeroNP. This tests the happy
//     /// path where the operand is valid. IsZero is a 1 input, 1 output op.
//     function testOpIsZeroNPIntegrityHappy(
//         IntegrityCheckState memory state,
//         uint8 inputs,
//         uint8 outputs,
//         uint16 operandData
//     ) external pure {
//         inputs = uint8(bound(inputs, 1, 0x0F));
//         outputs = uint8(bound(outputs, 1, 0x0F));
//         (uint256 calcInputs, uint256 calcOutputs) =
//             LibOpIsZeroNP.integrity(state, LibOperand.build(inputs, outputs, operandData));

// //         // The inputs from the operand are ignored. The op is always 1 input.
// //         assertEq(calcInputs, 1);
// //         assertEq(calcOutputs, 1);
// //     }

//     /// Directly test the runtime logic of LibOpIsZeroNP.
//     function testOpIsZeroNPRun(uint256 input) external view {
//         InterpreterState memory state = opTestDefaultInterpreterState();
//         uint256[] memory inputs = new uint256[](1);
//         inputs[0] = input;
//         Operand operand = LibOperand.build(uint8(inputs.length), 1, 0);
//         opReferenceCheck(state, operand, LibOpIsZeroNP.referenceFn, LibOpIsZeroNP.integrity, LibOpIsZeroNP.run, inputs);
//     }

// //     /// Test the eval of isZero opcode parsed from a string. Tests 1 nonzero input.
// //     function testOpIsZeroNPEval1NonZeroInput() external {
// //         checkHappy("_: is-zero(30);", 0, "");
// //     }

// //     /// Test the eval of isZero opcode parsed from a string. Tests 1 zero input.
// //     function testOpIsZeroNPEval1ZeroInput() external {
// //         checkHappy("_: is-zero(0);", 1, "");
// //     }

// //     /// Test that an iszero without inputs fails integrity check.
// //     function testOpIsZeroNPEvalFail0Inputs() public {
// //         vm.expectRevert(abi.encodeWithSelector(BadOpInputsLength.selector, 0, 1, 0));
// //         bytes memory bytecode = iDeployer.parse2("_: is-zero();");
// //         (bytecode);
// //     }

// //     /// Test that an iszero with 2 inputs fails integrity check.
// //     function testOpIsZeroNPEvalFail2Inputs() public {
// //         vm.expectRevert(abi.encodeWithSelector(BadOpInputsLength.selector, 2, 1, 2));
// //         bytes memory bytecode = iDeployer.parse2("_: is-zero(0x00 0x00);");
// //         (bytecode);
// //     }

// //     function testOpIsZeroNPZeroOutputs() external {
// //         checkBadOutputs(": is-zero(0);", 1, 1, 0);
// //     }

// //     function testOpIsZeroNPTwoOutputs() external {
// //         checkBadOutputs("_ _: is-zero(30);", 1, 1, 2);
// //     }
// // }
