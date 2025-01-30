// SPDX-License-Identifier: CAL
pragma solidity ^0.8.18;

import {LibUint256Array} from "rain.solmem/lib/LibUint256Array.sol";
import {LibInterpreterState, STACK_TRACER} from "src/lib/state/LibInterpreterState.sol";
import {Test} from "forge-std/Test.sol";

contract LibInterpreterStateStackTraceTest is Test {
    using LibUint256Array for uint256[];

    function testStackTraceCall(uint256 parentSourceIndex, uint256 sourceIndex, uint256[] memory inputs) external {
        parentSourceIndex = bound(parentSourceIndex, 0, 0xFFFF);
        sourceIndex = bound(sourceIndex, 0, 0xFFFF);
        uint256 lengthBefore = inputs.length;
        vm.expectCall(
            STACK_TRACER, abi.encodePacked(bytes2(uint16(parentSourceIndex)), bytes2(uint16(sourceIndex)), inputs), 1
        );
        LibInterpreterState.stackTrace(parentSourceIndex, sourceIndex, inputs.dataPointer(), inputs.endPointer());
        // Check we didn't corrupt the inputs length while mutating memory.
        assertEq(inputs.length, lengthBefore);
    }
}
