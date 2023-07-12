// SPDX-License-Identifier: CAL
pragma solidity =0.8.19;

import "forge-std/Test.sol";

import "src/interface/IInterpreterExternV1.sol";
import "src/lib/extern/LibExtern.sol";

/// @title LibExternCodecTest
/// Tests the encoding and decoding of the types associated with extern contract
/// calling and internal dispatch.
contract LibExternCodecTest is Test {
    /// Ensure `encodeExternDispatch` encodes the opcode and operand correctly.
    function testLibExternCodecEncodeExternDispatch(uint256 opcode, uint256 operand) external {
        opcode = bound(opcode, 0, type(uint16).max);
        operand = bound(operand, 0, type(uint16).max);
        ExternDispatch dispatch = LibExtern.encodeExternDispatch(opcode, Operand.wrap(operand));
        (uint256 decodedOpcode, Operand decodedOperand) = LibExtern.decodeExternDispatch(dispatch);
        assertEq(decodedOpcode, opcode);
        assertEq(Operand.unwrap(decodedOperand), operand);
    }

    /// Ensure `encodeExternCall` encodes the address and dispatch correctly.
    function testLibExternCodecEncodeExternCall(uint256 opcode, uint256 operand) external {
        opcode = bound(opcode, 0, type(uint16).max);
        operand = bound(operand, 0, type(uint16).max);
        IInterpreterExternV1 extern = IInterpreterExternV1(address(0x1234567890123456789012345678901234567890));
        ExternDispatch dispatch = LibExtern.encodeExternDispatch(opcode, Operand.wrap(uint16(operand)));
        EncodedExternDispatch encoded = LibExtern.encodeExternCall(extern, dispatch);
        (IInterpreterExternV1 decodedExtern, ExternDispatch decodedDispatch) = LibExtern.decodeExternCall(encoded);
        assertEq(uint256(uint160(address(decodedExtern))), uint256(uint160(address(extern))));
        assertEq(ExternDispatch.unwrap(decodedDispatch), ExternDispatch.unwrap(dispatch));
        (uint256 decodedOpcode, Operand decodedOperand) = LibExtern.decodeExternDispatch(decodedDispatch);
        assertEq(decodedOpcode, opcode);
        assertEq(Operand.unwrap(decodedOperand), operand);
    }
}
