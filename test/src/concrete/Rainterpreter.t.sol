// SPDX-License-Identifier: CAL
pragma solidity =0.8.25;

import {Test} from "forge-std/Test.sol";

import {Rainterpreter, OPCODE_FUNCTION_POINTERS} from "src/concrete/Rainterpreter.sol";

/// @title RainterpreterTest
/// Test suite for RainterpreterNP.
contract RainterpreterTest is Test {
    /// The function pointers of the interpreter must be even non-zero length.
    function testRainterpreterOddFunctionPointersLength() external pure {
        assertTrue(OPCODE_FUNCTION_POINTERS.length % 2 == 0);
        assertTrue(OPCODE_FUNCTION_POINTERS.length > 0);
    }
}
