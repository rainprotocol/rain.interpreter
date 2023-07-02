// SPDX-License-Identifier: CAL
pragma solidity ^0.8.18;

import "sol.lib.memory/LibPointer.sol";
import "./LibCtPop.sol";
import "./LibParseMeta.sol";

import "forge-std/console2.sol";

/// The expression does not finish with a semicolon (EOF).
error MissingFinalSemi(uint256 offset);

/// Enountered an unexpected character on the LHS.
error UnexpectedLHSChar(uint256 offset, string char);

/// Encountered an unexpected character on the RHS.
error UnexpectedRHSChar(uint256 offset, string char);

/// Enountered a word that is longer than 32 bytes.
error WordSize(bytes32 wordStart);

/// Parsed a word that is not in the meta.
error UnknownWord(bytes32 word);

/// The parser exceeded the maximum number of sources that it can build.
error MaxSources();

/// The parser encountered a dangling source. This is a bug in the parser.
error DanglingSource();

/// @dev \t
uint128 constant CMASK_TAB = 0x200;

/// @dev \n
uint128 constant CMASK_LINE_FEED = 0x400;

/// @dev \r
uint128 constant CMASK_CARRIAGE_RETURN = 0x2000;

/// @dev space
uint128 constant CMASK_SPACE = 0x0100000000;

/// @dev ,
uint128 constant CMASK_COMMA = 0x100000000000;
uint128 constant CMASK_EOL = CMASK_COMMA;

/// @dev -
uint128 constant CMASK_DASH = 0x200000000000;

/// @dev :
uint128 constant CMASK_COLON = 0x0400000000000000;
/// @dev LHS/RHS delimiter is :
uint128 constant CMASK_LHS_RHS_DELIMITER = CMASK_COLON;

/// @dev ;
uint128 constant CMASK_SEMICOLON = 0x800000000000000;
uint128 constant CMASK_EOS = CMASK_SEMICOLON;

/// @dev _
uint128 constant CMASK_UNDERSCORE = 0x800000000000000000000000;

/// @dev (
uint128 constant CMASK_LEFT_PAREN = 0x10000000000;

/// @dev )
uint128 constant CMASK_RIGHT_PAREN = 0x20000000000;

/// @dev lower alpha and underscore a-z _
uint128 constant CMASK_LHS_STACK_HEAD = 0xffffffe800000000000000000000000;

/// @dev lower alpha a-z
uint128 constant CMASK_IDENTIFIER_HEAD = 0xffffffe000000000000000000000000;
uint128 constant CMASK_RHS_WORD_HEAD = CMASK_IDENTIFIER_HEAD;

/// @dev lower alphanumeric kebab a-z 0-9 -
uint128 constant CMASK_IDENTIFIER_TAIL = 0xffffffe0000000003ff200000000000;
uint128 constant CMASK_LHS_STACK_TAIL = CMASK_IDENTIFIER_TAIL;
uint128 constant CMASK_RHS_WORD_TAIL = CMASK_IDENTIFIER_TAIL;

/// @dev NOT lower alphanumeric kebab
uint128 constant CMASK_NOT_IDENTIFIER_TAIL = 0xf0000001fffffffffc00dfffffffffff;

/// @dev stack item delimiter is space
uint128 constant CMASK_LHS_STACK_DELIMITER = 0x0100000000;

/// @dev whitespace is \n \r \t space
uint128 constant CMASK_WHITESPACE = 0x100002600;


uint256 constant NOT_LOW_16_BIT_MASK = ~uint256(0xFFFF);
uint256 constant ACTIVE_SOURCE_MASK = NOT_LOW_16_BIT_MASK;

uint256 constant FSM_LHS_MASK = 1;
uint256 constant FSM_YANG_MASK = 1 << 1;
uint256 constant FSM_WORD_END_MASK = 1 << 2;

uint256 constant EMPTY_ACTIVE_SOURCE = 0x20;

