// SPDX-License-Identifier: LicenseRef-DCL-1.0
// SPDX-FileCopyrightText: Copyright (c) 2020 thedavidmeister
pragma solidity ^0.8.18;

import {ParseState} from "../LibParseState.sol";
import {LibParseError} from "../LibParseError.sol";
import {LibParseDecimalFloat, PackedFloat} from "rain.math.float/lib/parse/LibParseDecimalFloat.sol";

library LibParseLiteralDecimal {
    using LibParseError for ParseState;

    function parseDecimalFloatPacked(ParseState memory state, uint256 start, uint256 end)
        internal
        pure
        returns (uint256, bytes32)
    {
        (bytes4 errorSelector, uint256 cursor, PackedFloat packedFloat) =
            LibParseDecimalFloat.parseDecimalFloatPacked(start, end);
        state.handleErrorSelector(cursor, errorSelector);
        return (cursor, PackedFloat.unwrap(packedFloat));
    }

    function parseDecimalFloat(ParseState memory state, uint256 start, uint256 end)
        internal
        pure
        returns (uint256, int256, int256)
    {
        (bytes4 errorSelector, uint256 cursor, int256 signedCoefficient, int256 exponent) =
            LibParseDecimalFloat.parseDecimalFloat(start, end);
        state.handleErrorSelector(cursor, errorSelector);
        return (cursor, signedCoefficient, exponent);
    }
}
