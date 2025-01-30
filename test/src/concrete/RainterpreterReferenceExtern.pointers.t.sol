// SPDX-License-Identifier: CAL
pragma solidity =0.8.25;

import {Test} from "forge-std/Test.sol";
import {
    RainterpreterReferenceExtern,
    OPCODE_FUNCTION_POINTERS,
    INTEGRITY_FUNCTION_POINTERS,
    SUB_PARSER_WORD_PARSERS,
    AuthoringMetaV2,
    SUB_PARSER_PARSE_META,
    LibRainterpreterReferenceExtern,
    LITERAL_PARSER_FUNCTION_POINTERS,
    OPERAND_HANDLER_FUNCTION_POINTERS
} from "src/concrete/extern/RainterpreterReferenceExtern.sol";
import {LibParseMeta} from "rain.interpreter.interface/lib/parse/LibParseMeta.sol";
import {LibGenParseMeta} from "rain.sol.codegen/lib/LibGenParseMeta.sol";

contract RainterpreterReferenceExternPointersTest is Test {
    function testOpcodeFunctionPointers() external {
        RainterpreterReferenceExtern extern = new RainterpreterReferenceExtern();
        bytes memory expected = extern.buildOpcodeFunctionPointers();
        bytes memory actual = OPCODE_FUNCTION_POINTERS;
        assertEq(actual, expected);
    }

    function testIntegrityFunctionPointers() external {
        RainterpreterReferenceExtern extern = new RainterpreterReferenceExtern();
        bytes memory expected = extern.buildIntegrityFunctionPointers();
        bytes memory actual = INTEGRITY_FUNCTION_POINTERS;
        assertEq(actual, expected);
    }

    function testSubParserParseMeta() external pure {
        bytes memory authoringMetaBytes = LibRainterpreterReferenceExtern.authoringMetaV2();
        AuthoringMetaV2[] memory authoringMeta = abi.decode(authoringMetaBytes, (AuthoringMetaV2[]));
        bytes memory expected = LibGenParseMeta.buildParseMetaV2(authoringMeta, 2);
        bytes memory actual = SUB_PARSER_PARSE_META;
        assertEq(actual, expected);
    }

    function testSubParserLiteralParsers() external {
        RainterpreterReferenceExtern subParser = new RainterpreterReferenceExtern();
        bytes memory expected = subParser.buildLiteralParserFunctionPointers();
        bytes memory actual = LITERAL_PARSER_FUNCTION_POINTERS;
        assertEq(actual, expected);
    }

    function testSubParserFunctionPointers() external {
        RainterpreterReferenceExtern extern = new RainterpreterReferenceExtern();
        bytes memory expected = extern.buildSubParserWordParsers();
        bytes memory actual = SUB_PARSER_WORD_PARSERS;
        assertEq(actual, expected);
    }

    function testSubParserOperandParsers() external {
        RainterpreterReferenceExtern extern = new RainterpreterReferenceExtern();
        bytes memory expected = extern.buildOperandHandlerFunctionPointers();
        bytes memory actual = OPERAND_HANDLER_FUNCTION_POINTERS;
        assertEq(actual, expected);
    }
}
