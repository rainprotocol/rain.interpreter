// SPDX-License-Identifier: CAL
pragma solidity =0.8.25;

import {Test} from "forge-std/Test.sol";
import {
    RainterpreterExpressionDeployer,
    RainterpreterExpressionDeployerConstructionConfigV2
} from "src/concrete/RainterpreterExpressionDeployer.sol";
import {Rainterpreter} from "src/concrete/Rainterpreter.sol";
import {RainterpreterStore} from "src/concrete/RainterpreterStore.sol";
import {RainterpreterParser} from "src/concrete/RainterpreterParser.sol";
import {EXPRESSION_DEPLOYER_NP_META_PATH} from "src/lib/constants/ExpressionDeployerNPConstants.sol";

contract RainterpreterExpressionDeployerDescribedByMetaV1Test is Test {
    function testRainterpreterExpressionDeployerDescribedByMetaV1Happy() external {
        bytes memory describedByMeta = vm.readFileBinary(EXPRESSION_DEPLOYER_NP_META_PATH);
        RainterpreterExpressionDeployer deployer = new RainterpreterExpressionDeployer(
            RainterpreterExpressionDeployerConstructionConfigV2(
                address(new Rainterpreter()), address(new RainterpreterStore()), address(new RainterpreterParser())
            )
        );

        assertEq(keccak256(describedByMeta), deployer.describedByMetaV1());
    }
}
