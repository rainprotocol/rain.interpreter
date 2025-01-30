// SPDX-License-Identifier: CAL
pragma solidity =0.8.25;

import {OpTest} from "test/abstract/OpTest.sol";
import {IntegrityCheckState} from "src/lib/integrity/LibIntegrityCheckNP.sol";
import {LibOpShiftBitsLeftNP} from "src/lib/op/bitwise/LibOpShiftBitsLeftNP.sol";
import {InterpreterState} from "src/lib/state/LibInterpreterState.sol";
import {
    IInterpreterV4,
    FullyQualifiedNamespace,
    OperandV2,
    SourceIndexV2
} from "rain.interpreter.interface/interface/unstable/IInterpreterV4.sol";
import {IInterpreterStoreV2} from "rain.interpreter.interface/interface/IInterpreterStoreV2.sol";
import {SignedContextV1} from "rain.interpreter.interface/interface/IInterpreterCallerV3.sol";
import {LibContext} from "rain.interpreter.interface/lib/caller/LibContext.sol";
import {UnsupportedBitwiseShiftAmount} from "src/error/ErrBitwise.sol";
import {LibOperand} from "test/lib/operand/LibOperand.sol";
import {OperandOverflow} from "src/error/ErrParse.sol";

contract LibOpShiftBitsLeftNPTest is OpTest {
    /// Directly test the integrity logic of LibOpShiftBitsLeftNP. Tests the
    /// happy path where the integrity check does not error due to an unsupported
    /// shift amount.
    function testOpShiftBitsLeftNPIntegrityHappy(
        IntegrityCheckState memory state,
        uint8 inputs,
        uint8 outputs,
        uint8 shiftAmount
    ) external pure {
        vm.assume(shiftAmount != 0);
        inputs = uint8(bound(inputs, 1, 0x0F));
        outputs = uint8(bound(outputs, 1, 0x0F));
        OperandV2 operand = LibOperand.build(inputs, outputs, shiftAmount);
        (uint256 calcInputs, uint256 calcOutputs) = LibOpShiftBitsLeftNP.integrity(state, operand);
        assertEq(calcInputs, 1);
        assertEq(calcOutputs, 1);
    }

    /// Directly test the execution logic of LibOpShiftBitsLeftNP. Tests that
    /// any shift amount that always results in an output of 0 will error as
    /// an unsupported shift amount.
    function testOpShiftBitsLeftNPIntegrityZero(IntegrityCheckState memory state, uint8 inputs, uint16 shiftAmount16)
        external
    {
        inputs = uint8(bound(inputs, 0, 0x0F));
        uint256 shiftAmount = bound(uint256(shiftAmount16), uint256(type(uint8).max) + 1, type(uint16).max);
        OperandV2 operand = LibOperand.build(inputs, 1, uint16(shiftAmount));
        vm.expectRevert(abi.encodeWithSelector(UnsupportedBitwiseShiftAmount.selector, shiftAmount));
        (uint256 calcInputs, uint256 calcOutputs) = LibOpShiftBitsLeftNP.integrity(state, operand);
        (calcInputs, calcOutputs);
    }

    /// Directly test the execution logic of LibOpShiftBitsLeftNP. Tests that
    /// any shift amount that is a noop (0) will error as an unsupported shift
    /// amount.
    function testOpShiftBitsLeftNPIntegrityNoop(IntegrityCheckState memory state, uint8 inputs) external {
        OperandV2 operand = OperandV2.wrap(uint256(inputs) << 0x10);
        vm.expectRevert(abi.encodeWithSelector(UnsupportedBitwiseShiftAmount.selector, 0));
        (uint256 calcInputs, uint256 calcOutputs) = LibOpShiftBitsLeftNP.integrity(state, operand);
        (calcInputs, calcOutputs);
    }

    /// Directly test the runtime logic of LibOpShiftBitsLeftNP. This tests that
    /// the opcode correctly shifts bits left.
    function testOpShiftBitsLeftNPRun(uint256 x, uint8 shiftAmount) external view {
        vm.assume(shiftAmount != 0);
        InterpreterState memory state = opTestDefaultInterpreterState();
        uint256[] memory inputs = new uint256[](1);
        inputs[0] = x;
        OperandV2 operand = LibOperand.build(1, 1, shiftAmount);
        opReferenceCheck(
            state,
            operand,
            LibOpShiftBitsLeftNP.referenceFn,
            LibOpShiftBitsLeftNP.integrity,
            LibOpShiftBitsLeftNP.run,
            inputs
        );
    }

    /// Test the eval of a shift bits left opcode parsed from a string.
    function testOpShiftBitsLeftNPEval() external view {
        checkHappy("_: bitwise-shift-left<1>(0x00);", 0, "1, 0");
        checkHappy("_: bitwise-shift-left<2>(0x00);", 0, "2, 0");
        checkHappy("_: bitwise-shift-left<3>(0x00);", 0, "3, 0");
        checkHappy("_: bitwise-shift-left<255>(0x00);", 0, "255, 0");

        checkHappy("_: bitwise-shift-left<1>(0x01);", 1 << 1, "1, 1");
        checkHappy("_: bitwise-shift-left<2>(0x01);", 1 << 2, "2, 1");
        checkHappy("_: bitwise-shift-left<3>(0x01);", 1 << 3, "3, 1");
        checkHappy("_: bitwise-shift-left<255>(0x01);", 1 << 255, "255, 1");

        checkHappy("_: bitwise-shift-left<1>(0x02);", 2 << 1, "1, 2");
        checkHappy("_: bitwise-shift-left<2>(0x02);", 2 << 2, "2, 2");
        checkHappy("_: bitwise-shift-left<3>(0x02);", 2 << 3, "3, 2");
        // 2 gets shifted out of the 256 bit word, so this is 0.
        checkHappy("_: bitwise-shift-left<255>(0x02);", 0, "255, 2");

        checkHappy("_: bitwise-shift-left<1>(0x03);", 3 << 1, "1, 3");
        checkHappy("_: bitwise-shift-left<2>(0x03);", 3 << 2, "2, 3");
        checkHappy("_: bitwise-shift-left<3>(0x03);", 3 << 3, "3, 3");
        // The high bit of 3 gets shifted out of the 256 bit word, so this is the
        // same as shifting 1.
        checkHappy("_: bitwise-shift-left<255>(0x03);", 1 << 255, "255, 3");

        checkHappy("_: bitwise-shift-left<1>(uint256-max-value());", type(uint256).max << 1, "1, max");
        checkHappy("_: bitwise-shift-left<2>(uint256-max-value());", type(uint256).max << 2, "2, max");
        checkHappy("_: bitwise-shift-left<3>(uint256-max-value());", type(uint256).max << 3, "3, max");
        // The high bit of max gets shifted out of the 256 bit word, so this is the
        // same as shifting 1.
        checkHappy("_: bitwise-shift-left<255>(uint256-max-value());", 1 << 255, "255, max");
    }

    /// Test that a bitwise shift with bad inputs fails integrity.
    function testOpShiftBitsLeftNPIntegrityFailZeroInputs() external {
        checkBadInputs("_: bitwise-shift-left<1>();", 0, 1, 0);
    }

    function testOpShiftBitsLeftNPIntegrityFailTwoInputs() external {
        checkBadInputs("_: bitwise-shift-left<1>(0 0);", 2, 1, 2);
    }

    function testOpShiftBitsLeftNPIntegrityFailZeroOutputs() external {
        checkBadOutputs(": bitwise-shift-left<1>(0);", 1, 1, 0);
    }

    function testOpShiftBitsLeftNPIntegrityFailTwoOutputs() external {
        checkBadOutputs("_ _: bitwise-shift-left<1>(0);", 1, 1, 2);
    }

    /// Test that a bitwise shift with bad shift amount fails integrity.
    function testOpShiftBitsLeftNPIntegrityFailBadShiftAmount() external {
        checkUnhappyParse2(
            "_: bitwise-shift-left<0>(0);", abi.encodeWithSelector(UnsupportedBitwiseShiftAmount.selector, 0)
        );
        checkUnhappyParse2(
            "_: bitwise-shift-left<256>(0);", abi.encodeWithSelector(UnsupportedBitwiseShiftAmount.selector, 256)
        );
        // Something even bigger than 256, but without overflowing the uint16
        // for the operand itself.
        checkUnhappyParse2(
            "_: bitwise-shift-left<65535>(0);", abi.encodeWithSelector(UnsupportedBitwiseShiftAmount.selector, 65535)
        );
        // Lets go ahead and overflow the operand.
        checkUnhappyParse("_: bitwise-shift-left<65536>(0);", abi.encodeWithSelector(OperandOverflow.selector));
    }
}
