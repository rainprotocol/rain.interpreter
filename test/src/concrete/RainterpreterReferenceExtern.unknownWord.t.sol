// SPDX-License-Identifier: CAL
pragma solidity =0.8.25;

import {OpTest} from "test/abstract/OpTest.sol";
import {RainterpreterReferenceExtern} from "src/concrete/extern/RainterpreterReferenceExtern.sol";
import {Strings} from "openzeppelin-contracts/contracts/utils/Strings.sol";
import {UnknownWord} from "src/error/ErrParse.sol";

contract RainterpreterReferenceExternUnknownWordTest is OpTest {
    using Strings for address;

    function testRainterpreterReferenceExternUnknownWord() external {
        RainterpreterReferenceExtern extern = new RainterpreterReferenceExtern();

        checkUnhappyParse(
            bytes(string.concat("using-words-from ", address(extern).toHexString(), " _: not-a-word();")),
            abi.encodeWithSelector(UnknownWord.selector, "not-a-word")
        );
    }
}
