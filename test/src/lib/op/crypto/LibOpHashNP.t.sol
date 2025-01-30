// SPDX-License-Identifier: CAL
pragma solidity =0.8.25;

import {OpTest} from "test/abstract/OpTest.sol";

import {LibOpHashNP} from "src/lib/op/crypto/LibOpHashNP.sol";
import {LibContext} from "rain.interpreter.interface/lib/caller/LibContext.sol";

import {LibPointer, Pointer} from "rain.solmem/lib/LibPointer.sol";
import {LibMemCpy} from "rain.solmem/lib/LibMemCpy.sol";
import {LibUint256Array} from "rain.solmem/lib/LibUint256Array.sol";

import {
    IInterpreterV4,
    OperandV2,
    SourceIndexV2,
    EvalV4
} from "rain.interpreter.interface/interface/unstable/IInterpreterV4.sol";
import {
    IInterpreterStoreV2, FullyQualifiedNamespace
} from "rain.interpreter.interface/interface/IInterpreterStoreV2.sol";
import {SignedContextV1} from "rain.interpreter.interface/interface/IInterpreterCallerV3.sol";
import {LibIntegrityCheckNP, IntegrityCheckState} from "src/lib/integrity/LibIntegrityCheckNP.sol";
import {InterpreterState, LibInterpreterState} from "src/lib/state/LibInterpreterState.sol";
import {LibOperand} from "test/lib/operand/LibOperand.sol";
import {LibDecimalFloat} from "rain.math.float/lib/LibDecimalFloat.sol";

/// @title LibOpHashNPTest
/// @notice Test the runtime and integrity time logic of LibOpHashNP.
contract LibOpHashNPTest is OpTest {
    using LibInterpreterState for InterpreterState;
    using LibPointer for Pointer;
    using LibUint256Array for uint256[];

    /// Directly test the integrity logic of LibOpHashNP. This tests the happy
    /// path where the operand is valid.
    function testOpHashNPIntegrityHappy(
        IntegrityCheckState memory state,
        uint8 inputs,
        uint8 outputs,
        uint16 operandData
    ) external pure {
        inputs = uint8(bound(inputs, 0, 0x0F));
        outputs = uint8(bound(outputs, 0, 0x0F));
        OperandV2 operand = LibOperand.build(inputs, outputs, operandData);
        (uint256 calcInputs, uint256 calcOutputs) = LibOpHashNP.integrity(state, operand);

        assertEq(inputs, calcInputs);
        assertEq(calcOutputs, 1);
    }

    /// Directly test the runtime logic of LibOpHashNP.
    function testOpHashNPRun(uint256[] memory inputs) external view {
        vm.assume(inputs.length <= 0x0F);
        InterpreterState memory state = opTestDefaultInterpreterState();
        OperandV2 operand = LibOperand.build(uint8(inputs.length), 1, 0);
        opReferenceCheck(state, operand, LibOpHashNP.referenceFn, LibOpHashNP.integrity, LibOpHashNP.run, inputs);
    }

    /// Test the eval of a hash opcode parsed from a string. Tests 0 inputs.
    function testOpHashNPEval0Inputs() external view {
        checkHappy("_: hash();", uint256(keccak256("")), "");
    }

    /// Test the eval of a hash opcode parsed from a string. Tests 1 input.
    function testOpHashNPEval1Input() external view {
        checkHappy(
            "_: hash(0x1234567890abcdef);", uint256(keccak256(abi.encodePacked(uint256(0x1234567890abcdef)))), ""
        );
    }

    /// Test the eval of a hash opcode parsed from a string. Tests 2 inputs that
    /// are identical to each other.
    function testOpHashNPEval2Inputs() external view {
        checkHappy(
            "_: hash(0x1234567890abcdef 0x1234567890abcdef);",
            uint256(keccak256(abi.encodePacked(uint256(0x1234567890abcdef), uint256(0x1234567890abcdef)))),
            ""
        );
    }

    /// Test the eval of a hash opcode parsed from a string. Tests 2 inputs that
    /// are different from each other.
    function testOpHashNPEval2InputsDifferent() external view {
        checkHappy(
            "_: hash(0x1234567890abcdef 0xfedcba0987654321);",
            uint256(keccak256(abi.encodePacked(uint256(0x1234567890abcdef), uint256(0xfedcba0987654321)))),
            ""
        );
    }

    /// Test the eval of a hash opcode parsed from a string. Tests 2 inputs and
    /// other stack items.
    function testOpHashNPEval2InputsOtherStack() external view {
        bytes memory bytecode = iDeployer.parse2("_ _ _: 5 hash(0x1234567890abcdef 0xfedcba0987654321) 9;");
        (uint256[] memory stack, uint256[] memory kvs) = iInterpreter.eval4(
            EvalV4({
                store: iStore,
                namespace: FullyQualifiedNamespace.wrap(0),
                bytecode: bytecode,
                sourceIndex: SourceIndexV2.wrap(0),
                context: LibContext.build(new uint256[][](0), new SignedContextV1[](0)),
                inputs: new uint256[](0),
                stateOverlay: new uint256[](0)
            })
        );
        assertEq(stack.length, 3);
        assertEq(stack[0], LibDecimalFloat.pack(9e37, -37));
        assertEq(
            stack[1], uint256(keccak256(abi.encodePacked(uint256(0x1234567890abcdef), uint256(0xfedcba0987654321))))
        );
        assertEq(stack[2], LibDecimalFloat.pack(5e37, -37));
        assertEq(kvs.length, 0);
    }

    function testOpHashNPZeroOutputs() external {
        checkBadOutputs(":hash();", 0, 1, 0);
    }

    function testOpHashNPTwoOutputs() external {
        checkBadOutputs("_ _: hash();", 0, 1, 2);
    }
}
