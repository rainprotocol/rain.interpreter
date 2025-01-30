// SPDX-License-Identifier: CAL
pragma solidity =0.8.25;

import {IERC165, ERC165} from "openzeppelin-contracts/contracts/utils/introspection/ERC165.sol";

import {LibParse} from "../lib/parse/LibParse.sol";
import {IParserPragmaV1, PragmaV1} from "rain.interpreter.interface/interface/IParserPragmaV1.sol";
import {LibParseState, ParseState} from "../lib/parse/LibParseState.sol";
import {LibParsePragma} from "../lib/parse/LibParsePragma.sol";
import {LibParseLiteral} from "../lib/parse/literal/LibParseLiteral.sol";
import {LibAllStandardOpsNP} from "../lib/op/LibAllStandardOpsNP.sol";
import {LibBytes, Pointer} from "rain.solmem/lib/LibBytes.sol";
import {LibParseInterstitial} from "../lib/parse/LibParseInterstitial.sol";
import {
    BYTECODE_HASH as PARSER_BYTECODE_HASH,
    LITERAL_PARSER_FUNCTION_POINTERS,
    OPERAND_HANDLER_FUNCTION_POINTERS,
    PARSE_META,
    PARSE_META_BUILD_DEPTH
} from "../generated/RainterpreterParser.pointers.sol";
import {IParserV1View} from "rain.interpreter.interface/interface/deprecated/IParserV1View.sol";
import {IParserToolingV1} from "rain.sol.codegen/interface/IParserToolingV1.sol";

/// @title RainterpreterParser
/// @dev The parser implementation. NOT intended to be called directly so
/// intentionally does NOT implement various interfaces. The expression deployer
/// calls into this contract and exposes the relevant interfaces, with additional
/// safety and integrity checks.
contract RainterpreterParser is ERC165, IParserToolingV1 {
    using LibParse for ParseState;
    using LibParseState for ParseState;
    using LibParsePragma for ParseState;
    using LibParseInterstitial for ParseState;
    using LibBytes for bytes;

    function unsafeParse(bytes memory data) external view returns (bytes memory, bytes32[] memory) {
        // The return is used by returning it, so this is a false positive.
        //slither-disable-next-line unused-return
        return LibParseState.newState(
            data, parseMeta(), operandHandlerFunctionPointers(), literalParserFunctionPointers()
        ).parse();
    }

    /// @inheritdoc ERC165
    function supportsInterface(bytes4 interfaceId) public view override returns (bool) {
        return interfaceId == type(IParserToolingV1).interfaceId || super.supportsInterface(interfaceId);
    }

    function parsePragma1(bytes memory data) external pure virtual returns (PragmaV1 memory) {
        ParseState memory parseState =
            LibParseState.newState(data, parseMeta(), operandHandlerFunctionPointers(), literalParserFunctionPointers());
        uint256 cursor = Pointer.unwrap(data.dataPointer());
        uint256 end = Pointer.unwrap(data.endDataPointer());
        cursor = parseState.parseInterstitial(cursor, end);
        cursor = parseState.parsePragma(cursor, end);
        (cursor);
        return PragmaV1(parseState.exportSubParsers());
    }

    /// Virtual function to return the parse meta.
    function parseMeta() internal pure virtual returns (bytes memory) {
        return PARSE_META;
    }

    /// Virtual function to return the operand handler function pointers.
    function operandHandlerFunctionPointers() internal pure virtual returns (bytes memory) {
        return OPERAND_HANDLER_FUNCTION_POINTERS;
    }

    /// Virtual function to return the literal parser function pointers.
    function literalParserFunctionPointers() internal pure virtual returns (bytes memory) {
        return LITERAL_PARSER_FUNCTION_POINTERS;
    }

    /// External function to build the operand handler function pointers.
    function buildOperandHandlerFunctionPointers() external pure returns (bytes memory) {
        return LibAllStandardOpsNP.operandHandlerFunctionPointers();
    }

    /// External function to build the literal parser function pointers.
    function buildLiteralParserFunctionPointers() external pure returns (bytes memory) {
        return LibAllStandardOpsNP.literalParserFunctionPointers();
    }
}
