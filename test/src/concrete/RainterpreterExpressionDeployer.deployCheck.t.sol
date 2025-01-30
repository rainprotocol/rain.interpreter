// SPDX-License-Identifier: CAL
pragma solidity =0.8.25;

import {Test} from "forge-std/Test.sol";

import {
    RainterpreterExpressionDeployer,
    RainterpreterExpressionDeployerConstructionConfigV2
} from "src/concrete/RainterpreterExpressionDeployer.sol";
import {RainterpreterStore} from "src/concrete/RainterpreterStore.sol";
import {RainterpreterParser} from "src/concrete/RainterpreterParser.sol";
import {Rainterpreter} from "src/concrete/Rainterpreter.sol";

/// @title RainterpreterExpressionDeployerDeployCheckTest
/// Test that the RainterpreterExpressionDeployer deploy check reverts if the
/// passed config does not match expectations.
contract RainterpreterExpressionDeployerDeployCheckTest is Test {
    /// Test the deployer can deploy if everything is valid.
    function testRainterpreterExpressionDeployerDeployNoEIP1820() external {
        new RainterpreterExpressionDeployer(
            RainterpreterExpressionDeployerConstructionConfigV2(
                address(new Rainterpreter()), address(new RainterpreterStore()), address(new RainterpreterParser())
            )
        );
    }
}
