// SPDX-License-Identifier: CAL
pragma solidity =0.8.25;

import {Test} from "forge-std/Test.sol";
import {OperandV2} from "rain.interpreter.interface/interface/unstable/IInterpreterV4.sol";
import {
    LibExtern, EncodedExternDispatchV2, ExternDispatchV2, IInterpreterExternV4
} from "src/lib/extern/LibExtern.sol";

/// @title LibExternCodecTest
/// Tests the encoding and decoding of the types associated with extern contract
/// calling and internal dispatch.
contract LibExternCodecTest is Test {
    /// Ensure `encodeExternDispatch` encodes the opcode and operand correctly.
    function testLibExternCodecEncodeExternDispatch(uint256 opcode, bytes32 operand) external pure {
        opcode = bound(opcode, 0, type(uint16).max);
        operand = bytes32(bound(uint256(operand), 0, type(uint16).max));
        ExternDispatchV2 dispatch = LibExtern.encodeExternDispatch(opcode, OperandV2.wrap(bytes32(operand)));
        (uint256 decodedOpcode, OperandV2 decodedOperand) = LibExtern.decodeExternDispatch(dispatch);
        assertEq(decodedOpcode, opcode);
        assertEq(OperandV2.unwrap(decodedOperand), operand);
    }

    /// Ensure `encodeExternCall` encodes the address and dispatch correctly.
    function testLibExternCodecEncodeExternCall(uint256 opcode, bytes32 operand) external pure {
        opcode = bound(opcode, 0, type(uint16).max);
        operand = bytes32(bound(uint256(operand), 0, type(uint16).max));
        IInterpreterExternV4 extern = IInterpreterExternV4(address(0x1234567890123456789012345678901234567890));
        ExternDispatchV2 dispatch = LibExtern.encodeExternDispatch(opcode, OperandV2.wrap(operand));
        EncodedExternDispatchV2 encoded = LibExtern.encodeExternCall(extern, dispatch);
        (IInterpreterExternV4 decodedExtern, ExternDispatchV2 decodedDispatch) = LibExtern.decodeExternCall(encoded);
        assertEq(uint256(uint160(address(decodedExtern))), uint256(uint160(address(extern))));
        assertEq(ExternDispatchV2.unwrap(decodedDispatch), ExternDispatchV2.unwrap(dispatch));
        (uint256 decodedOpcode, OperandV2 decodedOperand) = LibExtern.decodeExternDispatch(decodedDispatch);
        assertEq(decodedOpcode, opcode);
        assertEq(OperandV2.unwrap(decodedOperand), operand);
    }
}
