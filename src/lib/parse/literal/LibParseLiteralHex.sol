// SPDX-License-Identifier: CAL
pragma solidity ^0.8.18;

import {ParseState} from "../LibParseState.sol";
import {
    MalformedHexLiteral,
    OddLengthHexLiteral,
    ZeroLengthHexLiteral,
    HexLiteralOverflow
} from "../../../error/ErrParse.sol";
import {
    CMASK_UPPER_ALPHA_A_F,
    CMASK_LOWER_ALPHA_A_F,
    CMASK_NUMERIC_0_9,
    CMASK_HEX
} from "rain.string/lib/parse/LibParseCMask.sol";
import {LibParseError} from "../LibParseError.sol";

library LibParseLiteralHex {
    using LibParseLiteralHex for ParseState;
    using LibParseError for ParseState;

    function boundHex(ParseState memory, uint256 cursor, uint256 end)
        internal
        pure
        returns (uint256, uint256, uint256)
    {
        uint256 innerStart = cursor + 2;
        uint256 innerEnd = innerStart;
        {
            uint256 hexCharMask = CMASK_HEX;
            assembly ("memory-safe") {
                //slither-disable-next-line incorrect-shift
                for {} and(iszero(iszero(and(shl(byte(0, mload(innerEnd)), 1), hexCharMask))), lt(innerEnd, end)) {} {
                    innerEnd := add(innerEnd, 1)
                }
            }
        }

        return (innerStart, innerEnd, innerEnd);
    }

    /// Algorithm for parsing hexadecimal literals:
    /// - start at the end of the literal
    /// - for each character:
    ///   - convert the character to a nybble
    ///   - shift the nybble into the total at the correct position
    ///     (4 bits per nybble)
    /// - return the total
    function parseHex(ParseState memory state, uint256 cursor, uint256 end) internal pure returns (uint256, bytes32) {
        unchecked {
            bytes32 value;
            uint256 hexStart;
            uint256 hexEnd;
            (hexStart, hexEnd, cursor) = state.boundHex(cursor, end);

            uint256 hexLength = hexEnd - hexStart;
            if (hexLength > 0x40) {
                revert HexLiteralOverflow(state.parseErrorOffset(hexStart));
            } else if (hexLength == 0) {
                revert ZeroLengthHexLiteral(state.parseErrorOffset(hexStart));
            } else if (hexLength % 2 == 1) {
                revert OddLengthHexLiteral(state.parseErrorOffset(hexStart));
            } else {
                // Loop the cursor backwards over the hex string, we'll return
                // the hex end instead.
                cursor = hexEnd - 1;
                uint256 valueOffset = 0;
                while (cursor >= hexStart) {
                    uint256 hexCharByte;
                    assembly ("memory-safe") {
                        hexCharByte := byte(0, mload(cursor))
                    }
                    //slither-disable-next-line incorrect-shift
                    uint256 hexChar = 1 << hexCharByte;

                    bytes32 nybble;
                    // 0-9
                    if (hexChar & CMASK_NUMERIC_0_9 != 0) {
                        nybble = bytes32(hexCharByte - uint256(uint8(bytes1("0"))));
                    }
                    // a-f
                    else if (hexChar & CMASK_LOWER_ALPHA_A_F != 0) {
                        nybble = bytes32(hexCharByte - uint256(uint8(bytes1("a"))) + 10);
                    }
                    // A-F
                    else if (hexChar & CMASK_UPPER_ALPHA_A_F != 0) {
                        nybble = bytes32(hexCharByte - uint256(uint8(bytes1("A"))) + 10);
                    } else {
                        revert MalformedHexLiteral(state.parseErrorOffset(cursor));
                    }

                    value |= nybble << valueOffset;
                    valueOffset += 4;
                    cursor--;
                }
            }

            return (hexEnd, value);
        }
    }
}
