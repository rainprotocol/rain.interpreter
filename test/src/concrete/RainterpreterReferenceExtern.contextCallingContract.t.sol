// SPDX-License-Identifier: CAL
pragma solidity =0.8.25;

import {OpTest} from "test/abstract/OpTest.sol";
import {Strings} from "openzeppelin-contracts/contracts/utils/Strings.sol";
import {RainterpreterReferenceExtern, StackItem} from "src/concrete/extern/RainterpreterReferenceExtern.sol";

contract RainterpreterReferenceExternContextSenderTest is OpTest {
    using Strings for address;

    function testRainterpreterReferenceExterNPE2ContextContractHappy() external {
        RainterpreterReferenceExtern extern = new RainterpreterReferenceExtern();

        StackItem[] memory expectedStack = new StackItem[](1);
        expectedStack[0] = StackItem.wrap(bytes32(uint256(uint160(address(this)))));

        checkHappy(
            bytes(
                string.concat(
                    "using-words-from ",
                    address(extern).toHexString(),
                    " calling-contract: ref-extern-context-contract();"
                )
            ),
            expectedStack,
            "calling-contract"
        );
    }
}
