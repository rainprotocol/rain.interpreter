// SPDX-License-Identifier: CAL
pragma solidity =0.8.25;

import {Test} from "forge-std/Test.sol";
import {
    RainterpreterParser,
    OPERAND_HANDLER_FUNCTION_POINTERS,
    LITERAL_PARSER_FUNCTION_POINTERS,
    PARSE_META,
    PARSE_META_BUILD_DEPTH
} from "src/concrete/RainterpreterParser.sol";
import {LibAllStandardOpsNP, AuthoringMetaV2} from "src/lib/op/LibAllStandardOpsNP.sol";
import {LibParseMeta} from "rain.interpreter.interface/lib/parse/LibParseMeta.sol";
import {LibGenParseMeta} from "rain.sol.codegen/lib/LibGenParseMeta.sol";

contract RainterpreterParserPointersTest is Test {
    function testOperandHandlerFunctionPointers() external {
        RainterpreterParser parser = new RainterpreterParser();
        bytes memory expected = parser.buildOperandHandlerFunctionPointers();
        bytes memory actual = OPERAND_HANDLER_FUNCTION_POINTERS;
        assertEq(actual, expected);
    }

    function testLiteralParserFunctionPointers() external {
        RainterpreterParser parser = new RainterpreterParser();
        bytes memory expected = parser.buildLiteralParserFunctionPointers();
        bytes memory actual = LITERAL_PARSER_FUNCTION_POINTERS;
        assertEq(actual, expected);
    }

    function testParserParseMeta() external pure {
        bytes memory authoringMetaBytes = LibAllStandardOpsNP.authoringMetaV2();
        AuthoringMetaV2[] memory authoringMeta = abi.decode(authoringMetaBytes, (AuthoringMetaV2[]));
        bytes memory expected = LibGenParseMeta.buildParseMetaV2(authoringMeta, PARSE_META_BUILD_DEPTH);
        bytes memory actual = PARSE_META;
        assertEq(actual, expected);
    }
}
