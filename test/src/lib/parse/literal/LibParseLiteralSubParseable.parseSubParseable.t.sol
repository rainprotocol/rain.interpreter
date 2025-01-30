// SPDX-License-Identifier: CAL
pragma solidity =0.8.25;

import {Test} from "forge-std/Test.sol";
import {ParseState, Pointer, LibParseState} from "src/lib/parse/LibParseState.sol";
import {LibBytes} from "rain.solmem/lib/LibBytes.sol";
import {LibParseLiteralSubParseable} from "src/lib/parse/literal/LibParseLiteralSubParseable.sol";
import {UnclosedSubParseableLiteral, SubParseableMissingDispatch} from "src/error/ErrParse.sol";
import {ISubParserV4} from "rain.interpreter.interface/interface/unstable/ISubParserV4.sol";
import {LibConformString} from "rain.string/lib/mut/LibConformString.sol";
import {CMASK_WHITESPACE, CMASK_SUB_PARSEABLE_LITERAL_END} from "rain.string/lib/parse/LibParseCMask.sol";

contract LibParseLiteralSubParseableTest is Test {
    using LibBytes for bytes;
    using LibParseState for ParseState;
    using LibParseLiteralSubParseable for ParseState;

    function checkParseSubParseable(
        string memory data,
        string memory expectedDispatch,
        string memory expectedBody,
        uint256 expectedCursorAfter
    ) internal {
        ParseState memory state = LibParseState.newState(bytes(data), "", "", "");
        uint256 cursor = Pointer.unwrap(state.data.dataPointer());
        address subParser = address(0x1234567890123456789012345678901234567890);
        state.pushSubParser(0, uint256(uint160(subParser)));
        bytes memory subParseData =
            bytes.concat(bytes2(uint16(bytes(expectedDispatch).length)), bytes(expectedDispatch), bytes(expectedBody));
        uint256 returnValue = 99;
        vm.mockCall(
            subParser,
            abi.encodeWithSelector(ISubParserV4.subParseLiteral.selector, subParseData),
            abi.encode(true, returnValue)
        );
        vm.expectCall(subParser, abi.encodeWithSelector(ISubParserV4.subParseLiteral.selector, subParseData));
        (uint256 cursorAfter, uint256 value) =
            state.parseSubParseable(cursor, Pointer.unwrap(state.data.endDataPointer()));
        assertEq(cursorAfter - cursor, expectedCursorAfter);
        assertEq(value, returnValue);
    }

    function checkParseSubParseableError(string memory data, bytes memory err) internal {
        vm.expectRevert(err);
        checkParseSubParseable(data, "", "", 0);
    }

    /// An unclosed sub parseable literal is an error.
    function testParseLiteralSubParseableUnclosedDispatch0() external {
        checkParseSubParseableError("[a", abi.encodeWithSelector(UnclosedSubParseableLiteral.selector, 2));
    }

    /// Leading whitespace is not allowed.
    function testParseLiteralSubParseableUnclosedDispatchWhitespace1() external {
        checkParseSubParseableError("[ a", abi.encodeWithSelector(SubParseableMissingDispatch.selector, 1));
    }

    /// An unclosed sub parseable literal is an error.
    function testParseLiteralSubParseableUnclosedDispatchWhitespace0() external {
        checkParseSubParseableError("[a ", abi.encodeWithSelector(UnclosedSubParseableLiteral.selector, 3));
    }

    /// An unclosed sub parseable literal is an error.
    /// Tests with a body.
    function testParseLiteralSubParseableUnclosedDispatchBody() external {
        checkParseSubParseableError("[a b", abi.encodeWithSelector(UnclosedSubParseableLiteral.selector, 4));
    }

    /// An unclosed sub parseable literal is an error.
    function testParseLiteralSubParseableUnclosedDoubleOpen() external {
        checkParseSubParseableError("[[", abi.encodeWithSelector(UnclosedSubParseableLiteral.selector, 2));
    }

    /// An empty sub parseable literal is an error.
    function testParseLiteralSubParseableMissingDispatchEmpty() external {
        checkParseSubParseableError("[]", abi.encodeWithSelector(SubParseableMissingDispatch.selector, 1));
    }

    /// An unclosed sub parseable literal with no dispatch is an error.
    function testParseLiteralSubParseableMissingDispatchUnclosed() external {
        checkParseSubParseableError("[", abi.encodeWithSelector(SubParseableMissingDispatch.selector, 1));
    }

    /// An unclosed sub parseable literal with no dispatch is an error.
    function testParseLiteralSubParseableMissingDispatchUnclosedWhitespace0() external {
        checkParseSubParseableError("[ ", abi.encodeWithSelector(SubParseableMissingDispatch.selector, 1));
    }

    /// An unclosed sub parseable literal with no dispatch is an error.
    function testParseLiteralSubParseableMissingDispatchUnclosedWhitespace1() external {
        checkParseSubParseableError("[  ", abi.encodeWithSelector(SubParseableMissingDispatch.selector, 1));
    }

    /// A dispatch with an empty body is allowed. Trailing whitespace is ignored.
    function testParseLiteralSubParseableEmptyBody() external {
        checkParseSubParseable("[pi]", "pi", "", 4);
        checkParseSubParseable("[pi ]", "pi", "", 5);
    }

    /// A dispatch with a body is allowed. Whitespace after the body start is
    /// included in the body.
    function testParseLiteralSubParseableBody() external {
        checkParseSubParseable("[hi a]", "hi", "a", 6);
        checkParseSubParseable("[hi a ]", "hi", "a ", 7);
        // Multiple whitespace between dispatch and body is allowed.
        checkParseSubParseable("[hi  a ]", "hi", "a ", 8);
        checkParseSubParseable("[hi a  ]", "hi", "a  ", 8);
        // Different whitespace such as a newline is allowed as a delimiter.
        checkParseSubParseable("[hi\na]", "hi", "a", 6);
        checkParseSubParseable("[hi\na ]", "hi", "a ", 7);
        checkParseSubParseable("[hi\na\n]", "hi", "a\n", 7);
    }

    /// Fuzz the happy path.
    function testParseLiteralSubParseableHappyFuzz(string memory dispatch, string memory whitespace, string memory body)
        external
    {
        vm.assume(bytes(dispatch).length > 0);
        vm.assume(bytes(whitespace).length > 0);

        // Dispatch can be any ASCII other than whitespace or literal end char.
        LibConformString.conformStringToMask(dispatch, ~(CMASK_WHITESPACE | CMASK_SUB_PARSEABLE_LITERAL_END));
        // Whitespace can be any standard rainlang whitespace.
        LibConformString.conformStringToWhitespace(whitespace);
        // Body can be any ASCII other than the literal end, including
        // whitespace.
        LibConformString.conformStringToMask(body, ~CMASK_SUB_PARSEABLE_LITERAL_END);

        checkParseSubParseable(
            string(abi.encodePacked("[", dispatch, whitespace, body, "]")),
            dispatch,
            body,
            bytes(dispatch).length + bytes(whitespace).length + bytes(body).length + 2
        );
    }
}
