// SPDX-License-Identifier: CAL
pragma solidity =0.8.25;

import {OpTest} from "test/abstract/OpTest.sol";
import {IntegrityCheckState} from "src/lib/integrity/LibIntegrityCheckNP.sol";
import {OperandV2} from "rain.interpreter.interface/interface/unstable/IInterpreterV4.sol";
import {LibOpBitwiseOrNP} from "src/lib/op/bitwise/LibOpBitwiseOrNP.sol";
import {InterpreterState} from "src/lib/state/LibInterpreterState.sol";
import {UnexpectedOperand} from "src/error/ErrParse.sol";
import {LibOperand} from "test/lib/operand/LibOperand.sol";

contract LibOpBitwiseOrNPTest is OpTest {
    /// Directly test the integrity logic of LibOpBitwiseOrNP. All possible
    /// operands result in the same number of inputs and outputs, (2, 1).
    function testOpBitwiseORNPIntegrity(IntegrityCheckState memory state, OperandV2 operand) external pure {
        (uint256 calcInputs, uint256 calcOutputs) = LibOpBitwiseOrNP.integrity(state, operand);
        assertEq(calcInputs, 2);
        assertEq(calcOutputs, 1);
    }

    /// Directly test the runtime logic of LibOpBitwiseOrNP. This tests that the
    /// opcode correctly pushes the bitwise OR onto the stack.
    function testOpBitwiseORNPRun(uint256 x, uint256 y) external view {
        InterpreterState memory state = opTestDefaultInterpreterState();
        uint256[] memory inputs = new uint256[](2);
        inputs[0] = x;
        inputs[1] = y;
        OperandV2 operand = LibOperand.build(2, 1, 0);
        opReferenceCheck(
            state, operand, LibOpBitwiseOrNP.referenceFn, LibOpBitwiseOrNP.integrity, LibOpBitwiseOrNP.run, inputs
        );
    }

    /// Test the eval of bitwise OR parsed from a string.
    function testOpBitwiseORNPEval() external view {
        checkHappy("_: bitwise-or(0x00 0x00);", 0, "0 0");
        checkHappy("_: bitwise-or(0x00 0x01);", 1, "0 1");
        checkHappy("_: bitwise-or(0x01 0x00);", 1, "1 0");
        checkHappy("_: bitwise-or(0x01 0x01);", 1, "1 1");
        checkHappy("_: bitwise-or(0x00 0x02);", 2, "0 2");
        checkHappy("_: bitwise-or(0x02 0x00);", 2, "2 0");
        checkHappy("_: bitwise-or(0x01 0x02);", 3, "1 2");
        checkHappy("_: bitwise-or(0x02 0x01);", 3, "2 1");
        checkHappy("_: bitwise-or(0x02 0x02);", 2, "2 2");
        checkHappy("_: bitwise-or(0x00 0x03);", 3, "0 3");
        checkHappy("_: bitwise-or(0x03 0x00);", 3, "3 0");
        checkHappy("_: bitwise-or(0x01 0x03);", 3, "1 3");
        checkHappy("_: bitwise-or(0x03 0x01);", 3, "3 1");
        checkHappy("_: bitwise-or(0x02 0x03);", 3, "2 3");
        checkHappy("_: bitwise-or(0x03 0x02);", 3, "3 2");
        checkHappy("_: bitwise-or(0x03 0x03);", 3, "3 3");
    }

    /// Test that a bitwise OR with bad inputs fails integrity.
    function testOpBitwiseORNPEvalZeroInputs() external {
        checkBadInputs("_: bitwise-or();", 0, 2, 0);
    }

    function testOpBitwiseORNPEvalOneInput() external {
        checkBadInputs("_: bitwise-or(0);", 1, 2, 1);
    }

    function testOpBitwiseORNPEvalThreeInputs() external {
        checkBadInputs("_: bitwise-or(0 0 0);", 3, 2, 3);
    }

    function testOpBitwiseORNPEvalZeroOutputs() external {
        checkBadOutputs(": bitwise-or(0 0);", 2, 1, 0);
    }

    function testOpBitwiseORNPEvalTwoOutputs() external {
        checkBadOutputs("_ _: bitwise-or(0 0);", 2, 1, 2);
    }

    /// Test that operand is disallowed.
    function testOpBitwiseORNPEvalBadOperand() external {
        checkUnhappyParse("_: bitwise-or<0>(0 0);", abi.encodeWithSelector(UnexpectedOperand.selector));
    }
}
