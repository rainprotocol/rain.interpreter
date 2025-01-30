// SPDX-License-Identifier: CAL
pragma solidity =0.8.25;

import {OpTest} from "test/abstract/OpTest.sol";
import {LibOpMaxUint256NP} from "src/lib/op/evm/LibOpMaxUint256NP.sol";
import {IntegrityCheckState, BadOpInputsLength} from "src/lib/integrity/LibIntegrityCheckNP.sol";
import {
    IInterpreterV4,
    OperandV2,
    SourceIndexV2,
    FullyQualifiedNamespace
} from "rain.interpreter.interface/interface/unstable/IInterpreterV4.sol";
import {InterpreterState, LibInterpreterState} from "src/lib/state/LibInterpreterState.sol";
import {LibContext} from "rain.interpreter.interface/lib/caller/LibContext.sol";
import {IInterpreterStoreV2} from "rain.interpreter.interface/interface/IInterpreterStoreV2.sol";
import {SignedContextV1} from "rain.interpreter.interface/interface/IInterpreterCallerV3.sol";
import {LibOperand} from "test/lib/operand/LibOperand.sol";

/// @title LibOpMaxUint256NPTest
/// @notice Test the runtime and integrity time logic of LibOpMaxUint256NP.
contract LibOpMaxUint256NPTest is OpTest {
    using LibInterpreterState for InterpreterState;

    /// Directly test the integrity logic of LibOpMaxUint256NP.
    function testOpMaxUint256NPIntegrity(
        IntegrityCheckState memory state,
        uint8 inputs,
        uint8 outputs,
        uint16 operandData
    ) external pure {
        inputs = uint8(bound(inputs, 0, 0x0F));
        outputs = uint8(bound(outputs, 0, 0x0F));
        (uint256 calcInputs, uint256 calcOutputs) =
            LibOpMaxUint256NP.integrity(state, LibOperand.build(inputs, outputs, operandData));

        assertEq(calcInputs, 0);
        assertEq(calcOutputs, 1);
    }

    /// Directly test the runtime logic of LibOpMaxUint256NP. This tests that the
    /// opcode correctly pushes the max uint256 onto the stack.
    function testOpMaxUint256NPRun() external view {
        InterpreterState memory state = opTestDefaultInterpreterState();
        uint256[] memory inputs = new uint256[](0);
        OperandV2 operand = LibOperand.build(0, 1, 0);
        opReferenceCheck(
            state, operand, LibOpMaxUint256NP.referenceFn, LibOpMaxUint256NP.integrity, LibOpMaxUint256NP.run, inputs
        );
    }

    /// Test the eval of LibOpMaxUint256NP parsed from a string.
    function testOpMaxUint256NPEval() external view {
        checkHappy("_: uint256-max-value();", type(uint256).max, "");
    }

    /// Test that a max-value with inputs fails integrity check.
    function testOpMaxUint256NPEvalFail() public {
        vm.expectRevert(abi.encodeWithSelector(BadOpInputsLength.selector, 1, 0, 1));
        bytes memory bytecode = iDeployer.parse2("_: uint256-max-value(0x00);");
        (bytecode);
    }

    function testOpMaxUint256NPZeroOutputs() external {
        checkBadOutputs(": uint256-max-value();", 0, 1, 0);
    }

    function testOpMaxUint256NPTwoOutputs() external {
        checkBadOutputs("_ _: uint256-max-value();", 0, 1, 2);
    }
}