/// The parser is stateful. This struct keeps track of the entire state.
/// @param fsm The finite state machine representation of the parser.
/// - bit 0: LHS/RHS => 0 = LHS, 1 = RHS
/// - bit 1: yang/yin => 0 = yin, 1 = yang
/// - bit 2: word end => 0 = not end, 1 = end
struct ParseState {
    uint256 fsm;
    uint256 stackIndex;
    uint256 stackNames;
    // low 16 bits = bitwise offset (starts at 0x20)
    // mid 16 bits = LL pointer
    // high bits = 4 byte ops
    uint256 activeSource;
    uint256 sourcesBuilder;
    uint256 constantsBuilder;
}

type Bitmap is uint256;

error NoSeedFound();

library LibParseState {
    function newState() internal pure returns (ParseState memory) {
        return ParseState(FSM_LHS_MASK, 0, 0, EMPTY_ACTIVE_SOURCE, 0, 0);
    }

    function pushStackName(ParseState memory state, bytes32 word) internal pure {
        uint256 fingerprint;
        uint256 ptr;
        uint256 oldStackNames = state.stackNames;
        assembly ("memory-safe") {
            ptr := mload(0x40)
            mstore(ptr, word)
            fingerprint := and(keccak256(ptr, 0x20), not(0xFFFFFFFF))
            mstore(ptr, oldStackNames)
            mstore(0x40, add(ptr, 0x20))
        }
        state.stackNames = fingerprint | (state.stackIndex << 0x10) | ptr;
    }

    function pushWordToSource(ParseState memory state, bytes memory meta, bytes32 word) internal pure {
        unchecked {
            (bool exists, uint256 i) = LibParseMeta.lookupIndexMetaExpander(meta, word);

            uint256 activeSource = state.activeSource;
            // The low byte of the active source is the current offset.
            uint256 offset = uint8(activeSource);

            // We write sources RTL so they can run LTR.
            activeSource =
            // increment offset. We have 16 bits allocated to the offset and stop
            // processing at 0x100 so this never overflows into the actual source
            // data.
            activeSource + 0x20
            // include new op
            | i << (offset + 0x10);

            // Maintenance branches.
            if (!exists) {
                revert UnknownWord(word);
            }
            if (offset == 0xe0) {
                uint256 ptr;
                assembly ("memory-safe") {
                    ptr := mload(0x40)
                    mstore(ptr, activeSource)
                    mstore(0x40, add(ptr, 0x20))
                }
                activeSource = EMPTY_ACTIVE_SOURCE | (ptr << 0x10);
            }

            state.activeSource = activeSource;
        }
    }

    function newSource(ParseState memory state) internal pure {
        uint256 sourcesBuilder = state.sourcesBuilder;
        uint256 offset = sourcesBuilder >> 0xf0;
        uint256 activeSource = state.activeSource;

        if (offset == 0xf0) {
            revert MaxSources();
        } else {
            // close out the LL to fixed solidity compatible bytes.
            uint256 source;
            assembly ("memory-safe") {
                source := mload(0x40)
                let cursor := add(source, 0x20)

                // handle the head first
                let activeSourceOffset := and(activeSource, 0xFFFF)
                mstore(cursor, shl(sub(0x100, activeSourceOffset), and(activeSource, not(0xFFFF))))
                let length := div(sub(activeSourceOffset, 0x20), 8)
                cursor := add(cursor, length)

                // loop the tail
                for { let tailPointer := and(shr(0x10, activeSource), 0xFFFF) } iszero(iszero(tailPointer)) {} {
                    tailPointer := and(shr(0x10, mload(tailPointer)), 0xFFFF)
                    mstore(cursor, and(mload(tailPointer), not(0xFFFFFFFF)))
                    cursor := add(cursor, 0xe0)
                    length := add(length, 0xe0)
                }
                mstore(source, length)
                mstore(0x40, and(add(cursor, 0x1f), not(0x1f)))
            }
            state.activeSource = 0x20;
            state.sourcesBuilder = (offset + 0x10) << 0xf0 | source << offset | sourcesBuilder;
        }
    }

    function buildSources(ParseState memory state) internal pure returns (bytes[] memory sources) {
        unchecked {
            uint256 sourcesBuilder = state.sourcesBuilder;
            uint256 offsetEnd = (sourcesBuilder >> 0xf0);

            // Somehow the parser state for the active source was not reset
            // correctly, or the finalised offset is dangling. This implies that
            // we are building the overall sources array while still trying to
            // build one of the individual sources. This is a bug in the parser.
            if (state.activeSource != 0x20) {
                revert DanglingSource();
            }

            uint256 cursor;
            assembly ("memory-safe") {
                cursor := mload(0x40)
                sources := cursor
                mstore(cursor, sub(div(offsetEnd, 0x10), 1))
                cursor := add(cursor, 0x20)
                // Expect underflow on the break condition.
                for { let offset := 0 } lt(offset, offsetEnd) {
                    offset := add(offset, 0x10)
                    cursor := add(cursor, 0x20)
                } { mstore(cursor, and(shr(offset, sourcesBuilder), 0xFFFF)) }
                mstore(0x40, cursor)
            }
        }
    }

    function buildConstants(ParseState memory) internal pure returns (uint256[] memory) {
        return new uint256[](0);
    }
}

