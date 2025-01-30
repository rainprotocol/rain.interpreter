// SPDX-License-Identifier: CAL
pragma solidity =0.8.25;

import {Test} from "forge-std/Test.sol";
import {LibParseOperand, OperandV2} from "src/lib/parse/LibParseOperand.sol";
import {ExpectedOperand, UnexpectedOperandValue} from "src/error/ErrParse.sol";
import {LibParseLiteral} from "src/lib/parse/literal/LibParseLiteral.sol";
import {OperandOverflow} from "src/error/ErrParse.sol";

contract LibParseOperandHandleOperand8M1M1Test is Test {
    // The first value must be 1 byte and is mandatory. Zero values is an error.
    function testHandleOperand8M1M1NoValues() external {
        vm.expectRevert(abi.encodeWithSelector(ExpectedOperand.selector));
        LibParseOperand.handleOperand8M1M1(new uint256[](0));
    }

    // If only the first value is provided, the others default to zero.
    function testHandleOperand8M1M1FirstValueOnly(uint256 value) external pure {
        value = bound(value, 0, type(uint8).max);
        uint256[] memory values = new uint256[](1);
        values[0] = value;
        assertEq(OperandV2.unwrap(LibParseOperand.handleOperand8M1M1(values)), value);
    }

    // If the first value is greater than 1 byte, it is an error.
    function testHandleOperand8M1M1FirstValueTooLarge(int256 value) external {
        value = bound(value, int256(uint256(type(uint8).max)) + 1, type(int128).max);

        uint256[] memory values = new uint256[](1);
        values[0] = uint256(value);
        vm.expectRevert(abi.encodeWithSelector(OperandOverflow.selector));
        LibParseOperand.handleOperand8M1M1(values);
    }

    // If the first and second values are provided, the third defaults to zero.
    // The first value is 1 byte and the second is 1 bit.
    function testHandleOperand8M1M1FirstAndSecondValue(uint256 a, uint256 b) external pure {
        a = bound(a, 0, type(uint8).max);
        b = bound(b, 0, 1);
        uint256[] memory values = new uint256[](2);
        values[0] = a;
        values[1] = b;
        assertEq(OperandV2.unwrap(LibParseOperand.handleOperand8M1M1(values)), (b << 8) | a);
    }

    // If the first and second values are provided, the first value is 1 byte
    // but the second is greater than 1 bit, it is an error.
    function testHandleOperand8M1M1FirstAndSecondValueSecondValueTooLarge(uint256 a, uint256 b) external {
        a = bound(a, 0, type(uint8).max);
        b = bound(b, 2, uint256(int256(type(int128).max)));

        uint256[] memory values = new uint256[](2);
        values[0] = a;
        values[1] = b;
        vm.expectRevert(abi.encodeWithSelector(OperandOverflow.selector));
        LibParseOperand.handleOperand8M1M1(values);
    }

    // If all the values are provided they all appear in the operand.
    // The first value is 1 byte and the second is 1 bit, the third is 1 bit.
    function testHandleOperand8M1M1AllValues(uint256 a, uint256 b, uint256 c) external pure {
        a = bound(a, 0, type(uint8).max);
        b = bound(b, 0, 1);
        c = bound(c, 0, 1);
        uint256[] memory values = new uint256[](3);
        values[0] = a;
        values[1] = b;
        values[2] = c;
        assertEq(OperandV2.unwrap(LibParseOperand.handleOperand8M1M1(values)), (c << 9) | (b << 8) | a);
    }

    // If all the values are provided, the first is 1 byte, the second is 1 bit
    // but the third is greater than 1 bit, it is an error.
    function testHandleOperand8M1M1AllValuesThirdValueTooLarge(uint256 a, uint256 b, uint256 c) external {
        a = bound(a, 0, type(uint8).max);
        b = bound(b, 0, 1);
        c = bound(c, 2, uint256(int256(type(int128).max)));

        uint256[] memory values = new uint256[](3);
        values[0] = a;
        values[1] = b;
        values[2] = c;
        vm.expectRevert(abi.encodeWithSelector(OperandOverflow.selector));
        LibParseOperand.handleOperand8M1M1(values);
    }

    // If more than three values are provided, it is an error.
    function testHandleOperand8M1M1ManyValues(uint256[] memory values) external {
        vm.assume(values.length > 3);
        vm.expectRevert(abi.encodeWithSelector(UnexpectedOperandValue.selector));
        LibParseOperand.handleOperand8M1M1(values);
    }
}
