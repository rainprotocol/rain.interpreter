// SPDX-License-Identifier: CAL
pragma solidity =0.8.25;

import {Test} from "forge-std/Test.sol";
import {LibParseOperand, OperandV2} from "src/lib/parse/LibParseOperand.sol";
import {UnexpectedOperand} from "src/error/ErrParse.sol";

contract LibParseOperandHandleOperandDisallowedTest is Test {
    function testHandleOperandDisallowedNoValues() external pure {
        assertEq(OperandV2.unwrap(LibParseOperand.handleOperandDisallowed(new uint256[](0))), 0);
    }

    function testHandleOperandDisallowedAnyValues(uint256[] memory values) external {
        vm.assume(values.length > 0);
        vm.expectRevert(abi.encodeWithSelector(UnexpectedOperand.selector));
        LibParseOperand.handleOperandDisallowed(values);
    }
}
