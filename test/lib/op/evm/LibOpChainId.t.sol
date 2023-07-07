// SPDX-License-Identifier: CAL
pragma solidity ^0.8.18;

import "forge-std/Test.sol";

import "sol.lib.memory/LibPointer.sol";
import "sol.lib.memory/LibStackPointer.sol";

import "src/lib/state/LibInterpreterState.sol";
import "src/lib/op/evm/LibOpChainId.sol";
import "src/lib/caller/LibContext.sol";

import "src/concrete/RainterpreterNP.sol";
import "src/concrete/RainterpreterStore.sol";
import "src/concrete/RainterpreterExpressionDeployerNP.sol";

/// @title LibOpChainIdTest
/// @notice Test the runtime and integrity time logic of LibOpChainId.
contract LibOpChainIdTest is Test {
    using LibPointer for Pointer;
    using LibStackPointer for Pointer;
    using LibInterpreterState for InterpreterState;

    function testOpChainIDRun(InterpreterState memory state, Operand operand, uint256 pre, uint256 post) external {
        // Build a stack with two zeros on it. The first zero will be overridden
        // by the opcode. The second zero will be used to check that the opcode
        // doesn't modify the stack beyond the first element.
        state.stackBottom = LibPointer.allocatedMemoryPointer();
        Pointer stackTop = state.stackBottom.unsafePush(pre);
        Pointer end = stackTop.unsafePush(0).unsafePush(post);
        assembly ("memory-safe") {
            mstore(0x40, end)
        }

        // Chain ID doesn't modify the state.
        bytes32 stateFingerprintBefore = state.fingerprint();

        // Run the opcode.
        Pointer stackTopAfter = LibOpChainId.run(state, operand, stackTop);

        bytes32 stateFingerprintAfter = state.fingerprint();
        assertEq(stateFingerprintBefore, stateFingerprintAfter);

        // The chain ID should be on the stack without modifying any other data.
        assertEq(state.stackBottom.unsafeReadWord(), pre);
        assertEq(stackTop.unsafeReadWord(), block.chainid);
        assertEq(stackTopAfter.unsafeReadWord(), post);
    }

    function testOpChainIDEval() external {
        RainterpreterNP interpreter = new RainterpreterNP();
        RainterpreterStore store = new RainterpreterStore();
        // magic number.
        bytes memory meta = hex"ff0a89c674ee7874";
        vm.etch(address(IERC1820_REGISTRY), hex"00");
        vm.mockCall(address(IERC1820_REGISTRY), "", abi.encode(true));
        RainterpreterExpressionDeployerNP deployer =
        new RainterpreterExpressionDeployerNP(RainterpreterExpressionDeployerConstructionConfig(
            address(interpreter),
            address(store),
            meta
        ));
        (bytes[] memory sources, uint256[] memory constants) = deployer.parse("_: chain-id();");
        uint256[] memory minOutputs = new uint256[](1);
        minOutputs[0] = 1;
        (IInterpreterV1 interpreterDeployer, IInterpreterStoreV1 storeDeployer, address expression) =
            deployer.deployExpression(sources, constants, minOutputs);
        (uint256[] memory stack, uint256[] memory kvs) = interpreterDeployer.eval(
            storeDeployer,
            StateNamespace.wrap(0),
            LibEncodedDispatch.encode(expression, SourceIndex.wrap(0), 1),
            LibContext.build(new uint256[][](0), new SignedContextV1[](0))
        );
        assertEq(stack.length, 1);
        assertEq(stack[0], block.chainid);
        assertEq(kvs.length, 0);
    }
}