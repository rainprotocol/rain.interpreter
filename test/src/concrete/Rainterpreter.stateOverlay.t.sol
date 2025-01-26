// SPDX-License-Identifier: CAL
pragma solidity =0.8.25;

import {RainterpreterExpressionDeployerDeploymentTest} from
    "test/abstract/RainterpreterExpressionDeployerDeploymentTest.sol";
import {FullyQualifiedNamespace, StateNamespace} from "rain.interpreter.interface/interface/IInterpreterStoreV2.sol";
import {EvalV4, SourceIndexV2} from "rain.interpreter.interface/interface/unstable/IInterpreterV4.sol";
import {LibNamespace} from "rain.interpreter.interface/lib/ns/LibNamespace.sol";
import {LibDecimalFloat, PackedFloat} from "rain.math.float/lib/LibDecimalFloat.sol";

contract RainterpreterStateOverlayTest is RainterpreterExpressionDeployerDeploymentTest {
    /// Show that state overlay can prewarm a get.
    function testStateOverlayGet() external view {
        bytes memory bytecode = iDeployer.parse2("_: get(9);");

        uint256 k = LibDecimalFloat.pack(9e37, -37);
        uint256 v = 42;
        uint256[] memory stateOverlay = new uint256[](2);
        stateOverlay[0] = k;
        stateOverlay[1] = v;

        (uint256[] memory stack, uint256[] memory kvs) = iInterpreter.eval4(
            EvalV4({
                store: iStore,
                namespace: LibNamespace.qualifyNamespace(StateNamespace.wrap(0), address(this)),
                bytecode: bytecode,
                sourceIndex: SourceIndexV2.wrap(0),
                context: new uint256[][](0),
                inputs: new uint256[](0),
                stateOverlay: stateOverlay
            })
        );

        assertEq(stack.length, 1);
        assertEq(stack[0], v);
        assertEq(kvs.length, 2);
        assertEq(kvs[0], k);
        assertEq(kvs[1], v);
    }

    /// Show that state overlay can be overridden by a set in the bytecode.
    function testStateOverlaySet() external view {
        bytes memory bytecode = iDeployer.parse2("_:get(9),:set(9 42),_:get(9);");

        bytes32 k = LibDecimalFloat.pack(9e37, -37);
        bytes32 v = LibDecimalFloat.pack(43e37, -37);
        bytes32[] memory stateOverlay = new bytes32[](2);
        stateOverlay[0] = k;
        stateOverlay[1] = v;

        (bytes32[] memory stack, bytes32[] memory kvs) = iInterpreter.eval4(
            EvalV4({
                store: iStore,
                namespace: LibNamespace.qualifyNamespace(StateNamespace.wrap(0), address(this)),
                bytecode: bytecode,
                sourceIndex: SourceIndexV2.wrap(0),
                context: new bytes32[][](0),
                inputs: new bytes32[](0),
                stateOverlay: stateOverlay
            })
        );

        assertEq(stack.length, 2);
        assertEq(stack[0], PackedFloat.unwrap(LibDecimalFloat.pack(42e37, -37)));
        assertEq(stack[1], v);
        assertEq(kvs.length, 2);
        assertEq(kvs[0], k);
        assertEq(kvs[1], PackedFloat.unwrap(LibDecimalFloat.pack(42e37, -37)));
    }
}