// SPDX-License-Identifier: CAL
pragma solidity ^0.8.18;

import {Pointer} from "rain.solmem/lib/LibPointer.sol";
import {MemoryKV} from "rain.lib.memkv/lib/LibMemoryKV.sol";
import {
    FullyQualifiedNamespace,
    IInterpreterStoreV3
} from "rain.interpreter.interface/interface/unstable/IInterpreterStoreV3.sol";
import {StackItem} from "rain.interpreter.interface/interface/unstable/IInterpreterV4.sol";

address constant STACK_TRACER = address(uint160(uint256(keccak256("rain.interpreter.stack-tracer.0"))));

struct InterpreterState {
    Pointer[] stackBottoms;
    bytes32[] constants;
    uint256 sourceIndex;
    MemoryKV stateKV;
    FullyQualifiedNamespace namespace;
    IInterpreterStoreV3 store;
    bytes32[][] context;
    bytes bytecode;
    bytes fs;
}

library LibInterpreterState {
    function fingerprint(InterpreterState memory state) internal pure returns (bytes32) {
        return keccak256(abi.encode(state));
    }

    function stackBottoms(StackItem[][] memory stacks) internal pure returns (Pointer[] memory) {
        Pointer[] memory bottoms = new Pointer[](stacks.length);
        assembly ("memory-safe") {
            for {
                let cursor := add(stacks, 0x20)
                let end := add(cursor, mul(mload(stacks), 0x20))
                let bottomsCursor := add(bottoms, 0x20)
            } lt(cursor, end) {
                cursor := add(cursor, 0x20)
                bottomsCursor := add(bottomsCursor, 0x20)
            } {
                let stack := mload(cursor)
                let stackBottom := add(stack, mul(0x20, add(mload(stack), 1)))
                mstore(bottomsCursor, stackBottom)
            }
        }
        return bottoms;
    }

    /// Does something that a full node can easily track in its traces that isn't
    /// an event. Specifically, it calls the tracer contract with the memory
    /// region between `stackTop` and `stackBottom` as an argument. The source
    /// index is used literally as a 4 byte prefix to the memory region, so that
    /// it will be interpreted as a function selector by most tooling that is
    /// expecting ABI encoded data.
    ///
    /// The tracer contract doesn't exist, the whole point is that the call will
    /// be a no-op, but it will be visible in traces and unambiguous as no other
    /// call will be made to the tracer contract for any reason other than
    /// tracing stacks.
    ///
    /// Note that the trace is a literal memory region, no ABI encoding or other
    /// processing is done. The structure is 4 bytes of the source index, then
    /// 32 byte items for each stack item, in order from top to bottom.
    ///
    /// There are several reasons we do this instead of emitting an event:
    /// - It's cheaper. Way cheaper in the case of large stacks. There is a one
    ///   time 2600 gas cost to warm the tracer, then all subsequent calls are
    ///   just 100 gas + memory expansion cost. Using an empty contract means
    ///   there's no execution cost.
    ///   (vs. e.g. a solidity contract that would at least attempt a dispatch)
    ///   Meanwhile, emitting an event costs 375 gas plus 8 gas per byte, plus
    ///   the cost of the memory expansion.
    ///   Let's say we have 50 stack items spread over 5 calls:
    ///   - Using the tracer:
    ///     ( 2600 + 100 * 4 ) + (51 ** 2) / 512 + (3 * 51)
    ///     = 3000 + 2601 / 665
    ///     = 3000 + 4 ~= 3000
    ///   - Using an event (assuming same memory expansion cost):
    ///     (375 * 5) + (8 * 50 * 32) + 4
    ///     = 1875 + 12800 + 4
    ///     = 14679 (nearly 5x the cost!)
    /// - Events cannot be emitted from view functions, so we would have to
    ///   either abandon our view eval (security risk) or return every internal
    ///   stack back to the caller, to have it handle the event emission. This
    ///   would be both complex and onerous for caller implementations, and make
    ///   it much harder for tooling/consumers to reliably find all the data, as
    ///   it would be spread across callers in potentially inconsistent events.
    function stackTrace(uint256 parentSourceIndex, uint256 sourceIndex, Pointer stackTop, Pointer stackBottom)
        internal
        view
    {
        address tracer = STACK_TRACER;
        assembly ("memory-safe") {
            // We are mutating memory in place to avoid allocation, copying, etc.
            let beforePtr := sub(stackTop, 0x20)
            // We need to save the value at the pointer before we overwrite it.
            let before := mload(beforePtr)
            mstore(beforePtr, or(shl(0x10, parentSourceIndex), sourceIndex))
            // We don't care about success, we just want to call the tracer.
            let success := staticcall(gas(), tracer, sub(stackTop, 4), add(sub(stackBottom, stackTop), 4), 0, 0)
            // Restore the value at the pointer that we mutated above.
            mstore(beforePtr, before)
        }
    }
}
