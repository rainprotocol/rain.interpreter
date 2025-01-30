// SPDX-License-Identifier: CAL
pragma solidity ^0.8.18;

import {MemoryKV} from "rain.lib.memkv/lib/LibMemoryKV.sol";
import {Pointer} from "rain.solmem/lib/LibPointer.sol";
import {LibMemCpy} from "rain.solmem/lib/LibMemCpy.sol";
import {LibBytes} from "rain.solmem/lib/LibBytes.sol";
import {FullyQualifiedNamespace} from "rain.interpreter.interface/interface/unstable/IInterpreterV4.sol";
import {IInterpreterStoreV3} from "rain.interpreter.interface/interface/unstable/IInterpreterStoreV3.sol";

import {InterpreterState} from "./LibInterpreterState.sol";

library LibInterpreterStateDataContract {
    using LibBytes for bytes;

    function serializeSize(bytes memory bytecode, bytes32[] memory constants) internal pure returns (uint256 size) {
        unchecked {
            // bytecode length + constants length * 0x20 + 0x40 for both the bytecode and constants length words.
            size = bytecode.length + constants.length * 0x20 + 0x40;
        }
    }

    function unsafeSerialize(Pointer cursor, bytes memory bytecode, bytes32[] memory constants) internal pure {
        unchecked {
            // Copy constants into place with length.
            assembly ("memory-safe") {
                for {
                    let constantsCursor := constants
                    let constantsEnd := add(constantsCursor, mul(0x20, add(mload(constants), 1)))
                } lt(constantsCursor, constantsEnd) {
                    constantsCursor := add(constantsCursor, 0x20)
                    cursor := add(cursor, 0x20)
                } { mstore(cursor, mload(constantsCursor)) }
            }
            // Copy the bytecode into place with length.
            LibMemCpy.unsafeCopyBytesTo(bytecode.startPointer(), cursor, bytecode.length + 0x20);
        }
    }

    function unsafeDeserialize(
        bytes memory serialized,
        uint256 sourceIndex,
        FullyQualifiedNamespace namespace,
        IInterpreterStoreV3 store,
        bytes32[][] memory context,
        bytes memory fs
    ) internal pure returns (InterpreterState memory) {
        unchecked {
            Pointer cursor;
            assembly ("memory-safe") {
                cursor := add(serialized, 0x20)
            }

            // Reference the constants array as-is and move cursor past it.
            bytes32[] memory constants;
            assembly ("memory-safe") {
                constants := cursor
                cursor := add(cursor, mul(0x20, add(mload(cursor), 1)))
            }

            // Reference the bytecode array as-is.
            bytes memory bytecode;
            assembly ("memory-safe") {
                bytecode := cursor
            }

            // Build all the stacks.
            Pointer[] memory stackBottoms;
            assembly ("memory-safe") {
                cursor := add(cursor, 0x20)
                let stacksLength := byte(0, mload(cursor))
                cursor := add(cursor, 1)
                let sourcesStart := add(cursor, mul(stacksLength, 2))

                // Allocate the memory for stackBottoms.
                // We don't need to zero this because we're about to write to it.
                stackBottoms := mload(0x40)
                mstore(stackBottoms, stacksLength)
                mstore(0x40, add(stackBottoms, mul(add(stacksLength, 1), 0x20)))

                // Allocate each stack and point to it.
                let stacksCursor := add(stackBottoms, 0x20)
                for { let i := 0 } lt(i, stacksLength) {
                    i := add(i, 1)
                    // Move over the 2 byte source pointer.
                    cursor := add(cursor, 2)
                    // Move the stacks cursor forward.
                    stacksCursor := add(stacksCursor, 0x20)
                } {
                    // The stack size is in the prefix of the source data, which
                    // is behind a relative pointer in the bytecode prefix.
                    let sourcePointer := add(sourcesStart, shr(0xf0, mload(cursor)))
                    // Stack size is the second byte of the source prefix.
                    let stackSize := byte(1, mload(sourcePointer))

                    // Allocate the stack.
                    // We don't need to zero the stack because the interpreter
                    // assumes values above the stack top are dirty anyway.
                    let stack := mload(0x40)
                    mstore(stack, stackSize)
                    let stackBottom := add(stack, mul(add(stackSize, 1), 0x20))
                    mstore(0x40, stackBottom)

                    // Point to the stack bottom
                    mstore(stacksCursor, stackBottom)
                }
            }

            return InterpreterState(
                stackBottoms, constants, sourceIndex, MemoryKV.wrap(0), namespace, store, context, bytecode, fs
            );
        }
    }
}
