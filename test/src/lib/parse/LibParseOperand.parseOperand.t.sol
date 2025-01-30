// SPDX-License-Identifier: CAL
pragma solidity =0.8.25;

import {Test} from "forge-std/Test.sol";
import {LibParseOperand, OperandV2} from "src/lib/parse/LibParseOperand.sol";
import {ParseState} from "src/lib/parse/LibParseState.sol";
import {LibBytes, Pointer} from "rain.solmem/lib/LibBytes.sol";
import {Strings} from "openzeppelin-contracts/contracts/utils/Strings.sol";
import {LibMetaFixture} from "test/lib/parse/LibMetaFixture.sol";
import {LibConformString} from "rain.string/lib/mut/LibConformString.sol";
import {OperandValuesOverflow, UnclosedOperand} from "src/error/ErrParse.sol";
import {LibParseLiteral} from "src/lib/parse/literal/LibParseLiteral.sol";
import {LibDecimalFloat, LibDecimalFloatImplementation} from "rain.math.float/lib/LibDecimalFloat.sol";
import {SIGNED_NORMALIZED_MAX} from "rain.math.float/lib/implementation/LibDecimalFloatImplementation.sol";

contract LibParseOperandParseOperandTest is Test {
    using LibBytes for bytes;
    using LibParseOperand for ParseState;
    using Strings for uint256;
    using Strings for int256;

    function checkParsingOperandFromData(string memory s, uint256[] memory expectedValues, uint256 expectedEnd)
        internal
        pure
    {
        ParseState memory state = LibMetaFixture.newState(s);
        // Before parsing any operand values the state gets initialized at the
        // max length of 4.
        assertEq(state.operandValues.length, 4);

        uint256 cursor = Pointer.unwrap(state.data.dataPointer());
        uint256 end = cursor + state.data.length;

        uint256 cursorAfter = state.parseOperand(cursor, end);

        assertEq(cursorAfter - cursor, expectedEnd);

        assertEq(expectedValues.length, state.operandValues.length);
        for (uint256 i = 0; i < expectedValues.length; i++) {
            assertEq(expectedValues[i], state.operandValues[i]);
        }
    }

    // Test that parsing a string that doesn't start with the operand opening
    // character always results in a zero length operand values array.
    /// forge-config: default.fuzz.runs = 100
    function testParseOperandNoOpeningCharacter(string memory s) external pure {
        vm.assume(bytes(s).length > 0);
        vm.assume(bytes(s)[0] != "<");

        checkParsingOperandFromData(s, new uint256[](0), 0);
    }

    // Test that parsing an empty "<>" operand results in a zero length operand
    // values array. The cursor moves past both the opening and closing
    // characters.
    /// forge-config: default.fuzz.runs = 100
    function testParseOperandEmptyOperand(string memory s) external pure {
        vm.assume(bytes(s).length > 2);
        bytes(s)[0] = "<";
        bytes(s)[1] = ">";

        checkParsingOperandFromData(s, new uint256[](0), 2);
    }

    // Test that we can parse a single literal.
    /// forge-config: default.fuzz.runs = 100
    function testParseOperandSingleDecimalLiteral(
        bool asHex,
        int256 value,
        string memory maybeWhitespaceA,
        string memory maybeWhitespaceB,
        string memory suffix
    ) external pure {
        LibConformString.conformStringToWhitespace(maybeWhitespaceA);
        LibConformString.conformStringToWhitespace(maybeWhitespaceB);

        value = bound(value, 0, SIGNED_NORMALIZED_MAX);

        string memory valueString = asHex ? uint256(value).toHexString() : value.toString();
        string memory s = string.concat("<", maybeWhitespaceA, valueString, maybeWhitespaceB, ">", suffix);

        uint256[] memory expectedValues = new uint256[](1);
        (int256 signedCoefficient, int256 exponent) = LibDecimalFloatImplementation.normalize(value, 0);
        expectedValues[0] = asHex ? uint256(value) : LibDecimalFloat.pack(signedCoefficient, exponent);

        checkParsingOperandFromData(
            s,
            expectedValues,
            bytes(valueString).length + 2 + bytes(maybeWhitespaceA).length + bytes(maybeWhitespaceB).length
        );
    }

    // Test that we can parse two literals.
    /// forge-config: default.fuzz.runs = 100
    function testParseOperandTwoDecimalLiterals(
        bool asHexA,
        bool asHexB,
        int256 valueA,
        int256 valueB,
        string memory maybeWhitespaceA,
        string memory maybeWhitespaceB,
        string memory maybeWhitespaceC,
        string memory suffix
    ) external pure {
        vm.assume(bytes(maybeWhitespaceB).length > 0);

        valueA = bound(valueA, 0, SIGNED_NORMALIZED_MAX);
        valueB = bound(valueB, 0, SIGNED_NORMALIZED_MAX);

        LibConformString.conformStringToWhitespace(maybeWhitespaceA);
        LibConformString.conformStringToWhitespace(maybeWhitespaceB);
        LibConformString.conformStringToWhitespace(maybeWhitespaceC);

        string memory valueAString = asHexA ? uint256(valueA).toHexString() : valueA.toString();
        string memory valueBString = asHexB ? uint256(valueB).toHexString() : valueB.toString();

        string memory s = string.concat(
            "<", maybeWhitespaceA, valueAString, maybeWhitespaceB, valueBString, maybeWhitespaceC, ">", suffix
        );
        uint256[] memory expectedValues = new uint256[](2);

        (int256 signedCoefficient, int256 exponent) = LibDecimalFloatImplementation.normalize(valueA, 0);
        expectedValues[0] = (asHexA ? uint256(valueA) : LibDecimalFloat.pack(signedCoefficient, exponent));

        (signedCoefficient, exponent) = LibDecimalFloatImplementation.normalize(valueB, 0);
        expectedValues[1] = (asHexB ? uint256(valueB) : LibDecimalFloat.pack(signedCoefficient, exponent));

        checkParsingOperandFromData(
            s,
            expectedValues,
            bytes(valueAString).length + bytes(valueBString).length + 2 + bytes(maybeWhitespaceA).length
                + bytes(maybeWhitespaceB).length + bytes(maybeWhitespaceC).length
        );
    }

    // Test that we can parse three literals.
    /// forge-config: default.fuzz.runs = 100
    function testParseOperandThreeDecimalLiterals(
        bool asHexA,
        bool asHexB,
        bool asHexC,
        int256 valueA,
        int256 valueB,
        int256 valueC,
        string memory maybeWhitespaceA,
        string memory maybeWhitespaceB,
        string memory maybeWhitespaceC,
        string memory maybeWhitespaceD,
        string memory suffix
    ) external pure {
        vm.assume(bytes(maybeWhitespaceB).length > 0);
        vm.assume(bytes(maybeWhitespaceC).length > 0);

        valueA = bound(valueA, 0, SIGNED_NORMALIZED_MAX);
        valueB = bound(valueB, 0, SIGNED_NORMALIZED_MAX);
        valueC = bound(valueC, 0, SIGNED_NORMALIZED_MAX);

        LibConformString.conformStringToWhitespace(maybeWhitespaceA);
        LibConformString.conformStringToWhitespace(maybeWhitespaceB);
        LibConformString.conformStringToWhitespace(maybeWhitespaceC);
        LibConformString.conformStringToWhitespace(maybeWhitespaceD);

        string memory s;
        uint256 expectedLength;
        {
            string memory valueAString = asHexA ? uint256(valueA).toHexString() : valueA.toString();
            string memory valueBString = asHexB ? uint256(valueB).toHexString() : valueB.toString();
            string memory valueCString = asHexC ? uint256(valueC).toHexString() : valueC.toString();

            s = string.concat(
                string.concat(
                    "<", maybeWhitespaceA, valueAString, maybeWhitespaceB, valueBString, maybeWhitespaceC, valueCString
                ),
                maybeWhitespaceD,
                ">",
                suffix
            );

            expectedLength = bytes(valueAString).length + bytes(valueBString).length + bytes(valueCString).length + 2
                + bytes(maybeWhitespaceA).length + bytes(maybeWhitespaceB).length + bytes(maybeWhitespaceC).length
                + bytes(maybeWhitespaceD).length;
        }

        uint256[] memory expectedValues = new uint256[](3);
        (int256 signedCoefficient, int256 exponent) = LibDecimalFloatImplementation.normalize(valueA, 0);
        expectedValues[0] = (asHexA ? uint256(valueA) : LibDecimalFloat.pack(signedCoefficient, exponent));

        (signedCoefficient, exponent) = LibDecimalFloatImplementation.normalize(valueB, 0);
        expectedValues[1] = (asHexB ? uint256(valueB) : LibDecimalFloat.pack(signedCoefficient, exponent));

        (signedCoefficient, exponent) = LibDecimalFloatImplementation.normalize(valueC, 0);
        expectedValues[2] = (asHexC ? uint256(valueC) : LibDecimalFloat.pack(signedCoefficient, exponent));

        checkParsingOperandFromData(s, expectedValues, expectedLength);
    }

    // Test that we can parse four literals.
    /// forge-config: default.fuzz.runs = 100
    function testParseOperandFourDecimalLiterals(
        bool[4] memory asHex,
        int256[4] memory values,
        string[5] memory maybeWhitespace,
        string memory suffix
    ) external pure {
        {
            vm.assume(bytes(maybeWhitespace[1]).length > 0);
            vm.assume(bytes(maybeWhitespace[2]).length > 0);
            vm.assume(bytes(maybeWhitespace[3]).length > 0);
            LibConformString.conformStringToWhitespace(maybeWhitespace[0]);
            LibConformString.conformStringToWhitespace(maybeWhitespace[1]);
            LibConformString.conformStringToWhitespace(maybeWhitespace[2]);
            LibConformString.conformStringToWhitespace(maybeWhitespace[3]);
            LibConformString.conformStringToWhitespace(maybeWhitespace[4]);
        }

        for (uint256 i = 0; i < 4; i++) {
            values[i] = bound(values[i], 0, SIGNED_NORMALIZED_MAX);
        }

        uint256 expectedLength;
        {
            expectedLength = 2 + bytes(maybeWhitespace[0]).length + bytes(maybeWhitespace[1]).length
                + bytes(maybeWhitespace[2]).length + bytes(maybeWhitespace[3]).length + bytes(maybeWhitespace[4]).length;
        }

        string memory valueAString = asHex[0] ? uint256(values[0]).toHexString() : values[0].toString();
        string memory valueBString = asHex[1] ? uint256(values[1]).toHexString() : values[1].toString();
        string memory valueCString = asHex[2] ? uint256(values[2]).toHexString() : values[2].toString();
        string memory valueDString = asHex[3] ? uint256(values[3]).toHexString() : values[3].toString();

        {
            expectedLength += bytes(valueAString).length + bytes(valueBString).length + bytes(valueCString).length
                + bytes(valueDString).length;
        }

        string memory s;

        // This is chunked out to avoid stack overflows in the solidity compiler.
        {
            s = string.concat("<", maybeWhitespace[0], valueAString);

            s = string.concat(s, maybeWhitespace[1], valueBString);

            s = string.concat(s, maybeWhitespace[2], valueCString);

            s = string.concat(s, maybeWhitespace[3], valueDString);

            s = string.concat(s, maybeWhitespace[4], ">", suffix);
        }

        uint256[] memory expectedValues = new uint256[](4);
        for (uint256 i = 0; i < 4; i++) {
            (int256 signedCoefficient, int256 exponent) = LibDecimalFloatImplementation.normalize(values[i], 0);
            expectedValues[i] = asHex[i] ? uint256(values[i]) : LibDecimalFloat.pack(signedCoefficient, exponent);
        }
        checkParsingOperandFromData(s, expectedValues, expectedLength);
    }

    /// More than 4 values is an error.
    function testParseOperandTooManyValues() external {
        vm.expectRevert(abi.encodeWithSelector(OperandValuesOverflow.selector, 9));
        checkParsingOperandFromData("<1 2 3 4 5>", new uint256[](0), 0);
    }

    /// Unclosed operand is an error.
    function testParseOperandUnclosed() external {
        vm.expectRevert(abi.encodeWithSelector(UnclosedOperand.selector, 8));
        checkParsingOperandFromData("<1 2 3 4", new uint256[](0), 0);
    }

    // Unexpected chars will be treated as unclosed operands.
    function testParseOperandUnexpectedChars() external {
        vm.expectRevert(abi.encodeWithSelector(UnclosedOperand.selector, 6));
        checkParsingOperandFromData("<1 2 3;> 6", new uint256[](0), 0);
    }
}