library LibParse {
    using LibPointer for Pointer;
    using LibParseState for ParseState;

    function stringToChar(string memory s) external pure returns (uint256 char) {
        return 1 << uint256(uint8(bytes1(bytes(s))));
    }

    function parseErrorContext(bytes memory data, uint256 cursor)
        internal
        pure
        returns (uint256 offset, string memory char)
    {
        uint256 charCode;
        assembly ("memory-safe") {
            offset := sub(cursor, add(data, 1))
            charCode := and(mload(cursor), 0xFF)
        }
        char = string(abi.encodePacked(charCode));
    }

    function parseWord(uint256 cursor, uint256 mask) internal pure returns (uint256, bytes32) {
        bytes32 word;
        uint256 i = 1;
        assembly ("memory-safe") {
            // word is head + tail
            word := mload(add(cursor, 0x1f))
            // loop over the tail
            for {} and(lt(i, 0x20), iszero(and(shl(byte(i, word), 1), not(mask)))) { i := add(i, 1) } {}
            let scrub := mul(sub(0x20, i), 8)
            word := shl(scrub, shr(scrub, word))
            cursor := add(cursor, i)
        }
        if (i == 0x20) {
            revert WordSize(word);
        }
        return (cursor, word);
    }

    function skipWord(uint256 cursor, uint256 mask) internal pure returns (uint256) {
        uint256 i;
        assembly ("memory-safe") {
            let done := 0
            // process the tail
            for {} iszero(done) {} {
                cursor := add(cursor, 0x20)
                i := 0
                for { let word := mload(cursor) } and(lt(i, 0x20), iszero(iszero(and(shl(byte(i, word), 1), mask)))) {}
                {
                    i := add(i, 1)
                }
                if lt(i, 0x20) {
                    cursor := sub(cursor, sub(0x20, i))
                    done := 1
                }
            }
            // compensate for the head
            cursor := add(cursor, 1)
        }
        return cursor;
    }

    function parse(bytes memory data, bytes memory meta)
        internal
        pure
        returns (bytes[] memory sources, uint256[] memory)
    {
        unchecked {
            ParseState memory state = LibParseState.newState();
            if (data.length > 0) {
                bytes32 word;
                uint256 cursor;
                uint256 end;
                uint256 char;
                assembly ("memory-safe") {
                    cursor := add(data, 1)
                    end := add(cursor, mload(data))
                }
                while (cursor < end) {
                    assembly ("memory-safe") {
                        char := shl(and(mload(cursor), 0xFF), 1)
                    }

                    // LHS
                    if (state.fsm & FSM_LHS_MASK > 0) {
                        if (char & CMASK_LHS_STACK_HEAD > 0) {
                            // if yang we can't start new stack item
                            if (state.fsm & FSM_YANG_MASK > 0) {
                                (uint256 offset, string memory charString) = parseErrorContext(data, cursor);
                                revert UnexpectedLHSChar(offset, charString);
                            }

                            // Named stack item.
                            if (char & CMASK_IDENTIFIER_HEAD > 0) {
                                (cursor, word) = parseWord(cursor, CMASK_LHS_STACK_TAIL);
                                state.pushStackName(word);
                            }
                            // Anon stack item.
                            else {
                                cursor = skipWord(cursor, CMASK_LHS_STACK_TAIL);
                            }

                            state.stackIndex++;
                            state.fsm = FSM_LHS_MASK | FSM_YANG_MASK;
                        } else if (char & CMASK_WHITESPACE > 0) {
                            cursor = skipWord(cursor, CMASK_WHITESPACE);
                            state.fsm = FSM_LHS_MASK;
                        } else if (char & CMASK_LHS_RHS_DELIMITER > 0) {
                            state.fsm = 0;
                            cursor++;
                        } else {
                            (uint256 offset, string memory charString) = parseErrorContext(data, cursor);
                            revert UnexpectedLHSChar(offset, charString);
                        }
                    }
                    // RHS
                    else {
                        if (char & CMASK_RHS_WORD_HEAD > 0) {
                            // If yang we can't start a new word.
                            if (state.fsm & FSM_YANG_MASK > 0) {
                                (uint256 offset, string memory charString) = parseErrorContext(data, cursor);
                                revert UnexpectedRHSChar(offset, charString);
                            }

                            (cursor, word) = parseWord(cursor, CMASK_RHS_WORD_TAIL);
                            state.pushWordToSource(meta, word);

                            state.fsm = FSM_YANG_MASK | FSM_WORD_END_MASK;
                        } else if (state.fsm & FSM_WORD_END_MASK > 0) {
                            if (char & CMASK_LEFT_PAREN == 0) {
                                (uint256 offset, string memory charString) = parseErrorContext(data, cursor);
                                revert UnexpectedRHSChar(offset, charString);
                            }
                            state.fsm = 0;
                            cursor++;
                        } else if (char & CMASK_RIGHT_PAREN > 0) {
                            // @todo input handling.
                            state.fsm = 0;
                            cursor++;
                        } else if (char & CMASK_WHITESPACE > 0) {
                            state.fsm = 0;
                            cursor = skipWord(cursor, CMASK_WHITESPACE);
                        } else if (char & CMASK_EOL > 0) {
                            state.fsm = FSM_LHS_MASK;
                            cursor++;
                        }
                        // End of source.
                        else if (char & CMASK_EOS > 0) {
                            state.fsm = FSM_LHS_MASK;
                            state.newSource();
                            cursor++;
                        } else {
                            (uint256 offset, string memory charString) = parseErrorContext(data, cursor);
                            revert UnexpectedRHSChar(offset, charString);
                        }
                    }
                }
                if (char & CMASK_EOS == 0) {
                    (uint256 offset, string memory charString) = parseErrorContext(data, cursor);
                    revert UnexpectedRHSChar(offset, charString);
                }
            }
            return (state.buildSources(), state.buildConstants());
        }
    }
}

