// SPDX-License-Identifier: CAL
pragma solidity ^0.8.18;

import {
    CMASK_E_NOTATION,
    CMASK_HEX,
    CMASK_LOWER_ALPHA_A_F,
    CMASK_NUMERIC_0_9,
    CMASK_STRING_LITERAL_HEAD,
    CMASK_UPPER_ALPHA_A_F,
    CMASK_LITERAL_HEX_DISPATCH,
    CMASK_NUMERIC_LITERAL_HEAD,
    CMASK_SUB_PARSEABLE_LITERAL_HEAD,
    CMASK_SUB_PARSEABLE_LITERAL_END,
    CMASK_WHITESPACE
} from "rain.string/lib/parse/LibParseCMask.sol";
import {LibParse} from "../LibParse.sol";

import {
    DecimalLiteralOverflow,
    HexLiteralOverflow,
    MalformedExponentDigits,
    MalformedHexLiteral,
    OddLengthHexLiteral,
    ZeroLengthDecimal,
    ZeroLengthHexLiteral,
    UnsupportedLiteralType,
    UnclosedSubParseableLiteral
} from "../../../error/ErrParse.sol";
import {ParseState} from "../LibParseState.sol";
import {LibParseError} from "../LibParseError.sol";
import {LibParseInterstitial} from "../LibParseInterstitial.sol";
import {LibSubParse} from "../LibSubParse.sol";

uint256 constant LITERAL_PARSERS_LENGTH = 4;

uint256 constant LITERAL_PARSER_INDEX_HEX = 0;
uint256 constant LITERAL_PARSER_INDEX_DECIMAL = 1;
uint256 constant LITERAL_PARSER_INDEX_STRING = 2;
uint256 constant LITERAL_PARSER_INDEX_SUB_PARSE = 3;

library LibParseLiteral {
    using LibParseLiteral for ParseState;
    using LibParseError for ParseState;
    using LibParseLiteral for ParseState;
    using LibParseInterstitial for ParseState;
    using LibSubParse for ParseState;

    function selectLiteralParserByIndex(ParseState memory state, uint256 index)
        internal
        pure
        returns (function(ParseState memory, uint256, uint256) pure returns (uint256, bytes32))
    {
        bytes memory literalParsers = state.literalParsers;
        function(ParseState memory, uint256, uint256) pure returns (uint256, bytes32) parser;
        // This is NOT bounds checked because the indexes are all expected to
        // be provided by the parser itself and not user input.
        assembly ("memory-safe") {
            parser := and(mload(add(literalParsers, add(2, mul(index, 2)))), 0xFFFF)
        }
        return parser;
    }

    function parseLiteral(ParseState memory state, uint256 cursor, uint256 end)
        internal
        pure
        returns (uint256, bytes32)
    {
        (bool success, uint256 newCursor, bytes32 value) = tryParseLiteral(state, cursor, end);
        if (success) {
            return (newCursor, value);
        } else {
            revert UnsupportedLiteralType(state.parseErrorOffset(cursor));
        }
    }

    function tryParseLiteral(ParseState memory state, uint256 cursor, uint256 end)
        internal
        pure
        returns (bool, uint256, bytes32)
    {
        uint256 index;
        {
            uint256 word;
            uint256 head;
            assembly ("memory-safe") {
                word := mload(cursor)
                //slither-disable-next-line incorrect-shift
                head := shl(byte(0, word), 1)
            }

            // Figure out the literal type and dispatch to the correct parser.
            // Probably a numeric, most things are.
            if ((head & CMASK_NUMERIC_LITERAL_HEAD) != 0) {
                uint256 disambiguate;
                assembly ("memory-safe") {
                    //slither-disable-next-line incorrect-shift
                    disambiguate := shl(byte(1, word), 1)
                }
                // Hexadecimal literal dispatch is 0x. We can't accidentally
                // match x0 because we already checked that the head is 0-9.
                if ((head | disambiguate) == CMASK_LITERAL_HEX_DISPATCH) {
                    index = LITERAL_PARSER_INDEX_HEX;
                } else {
                    index = LITERAL_PARSER_INDEX_DECIMAL;
                }
            }
            // Could be a lil' string.
            else if ((head & CMASK_STRING_LITERAL_HEAD) != 0) {
                index = LITERAL_PARSER_INDEX_STRING;
            }
            // Or a sub parseable something.
            else if ((head & CMASK_SUB_PARSEABLE_LITERAL_HEAD) != 0) {
                index = LITERAL_PARSER_INDEX_SUB_PARSE;
            }
            // We don't know what this is.
            else {
                return (false, cursor, 0);
            }
        }
        bytes32 value;
        (cursor, value) = state.selectLiteralParserByIndex(index)(state, cursor, end);
        return (true, cursor, value);
    }
}
