// SPDX-License-Identifier: CAL
pragma solidity =0.8.25;

import {Test} from "forge-std/Test.sol";
import {Rainterpreter, OPCODE_FUNCTION_POINTERS} from "src/concrete/Rainterpreter.sol";

contract RainterpreterPointersTest is Test {
    function testOpcodeFunctionPointers() external {
        Rainterpreter interpreter = new Rainterpreter();
        bytes memory expected = interpreter.buildOpcodeFunctionPointers();
        bytes memory actual = OPCODE_FUNCTION_POINTERS;
        assertEq(actual, expected);
    }
}
