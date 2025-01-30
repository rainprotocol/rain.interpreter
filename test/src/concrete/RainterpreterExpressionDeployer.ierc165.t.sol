// SPDX-License-Identifier: CAL
pragma solidity =0.8.25;

import {Test} from "forge-std/Test.sol";

import {IERC165} from "openzeppelin-contracts/contracts/utils/introspection/IERC165.sol";
import {
    RainterpreterExpressionDeployer,
    RainterpreterExpressionDeployerConstructionConfigV2
} from "src/concrete/RainterpreterExpressionDeployer.sol";
import {IParserPragmaV1} from "rain.interpreter.interface/interface/IParserPragmaV1.sol";
import {IParserV2} from "rain.interpreter.interface/interface/IParserV2.sol";
import {IDescribedByMetaV1} from "rain.metadata/interface/IDescribedByMetaV1.sol";
import {Rainterpreter} from "src/concrete/Rainterpreter.sol";
import {RainterpreterParser} from "src/concrete/RainterpreterParser.sol";
import {RainterpreterStore} from "src/concrete/RainterpreterStore.sol";

contract RainterpreterExpressionDeployerIERC165Test is Test {
    /// Test that ERC165 is implemented for all interfaces.
    function testRainterpreterExpressionDeployerIERC165(bytes4 badInterfaceId) external {
        vm.assume(badInterfaceId != type(IERC165).interfaceId);
        vm.assume(badInterfaceId != type(IDescribedByMetaV1).interfaceId);
        vm.assume(badInterfaceId != type(IParserV2).interfaceId);
        vm.assume(badInterfaceId != type(IParserPragmaV1).interfaceId);

        RainterpreterExpressionDeployer deployer = new RainterpreterExpressionDeployer(
            RainterpreterExpressionDeployerConstructionConfigV2(
                address(new Rainterpreter()), address(new RainterpreterStore()), address(new RainterpreterParser())
            )
        );
        assertTrue(deployer.supportsInterface(type(IERC165).interfaceId));
        vm.assume(badInterfaceId != type(IDescribedByMetaV1).interfaceId);
        vm.assume(badInterfaceId != type(IParserV2).interfaceId);
        vm.assume(badInterfaceId != type(IParserPragmaV1).interfaceId);

        assertFalse(deployer.supportsInterface(badInterfaceId));
    }
}
