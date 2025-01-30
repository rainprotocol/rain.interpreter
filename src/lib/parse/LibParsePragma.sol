// SPDX-License-Identifier: CAL
pragma solidity ^0.8.18;

import {LibParseState, ParseState} from "./LibParseState.sol";
import {CMASK_WHITESPACE, CMASK_LITERAL_HEX_DISPATCH_START} from "rain.string/lib/parse/LibParseCMask.sol";
import {NoWhitespaceAfterUsingWordsFrom} from "../../error/ErrParse.sol";
import {LibParseError} from "./LibParseError.sol";
import {LibParseInterstitial} from "./LibParseInterstitial.sol";
import {LibParseLiteral} from "./literal/LibParseLiteral.sol";

bytes constant PRAGMA_KEYWORD_BYTES = bytes("using-words-from");
bytes32 constant PRAGMA_KEYWORD_BYTES32 = bytes32(PRAGMA_KEYWORD_BYTES);
uint256 constant PRAGMA_KEYWORD_BYTES_LENGTH = 16;
bytes32 constant PRAGMA_KEYWORD_MASK = bytes32(~((1 << (32 - PRAGMA_KEYWORD_BYTES_LENGTH) * 8) - 1));

library LibParsePragma {
    using LibParseError for ParseState;
    using LibParseInterstitial for ParseState;
    using LibParseLiteral for ParseState;
    using LibParseState for ParseState;

    function parsePragma(ParseState memory state, uint256 cursor, uint256 end) internal pure returns (uint256) {
        unchecked {
            // Not-pragma guard.
            {
                // There is a pragma if the cursor is pointing exactly at the bytes of
                // the pragma.
                bytes32 maybePragma;
                assembly ("memory-safe") {
                    maybePragma := mload(cursor)
                }
                // Bail without modifying the cursor if there's no pragma.
                if (maybePragma & PRAGMA_KEYWORD_MASK != PRAGMA_KEYWORD_BYTES32) {
                    return cursor;
                }
            }

            {
                // Move past the pragma keyword.
                cursor += PRAGMA_KEYWORD_BYTES_LENGTH;

                // Need at least one whitespace char after the pragma keyword.
                uint256 char;
                assembly ("memory-safe") {
                    //slither-disable-next-line incorrect-shift
                    char := shl(byte(0, mload(cursor)), 1)
                }
                if (char & CMASK_WHITESPACE == 0) {
                    revert NoWhitespaceAfterUsingWordsFrom(state.parseErrorOffset(cursor));
                }
                ++cursor;
            }

            while (cursor < end) {
                // It's fine to add comments for each pragma address.
                // This also has the effect of moving past the interstitial after
                // the last address as we don't break til just below.
                cursor = state.parseInterstitial(cursor, end);

                // Try to parse a literal and treat it as an address.
                bool success;
                bytes32 value;
                (success, cursor, value) = state.tryParseLiteral(cursor, end);
                // If we didn't parse a literal, we're done with the pragma.
                if (!success) {
                    break;
                } else {
                    state.pushSubParser(cursor, value);
                }
            }

            return cursor;
        }
    }
}
