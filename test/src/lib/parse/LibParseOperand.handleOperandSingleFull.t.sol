// SPDX-License-Identifier: CAL
pragma solidity =0.8.25;

import {Test} from "forge-std/Test.sol";
import {LibParseOperand, OperandV2} from "src/lib/parse/LibParseOperand.sol";
import {UnexpectedOperandValue} from "src/error/ErrParse.sol";
import {LibParseLiteral} from "src/lib/parse/literal/LibParseLiteral.sol";
import {OperandOverflow} from "src/error/ErrParse.sol";

contract LibParseOperandHandleOperandSingleFullTest is Test {
    // No values falls back to zero.
    function testHandleOperandSingleFullNoValues() external pure {
        assertEq(OperandV2.unwrap(LibParseOperand.handleOperandSingleFull(new uint256[](0))), 0);
    }

    // A single value of up to 2 bytes is allowed.
    function testHandleOperandSingleFullSingleValue(uint256 value) external pure {
        value = bound(value, 0, type(uint16).max);
        uint256[] memory values = new uint256[](1);
        values[0] = value;
        assertEq(OperandV2.unwrap(LibParseOperand.handleOperandSingleFull(values)), value);
    }

    // Single values outside 2 bytes are disallowed.
    function testHandleOperandSingleFullSingleValueDisallowed(uint256 value) external {
        value = bound(value, uint256(type(uint16).max) + 1, uint256(int256(type(int128).max)));
        uint256[] memory values = new uint256[](1);
        values[0] = value;
        vm.expectRevert(abi.encodeWithSelector(OperandOverflow.selector));
        LibParseOperand.handleOperandSingleFull(values);
    }

    // More than one value is disallowed.
    function testHandleOperandSingleFullManyValues(uint256[] memory values) external {
        vm.assume(values.length > 1);
        vm.expectRevert(abi.encodeWithSelector(UnexpectedOperandValue.selector));
        LibParseOperand.handleOperandSingleFull(values);
    }
}
