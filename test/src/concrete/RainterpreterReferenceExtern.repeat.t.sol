// SPDX-License-Identifier: CAL
pragma solidity =0.8.25;

import {OpTest} from "test/abstract/OpTest.sol";
import {RainterpreterReferenceExtern, StackItem} from "src/concrete/extern/RainterpreterReferenceExtern.sol";
import {Strings} from "openzeppelin-contracts/contracts/utils/Strings.sol";

contract RainterpreterReferenceExternRepeatTest is OpTest {
    using Strings for address;

    function testRainterpreterReferenceExternRepeatHappy() external {
        RainterpreterReferenceExtern extern = new RainterpreterReferenceExtern();
        string memory baseStr = string.concat("using-words-from ", address(extern).toHexString(), " ");

        StackItem[] memory expectedStack = new StackItem[](1);
        expectedStack[0] = StackItem.wrap(bytes32(uint256(999)));

        checkHappy(
            bytes(string.concat(baseStr, "nineninenine: [ref-extern-repeat-9 abc];")), expectedStack, "repeat 9 abc"
        );

        expectedStack[0] = StackItem.wrap(bytes32(uint256(88)));
        checkHappy(bytes(string.concat(baseStr, "eighteight: [ref-extern-repeat-8 zz];")), expectedStack, "repeat 8 zz");
    }
}
