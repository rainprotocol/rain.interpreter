// SPDX-License-Identifier: CAL
pragma solidity =0.8.25;

import "forge-std/Test.sol";

import "src/lib/integrity/LibIntegrityCheckNP.sol";
import "src/lib/state/LibInterpreterState.sol";
import "src/lib/op/LibAllStandardOpsNP.sol";

/// @title LibAllStandardOpsNPTest
/// Some basic guard rails around the `LibAllStandardOpsNP` library. Most of the
/// logic can only be tested by deploying an interpreter and running it.
contract LibAllStandardOpsNPTest is Test {
    /// Test that the dynamic length of the function pointers is correct.
    function testIntegrityFunctionPointersLength() external pure {
        bytes memory integrityFunctionPointers = LibAllStandardOpsNP.integrityFunctionPointers();
        assertEq(integrityFunctionPointers.length, ALL_STANDARD_OPS_LENGTH * 2);
    }

    /// Test that the dynamic length of the function pointers is correct.
    function testOpcodeFunctionPointersLength() external pure {
        bytes memory functionPointers = LibAllStandardOpsNP.opcodeFunctionPointers();
        // Each function pointer is 2 bytes.
        assertEq(functionPointers.length, ALL_STANDARD_OPS_LENGTH * 2);
    }

    /// Test that the integrity function pointers length and opcode function
    /// pointers length are the same.
    function testIntegrityAndOpcodeFunctionPointersLength() external pure {
        bytes memory integrityFunctionPointers = LibAllStandardOpsNP.integrityFunctionPointers();
        bytes memory functionPointers = LibAllStandardOpsNP.opcodeFunctionPointers();

        bytes memory authoringMeta = LibAllStandardOpsNP.authoringMetaV2();
        bytes32[] memory words = abi.decode(authoringMeta, (bytes32[]));

        assertEq(integrityFunctionPointers.length, functionPointers.length);
        assertEq(integrityFunctionPointers.length, words.length * 2);
    }
}
