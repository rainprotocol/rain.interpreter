// SPDX-License-Identifier: CAL
pragma solidity =0.8.25;

import {Test} from "forge-std/Test.sol";
import {RainterpreterReferenceExtern} from "src/concrete/extern/RainterpreterReferenceExtern.sol";

contract RainterpreterReferenceExternDescribedByMetaV1 is Test {
    function testRainterpreterReferenceExternDescribedByMetaV1Happy() external {
        RainterpreterReferenceExtern extern = new RainterpreterReferenceExtern();
        bytes memory describedByMeta = vm.readFileBinary("meta/RainterpreterReferenceExtern.rain.meta");

        assertEq(keccak256(describedByMeta), extern.describedByMetaV1());
    }
}