// // The second char is not a word char so do nothing.
// if iszero(and(shl(byte(0, word), 1), 0xffffffe0000000003ff200000000000)) { continue }

// // inline the first 16 word chars for gas efficiency.
// // It is usual for named stack items to be more than
// // one char long, so we can do better than looping in
// // terms of gas.
// if and(shl(byte(0, word), 1), 0xffffffe0000000003ff200000000000) {
//     if and(shl(byte(0x01, word), 1), 0xffffffe0000000003ff200000000000) {
//         if and(shl(byte(0x02, word), 1), 0xffffffe0000000003ff200000000000) {
//             if and(shl(byte(0x03, word), 1), 0xffffffe0000000003ff200000000000) {
//                 if and(shl(byte(0x04, word), 1), 0xffffffe0000000003ff200000000000) {
//                     if and(shl(byte(0x05, word), 1), 0xffffffe0000000003ff200000000000) {
//                         if and(shl(byte(0x06, word), 1), 0xffffffe0000000003ff200000000000)
//                         {
//                             if and(
//                                 shl(byte(0x07, word), 1), 0xffffffe0000000003ff200000000000
//                             ) {
//                                 if and(
//                                     shl(byte(0x08, word), 1),
//                                     0xffffffe0000000003ff200000000000
//                                 ) {
//                                     if and(
//                                         shl(byte(0x09, word), 1),
//                                         0xffffffe0000000003ff200000000000
//                                     ) {
//                                         if and(
//                                             shl(byte(0x0A, word), 1),
//                                             0xffffffe0000000003ff200000000000
//                                         ) {
//                                             if and(
//                                                 shl(byte(0x0B, word), 1),
//                                                 0xffffffe0000000003ff200000000000
//                                             ) {
//                                                 if and(
//                                                     shl(byte(0x0C, word), 1),
//                                                     0xffffffe0000000003ff200000000000
//                                                 ) {
//                                                     if and(
//                                                         shl(byte(0x0D, word), 1),
//                                                         0xffffffe0000000003ff200000000000
//                                                     ) {
//                                                         if and(
//                                                             shl(byte(0x0E, word), 1),
//                                                             0xffffffe0000000003ff200000000000
//                                                         ) {
//                                                             if and(
//                                                                 shl(byte(0x0F, word), 1),
//                                                                 0xffffffe0000000003ff200000000000
//                                                             ) {
//                                                                 // loop for the remainder for 16+ char words.
//                                                                 let i := 0x10
//                                                                 for {} and(
//                                                                     lt(i, 0x20),
//                                                                     iszero(
//                                                                         iszero(
//                                                                             and(
//                                                                                 shl(
//                                                                                     byte(
//                                                                                         i,
//                                                                                         word
//                                                                                     ),
//                                                                                     1
//                                                                                 ),
//                                                                                 0xffffffe0000000003ff200000000000
//                                                                             )
//                                                                         )
//                                                                     )
//                                                                 ) { i := add(i, 1) } {}
//                                                                 if lt(i, 0x20) {
//                                                                     cursor := add(cursor, i)
//                                                                     continue
//                                                                 }
//                                                                 errorCode :=
//                                                                     buildErrorCode(
//                                                                         data, cursor, 4
//                                                                     )
//                                                                 break
//                                                             }
//                                                             cursor := add(cursor, 0x0F)
//                                                             continue
//                                                         }
//                                                         cursor := add(cursor, 0x0E)
//                                                         continue
//                                                     }
//                                                     cursor := add(cursor, 0x0D)
//                                                     continue
//                                                 }
//                                                 cursor := add(cursor, 0x0C)
//                                                 continue
//                                             }
//                                             cursor := add(cursor, 0x0B)
//                                             continue
//                                         }
//                                         cursor := add(cursor, 0x0A)
//                                         continue
//                                     }
//                                     cursor := add(cursor, 0x09)
//                                     continue
//                                 }
//                                 cursor := add(cursor, 0x08)
//                                 continue
//                             }
//                             cursor := add(cursor, 0x07)
//                             continue
//                         }
//                         cursor := add(cursor, 0x06)
//                         continue
//                     }
//                     cursor := add(cursor, 0x05)
//                     continue
//                 }
//                 cursor := add(cursor, 0x04)
//                 continue
//             }
//             cursor := add(cursor, 0x03)
//             continue
//         }
//         cursor := add(cursor, 0x02)
//         continue
//     }
//     cursor := add(cursor, 0x01)
//     continue
// }