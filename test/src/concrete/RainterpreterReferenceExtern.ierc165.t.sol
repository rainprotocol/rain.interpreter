// SPDX-License-Identifier: CAL
pragma solidity =0.8.25;

import {Test} from "forge-std/Test.sol";

import {IERC165} from "openzeppelin-contracts/contracts/utils/introspection/IERC165.sol";
import {IInterpreterExternV3} from "rain.interpreter.interface/interface/IInterpreterExternV3.sol";
import {ISubParserV3} from "rain.interpreter.interface/interface/ISubParserV3.sol";
import {RainterpreterReferenceExtern} from "src/concrete/extern/RainterpreterReferenceExtern.sol";
import {IDescribedByMetaV1} from "rain.metadata/interface/IDescribedByMetaV1.sol";

contract RainterpreterReferenceExternIERC165Test is Test {
    /// Test that ERC165 is implemented for the reference extern contract.
    function testRainterpreterReferenceExternIERC165(bytes4 badInterfaceId) external {
        vm.assume(badInterfaceId != type(IERC165).interfaceId);
        vm.assume(badInterfaceId != type(IInterpreterExternV3).interfaceId);
        vm.assume(badInterfaceId != type(ISubParserV3).interfaceId);
        vm.assume(badInterfaceId != type(IDescribedByMetaV1).interfaceId);

        RainterpreterReferenceExtern extern = new RainterpreterReferenceExtern();
        assertTrue(extern.supportsInterface(type(IERC165).interfaceId));
        assertTrue(extern.supportsInterface(type(IInterpreterExternV3).interfaceId));
        assertTrue(extern.supportsInterface(type(ISubParserV3).interfaceId));
        assertTrue(extern.supportsInterface(type(IDescribedByMetaV1).interfaceId));
        assertFalse(extern.supportsInterface(badInterfaceId));
    }
}
