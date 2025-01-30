// SPDX-License-Identifier: CAL
pragma solidity =0.8.25;

import {RainterpreterExpressionDeployerDeploymentTest} from
    "test/abstract/RainterpreterExpressionDeployerDeploymentTest.sol";
import {DESCRIBED_BY_META_HASH} from "src/concrete/RainterpreterExpressionDeployer.sol";

/// @title RainterpreterExpressionDeployerMetaTest
/// Tests that the RainterpreterExpressionDeployer meta is correct. Also
/// tests basic functionality of the `IParserV1View` interface implementation, except
/// parsing which is tested more extensively elsewhere.
contract RainterpreterExpressionDeployerMetaTest is RainterpreterExpressionDeployerDeploymentTest {
    /// Test that the expected construction meta hash can be read from the
    /// deployer.
    function testRainterpreterExpressionDeployerExpectedConstructionMetaHash() external view {
        bytes32 actualConstructionMetaHash = iDeployer.describedByMetaV1();
        assertEq(actualConstructionMetaHash, DESCRIBED_BY_META_HASH);
    }
}
