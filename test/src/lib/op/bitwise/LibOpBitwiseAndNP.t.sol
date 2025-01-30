// SPDX-License-Identifier: CAL
pragma solidity =0.8.25;

import {OpTest} from "test/abstract/OpTest.sol";
import {IntegrityCheckState} from "src/lib/integrity/LibIntegrityCheckNP.sol";
import {OperandV2} from "rain.interpreter.interface/interface/unstable/IInterpreterV4.sol";
import {LibOpBitwiseAndNP} from "src/lib/op/bitwise/LibOpBitwiseAndNP.sol";
import {InterpreterState} from "src/lib/state/LibInterpreterState.sol";
import {UnexpectedOperand} from "src/error/ErrParse.sol";
import {LibOperand} from "test/lib/operand/LibOperand.sol";

contract LibOpBitwiseAndNPTest is OpTest {
    /// Directly test the integrity logic of LibOpBitwiseAndNP. All possible
    /// operands result in the same number of inputs and outputs, (2, 1).
    function testOpBitwiseAndNPIntegrity(IntegrityCheckState memory state, OperandV2 operand) external pure {
        (uint256 calcInputs, uint256 calcOutputs) = LibOpBitwiseAndNP.integrity(state, operand);
        assertEq(calcInputs, 2);
        assertEq(calcOutputs, 1);
    }

    /// Directly test the runtime logic of LibOpBitwiseAndNP. This tests that the
    /// opcode correctly pushes the bitwise AND onto the stack.
    function testOpBitwiseAndNPRun(uint256 x, uint256 y) external view {
        InterpreterState memory state = opTestDefaultInterpreterState();
        uint256[] memory inputs = new uint256[](2);
        inputs[0] = x;
        inputs[1] = y;
        OperandV2 operand = LibOperand.build(2, 1, 0);
        opReferenceCheck(
            state, operand, LibOpBitwiseAndNP.referenceFn, LibOpBitwiseAndNP.integrity, LibOpBitwiseAndNP.run, inputs
        );
    }

    /// Test the eval of bitwise AND parsed from a string.
    function testOpBitwiseAndNPEvalHappy() external view {
        checkHappy("_: bitwise-and(0x00 0x00);", 0, "0 0");
        checkHappy("_: bitwise-and(0x00 0x01);", 0, "0 1");
        checkHappy("_: bitwise-and(0x01 0x00);", 0, "1 0");
        checkHappy("_: bitwise-and(0x01 0x01);", 1, "1 1");
        checkHappy("_: bitwise-and(0x00 0x02);", 0, "0 2");
        checkHappy("_: bitwise-and(0x02 0x00);", 0, "2 0");
        checkHappy("_: bitwise-and(0x01 0x02);", 0, "1 2");
        checkHappy("_: bitwise-and(0x02 0x01);", 0, "2 1");
        checkHappy("_: bitwise-and(0x02 0x02);", 2, "2 2");
        checkHappy("_: bitwise-and(0x00 0x03);", 0, "0 3");
        checkHappy("_: bitwise-and(0x03 0x00);", 0, "3 0");
        checkHappy("_: bitwise-and(0x01 0x03);", 1, "1 3");
        checkHappy("_: bitwise-and(0x03 0x01);", 1, "3 1");
        checkHappy("_: bitwise-and(0x02 0x03);", 2, "2 3");
        checkHappy("_: bitwise-and(0x03 0x02);", 2, "3 2");
        checkHappy("_: bitwise-and(0x03 0x03);", 3, "3 3");
    }

    /// Test that a bitwise OR with bad inputs fails integrity.
    function testOpBitwiseORNPEvalZeroInputs() external {
        checkBadInputs("_: bitwise-and();", 0, 2, 0);
    }

    function testOpBitwiseORNPEvalOneInput() external {
        checkBadInputs("_: bitwise-and(0);", 1, 2, 1);
    }

    function testOpBitwiseORNPEvalThreeInputs() external {
        checkBadInputs("_: bitwise-and(0 0 0);", 3, 2, 3);
    }

    function testOpBitwiseORNPEvalZeroOutputs() external {
        checkBadOutputs(": bitwise-and(0 0);", 2, 1, 0);
    }

    function testOpBitwiseORNPEvalTwoOutputs() external {
        checkBadOutputs("_ _: bitwise-and(0 0);", 2, 1, 2);
    }

    /// Test that operand is disallowed.
    function testOpBitwiseORNPEvalBadOperand() external {
        checkUnhappyParse("_: bitwise-and<0>(0 0);", abi.encodeWithSelector(UnexpectedOperand.selector));
    }
}
