// SPDX-License-Identifier: CAL
pragma solidity =0.8.25;

import {Test} from "forge-std/Test.sol";

import {IERC165} from "openzeppelin-contracts/contracts/utils/introspection/IERC165.sol";
import {RainterpreterStore} from "src/concrete/RainterpreterStore.sol";
import {IInterpreterStoreV2} from "rain.interpreter.interface/interface/IInterpreterStoreV2.sol";

contract RainterpreterStoreIERC165Test is Test {
    /// Test that ERC165 is implemented for all interfaces.
    function testRainterpreterStoreIERC165(bytes4 badInterfaceId) external {
        vm.assume(badInterfaceId != type(IERC165).interfaceId);
        vm.assume(badInterfaceId != type(IInterpreterStoreV2).interfaceId);

        RainterpreterStore store = new RainterpreterStore();
        assertTrue(store.supportsInterface(type(IERC165).interfaceId));
        assertTrue(store.supportsInterface(type(IInterpreterStoreV2).interfaceId));

        assertFalse(store.supportsInterface(badInterfaceId));
    }
}
