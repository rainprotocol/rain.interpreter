// SPDX-License-Identifier: CAL
pragma solidity =0.8.25;

import {Test} from "forge-std/Test.sol";
import {LibParseOperand, OperandV2} from "src/lib/parse/LibParseOperand.sol";
import {ExpectedOperand, UnexpectedOperandValue} from "src/error/ErrParse.sol";
import {LibParseLiteral} from "src/lib/parse/literal/LibParseLiteral.sol";
import {OperandOverflow} from "src/error/ErrParse.sol";

contract LibParseOperandHandleOperandM1M1Test is Test {
    // Both values are optional so if nothing is provided everything falls back
    // to zero.
    function testHandleOperandM1M1NoValues() external pure {
        assertEq(OperandV2.unwrap(LibParseOperand.handleOperandM1M1(new uint256[](0))), 0);
    }

    // If one value is provided it must be 1 bit.
    function testHandleOperandM1M1OneValue(uint256 value) external pure {
        value = bound(value, 0, 1);
        uint256[] memory values = new uint256[](1);
        values[0] = value;
        assertEq(OperandV2.unwrap(LibParseOperand.handleOperandM1M1(values)), value);
    }

    // If one value is provided and it is greater than 1 bit, it is an error.
    function testHandleOperandM1M1OneValueTooLarge(uint256 value) external {
        value = bound(value, 2, uint256(int256(type(int128).max)));

        uint256[] memory values = new uint256[](1);
        values[0] = value;
        vm.expectRevert(abi.encodeWithSelector(OperandOverflow.selector));
        LibParseOperand.handleOperandM1M1(values);
    }

    // If two values are provided, they must be 1 bit each.
    function testHandleOperandM1M1TwoValues(uint256 a, uint256 b) external pure {
        a = bound(a, 0, 1);
        b = bound(b, 0, 1);
        uint256[] memory values = new uint256[](2);
        values[0] = a;
        values[1] = b;
        assertEq(OperandV2.unwrap(LibParseOperand.handleOperandM1M1(values)), (b << 1) | a);
    }

    // If two values are provided and the second is greater than 1 bit, it is
    // an error.
    function testHandleOperandM1M1TwoValuesSecondValueTooLarge(uint256 a, uint256 b) external {
        a = bound(a, 0, 1);
        b = bound(b, 2, uint256(int256(type(int128).max)));

        uint256[] memory values = new uint256[](2);
        values[0] = a;
        values[1] = b;
        vm.expectRevert(abi.encodeWithSelector(OperandOverflow.selector));
        LibParseOperand.handleOperandM1M1(values);
    }

    // If more than two values are provided, it is an error.
    function testHandleOperandM1M1ManyValues(uint256[] memory values) external {
        vm.assume(values.length > 2);
        vm.expectRevert(abi.encodeWithSelector(UnexpectedOperandValue.selector));
        LibParseOperand.handleOperandM1M1(values);
    }
}
