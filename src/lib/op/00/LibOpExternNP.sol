// SPDX-License-Identifier: CAL
pragma solidity ^0.8.18;

import {NotAnExternContract} from "../../../error/ErrExtern.sol";
import {IntegrityCheckState} from "../../integrity/LibIntegrityCheckNP.sol";
import {OperandV2} from "rain.interpreter.interface/interface/unstable/IInterpreterV4.sol";
import {InterpreterState} from "../../state/LibInterpreterState.sol";
import {Pointer} from "rain.solmem/lib/LibPointer.sol";
import {
    IInterpreterExternV4,
    ExternDispatchV2,
    EncodedExternDispatchV2,
    StackItem
} from "rain.interpreter.interface/interface/unstable/IInterpreterExternV4.sol";
import {LibExtern} from "../../extern/LibExtern.sol";
import {LibMemCpy} from "rain.solmem/lib/LibMemCpy.sol";
import {LibUint256Array} from "rain.solmem/lib/LibUint256Array.sol";
import {LibBytes32Array} from "rain.solmem/lib/LibBytes32Array.sol";
import {ERC165Checker} from "openzeppelin-contracts/contracts/utils/introspection/ERC165Checker.sol";

/// Thrown when a constant read index is outside the constants array.
error OutOfBoundsConstantRead(uint256 opIndex, uint256 constantsLength, uint256 constantRead);

/// Thrown when the outputs length is not equal to the expected length.
error BadOutputsLength(uint256 expectedLength, uint256 actualLength);

/// @title LibOpExternNP
/// @notice Implementation of calling an external contract.
library LibOpExternNP {
    using LibUint256Array for uint256[];

    function integrity(IntegrityCheckState memory state, OperandV2 operand) internal view returns (uint256, uint256) {
        uint256 encodedExternDispatchIndex = uint256(OperandV2.unwrap(operand) & bytes32(uint256(0xFFFF)));

        EncodedExternDispatchV2 encodedExternDispatch =
            EncodedExternDispatchV2.wrap(state.constants[encodedExternDispatchIndex]);
        (IInterpreterExternV4 extern, ExternDispatchV2 dispatch) = LibExtern.decodeExternCall(encodedExternDispatch);
        if (!ERC165Checker.supportsInterface(address(extern), type(IInterpreterExternV4).interfaceId)) {
            revert NotAnExternContract(address(extern));
        }
        uint256 expectedInputsLength = uint256((OperandV2.unwrap(operand) >> 0x10) & bytes32(uint256(0x0F)));
        uint256 expectedOutputsLength = uint256((OperandV2.unwrap(operand) >> 0x14) & bytes32(uint256(0x0F)));
        //slither-disable-next-line unused-return
        return extern.externIntegrity(dispatch, expectedInputsLength, expectedOutputsLength);
    }

    function run(InterpreterState memory state, OperandV2 operand, Pointer stackTop) internal view returns (Pointer) {
        uint256 encodedExternDispatchIndex = uint256(OperandV2.unwrap(operand) & bytes32(uint256(0xFFFF)));
        uint256 inputsLength = uint256((OperandV2.unwrap(operand) >> 0x10) & bytes32(uint256(0x0F)));
        uint256 outputsLength = uint256((OperandV2.unwrap(operand) >> 0x14) & bytes32(uint256(0x0F)));

        bytes32 encodedExternDispatch = state.constants[encodedExternDispatchIndex];
        (IInterpreterExternV4 extern, ExternDispatchV2 dispatch) =
            LibExtern.decodeExternCall(EncodedExternDispatchV2.wrap(encodedExternDispatch));
        StackItem[] memory inputs;
        uint256 head;
        assembly ("memory-safe") {
            // Mutate the word before the current stack top to be the length of
            // the inputs array so we can treat it as an inputs array. This will
            // either mutate memory allocated to the stack that is not currently
            // in use, or the length of the stack array itself, which will need
            // to be repaired after the call. We store the original value of the
            // word before the stack top so we can restore it after the call,
            // just in case it is the latter scenario.
            inputs := sub(stackTop, 0x20)
            head := mload(inputs)
            mstore(inputs, inputsLength)
        }
        StackItem[] memory outputs = extern.extern(dispatch, inputs);
        if (outputsLength != outputs.length) {
            revert BadOutputsLength(outputsLength, outputs.length);
        }

        assembly ("memory-safe") {
            // Restore whatever was in memory before we built our inputs array.
            // Inputs is no longer safe to use after this point.
            mstore(inputs, head)
            stackTop := add(stackTop, mul(inputsLength, 0x20))
            // Copy outputs out.
            let sourceCursor := add(outputs, 0x20)
            let end := add(sourceCursor, mul(outputsLength, 0x20))
            // We loop this backwards so that the 0th output is _lowest_ on the
            // stack, which visually maps to:
            // `a b: extern<x 2>(a b);`
            // If the extern implementation is an identity function and has both
            // inputs and outputs as `[a, b]`.
            for {} lt(sourceCursor, end) { sourceCursor := add(sourceCursor, 0x20) } {
                stackTop := sub(stackTop, 0x20)
                mstore(stackTop, mload(sourceCursor))
            }
        }
        return stackTop;
    }

    function referenceFn(InterpreterState memory state, OperandV2 operand, StackItem[] memory inputs)
        internal
        view
        returns (StackItem[] memory outputs)
    {
        uint256 encodedExternDispatchIndex = uint256(OperandV2.unwrap(operand) & bytes32(uint256(0xFFFF)));
        uint256 outputsLength = uint256((OperandV2.unwrap(operand) >> 0x14) & bytes32(uint256(0x0F)));

        bytes32 encodedExternDispatch = state.constants[encodedExternDispatchIndex];
        (IInterpreterExternV4 extern, ExternDispatchV2 dispatch) =
            LibExtern.decodeExternCall(EncodedExternDispatchV2.wrap(encodedExternDispatch));
        outputs = extern.extern(dispatch, inputs);
        if (outputs.length != outputsLength) {
            revert BadOutputsLength(outputsLength, outputs.length);
        }
        // The stack is built backwards, so we need to reverse the outputs.
        bytes32[] memory outputsBytes32;
        assembly {
            outputsBytes32 := outputs
        }
        LibBytes32Array.reverse(outputsBytes32);
    }
}
