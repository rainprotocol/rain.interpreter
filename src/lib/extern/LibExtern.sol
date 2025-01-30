// SPDX-License-Identifier: CAL
pragma solidity ^0.8.18;

import {OperandV2} from "rain.interpreter.interface/interface/unstable/IInterpreterV4.sol";
import {
    IInterpreterExternV4,
    ExternDispatchV2,
    EncodedExternDispatchV2,
    StackItem
} from "rain.interpreter.interface/interface/unstable/IInterpreterExternV4.sol";

/// @title LibExtern
/// Defines and implements an encoding and decoding scheme for the data that
/// controls the behaviour of externs.
library LibExtern {
    /// Converts an opcode and operand pair into a single 32-byte word.
    /// The encoding scheme is:
    /// - bits [0,16): the operand
    /// - bits [16,32): the opcode
    /// IMPORTANT: The encoding process does not check that either the opcode or
    /// operand fit within 16 bits. This is the responsibility of the caller.
    function encodeExternDispatch(uint256 opcode, OperandV2 operand) internal pure returns (ExternDispatchV2) {
        return ExternDispatchV2.wrap(bytes32(opcode) << 0x10 | OperandV2.unwrap(operand));
    }

    /// Inverse of `encodeExternDispatch`.
    function decodeExternDispatch(ExternDispatchV2 dispatch) internal pure returns (uint256, OperandV2) {
        return (
            uint256(ExternDispatchV2.unwrap(dispatch) >> 0x10),
            OperandV2.wrap(ExternDispatchV2.unwrap(dispatch) & bytes32(uint256(0xFFFF)))
        );
    }

    /// Encodes an extern address and dispatch pair into a single 32-byte word.
    /// This is the full data required to actually call an extern contract.
    /// The encoding scheme is:
    /// - bits [0,160): the address of the extern contract
    /// - bits [160,176): the dispatch operand
    /// - bits [176,192): the dispatch opcode
    /// Note that the high bits are implied by a correctly encoded
    /// `ExternDispatch`. Use `encodeExternDispatch` to ensure this.
    /// IMPORTANT: The encoding process does not check that any of the values
    /// fit within their respective bit ranges. This is the responsibility of
    /// the caller.
    function encodeExternCall(IInterpreterExternV4 extern, ExternDispatchV2 dispatch)
        internal
        pure
        returns (EncodedExternDispatchV2)
    {
        return EncodedExternDispatchV2.wrap(
            bytes32(uint256(uint160(address(extern)))) | ExternDispatchV2.unwrap(dispatch) << 160
        );
    }

    /// Inverse of `encodeExternCall`.
    function decodeExternCall(EncodedExternDispatchV2 dispatch)
        internal
        pure
        returns (IInterpreterExternV4, ExternDispatchV2)
    {
        return (
            IInterpreterExternV4(address(uint160(uint256(EncodedExternDispatchV2.unwrap(dispatch))))),
            ExternDispatchV2.wrap(EncodedExternDispatchV2.unwrap(dispatch) >> 160)
        );
    }
}
