// SPDX-License-Identifier: CAL
pragma solidity =0.8.25;

import {Test} from "forge-std/Test.sol";

import {IERC165} from "openzeppelin-contracts/contracts/utils/introspection/IERC165.sol";
import {Rainterpreter} from "src/concrete/Rainterpreter.sol";
import {IInterpreterV4} from "rain.interpreter.interface/interface/unstable/IInterpreterV4.sol";

contract RainterpreterIERC165Test is Test {
    /// Test that ERC165 is implemented for all interfaces.
    function testRainterpreterIERC165(bytes4 badInterfaceId) external {
        vm.assume(badInterfaceId != type(IERC165).interfaceId);
        vm.assume(badInterfaceId != type(IInterpreterV4).interfaceId);

        Rainterpreter interpreter = new Rainterpreter();
        assertTrue(interpreter.supportsInterface(type(IERC165).interfaceId));
        assertTrue(interpreter.supportsInterface(type(IInterpreterV4).interfaceId));

        assertFalse(interpreter.supportsInterface(badInterfaceId));
    }
}
