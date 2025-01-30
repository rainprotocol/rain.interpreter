// SPDX-License-Identifier: CAL
pragma solidity =0.8.25;

import {LibConvert} from "rain.lib.typecast/LibConvert.sol";
import {BadDynamicLength} from "../../error/ErrOpList.sol";
import {BaseRainterpreterExternNPE2, OperandV2} from "../../abstract/BaseRainterpreterExternNPE2.sol";
import {
    BaseRainterpreterSubParserNPE2,
    AuthoringMetaV2,
    IParserToolingV1,
    ISubParserToolingV1
} from "../../abstract/BaseRainterpreterSubParserNPE2.sol";
import {LibExtern, EncodedExternDispatchV2, IInterpreterExternV4, StackItem} from "../../lib/extern/LibExtern.sol";
import {LibSubParse} from "../../lib/parse/LibSubParse.sol";
import {LibParseState, ParseState} from "../../lib/parse/LibParseState.sol";
import {LibParseOperand} from "../../lib/parse/LibParseOperand.sol";
import {LibParseLiteral} from "../../lib/parse/literal/LibParseLiteral.sol";
import {LibExternOpIntIncNPE2, OP_INDEX_INCREMENT} from "../../lib/extern/reference/op/LibExternOpIntIncNPE2.sol";
import {LibExternOpStackOperandNPE2} from "../../lib/extern/reference/op/LibExternOpStackOperandNPE2.sol";
import {LibExternOpContextSenderNPE2} from "../../lib/extern/reference/op/LibExternOpContextSenderNPE2.sol";
import {LibExternOpContextCallingContractNPE2} from
    "../../lib/extern/reference/op/LibExternOpContextCallingContractNPE2.sol";
import {LibExternOpContextRainlenNPE2} from "../../lib/extern/reference/op/LibExternOpContextRainlenNPE2.sol";
import {LibParseLiteralRepeat} from "../../lib/extern/reference/literal/LibParseLiteralRepeat.sol";
import {LibParseLiteralDecimal} from "../../lib/parse/literal/LibParseLiteralDecimal.sol";
import {
    DESCRIBED_BY_META_HASH,
    PARSE_META as SUB_PARSER_PARSE_META,
    PARSE_META_BUILD_DEPTH as EXTERN_PARSE_META_BUILD_DEPTH,
    SUB_PARSER_WORD_PARSERS,
    OPERAND_HANDLER_FUNCTION_POINTERS,
    LITERAL_PARSER_FUNCTION_POINTERS,
    INTEGRITY_FUNCTION_POINTERS,
    OPCODE_FUNCTION_POINTERS
} from "../../generated/RainterpreterReferenceExtern.pointers.sol";
import {LibDecimalFloat, PackedFloat} from "rain.math.float/lib/LibDecimalFloat.sol";

/// @dev The number of subparser functions available to the parser. This is NOT
/// 1:1 with the number of opcodes provided by the extern component of this
/// contract. It is possible to subparse words into opcodes that run entirely
/// within the interpreter, and do not have an associated extern dispatch.
uint256 constant SUB_PARSER_WORD_PARSERS_LENGTH = 5;

/// @dev The number of literal parsers provided by the sub parser.
uint256 constant SUB_PARSER_LITERAL_PARSERS_LENGTH = 1;

/// @dev The keyword for the repeat literal parser. The digit after this keyword
/// is the digit to repeat in the literal when it is parsed to a value.
bytes constant SUB_PARSER_LITERAL_REPEAT_KEYWORD = bytes("ref-extern-repeat-");

/// @dev The keyword for the repeat literal parser, as a bytes32.
bytes32 constant SUB_PARSER_LITERAL_REPEAT_KEYWORD_BYTES32 = bytes32(SUB_PARSER_LITERAL_REPEAT_KEYWORD);

/// @dev The number of bytes in the repeat literal keyword.
uint256 constant SUB_PARSER_LITERAL_REPEAT_KEYWORD_BYTES_LENGTH = 18;

/// @dev The mask to apply to the dispatch bytes when parsing to determin whether
/// the dispatch is for the repeat literal parser.
bytes32 constant SUB_PARSER_LITERAL_REPEAT_KEYWORD_MASK =
    bytes32(~((1 << (32 - SUB_PARSER_LITERAL_REPEAT_KEYWORD_BYTES_LENGTH) * 8) - 1));

/// @dev The index of the repeat literal parser in the literal parser function
/// pointers.
uint256 constant SUB_PARSER_LITERAL_REPEAT_INDEX = 0;

/// @dev Thrown when the repeat literal parser is not a single digit.
error InvalidRepeatCount();

/// @dev Number of opcode function pointers available to run at eval time.
uint256 constant OPCODE_FUNCTION_POINTERS_LENGTH = 1;

/// @title LibRainterpreterReferenceExtern
/// This library allows code SEPARATE FROM the implementation contract to do
/// offchain processing of supporting data without needing to compile all this
/// information into the implementation contract. Any tooling that supports
/// solidity can read this data and expose it to end users.
library LibRainterpreterReferenceExtern {
    /// This mirrors the `authoringMeta` function in `LibAllStandardOps`. The
    /// goal is to produce a standard encoded `AuthoringMeta[]` that tooling can
    /// use to describe all the parseable words, that can be built directly into
    /// a useable parse meta with the standard libs. Note that the list of
    /// parseable words is not limited to the externs, the sub parser is free
    /// to define words that it then parses back into bytecode that is run by
    /// the interpreter itself.
    //slither-disable-next-line dead-code
    function authoringMetaV2() internal pure returns (bytes memory) {
        AuthoringMetaV2 memory lengthPlaceholder;
        AuthoringMetaV2[SUB_PARSER_WORD_PARSERS_LENGTH + 1] memory wordsFixed = [
            lengthPlaceholder,
            AuthoringMetaV2(
                "ref-extern-inc",
                "Demonstrates a sugared extern into the reference implementation that increments every input 1:1 with its outputs."
            ),
            AuthoringMetaV2(
                "ref-extern-stack-operand",
                "Demonstrates using the reference extern to put the operand of a word back into a constant opcode on the main interpreter, without any extern dispatch."
            ),
            AuthoringMetaV2(
                "ref-extern-context-sender",
                "Demonstrates a sugared context reference to the sender assuming the standard position in the context grid at <0 0>."
            ),
            AuthoringMetaV2(
                "ref-extern-context-contract",
                "Demonstrates a sugared context reference to the calling contract assuming the standard position in the context grid at <0 1>."
            ),
            AuthoringMetaV2(
                "ref-extern-context-rainlen",
                "Demonstrates a sugared context reference to the rainlang bytes length assuming the standard position in the context grid at <1 0>."
            )
        ];
        AuthoringMetaV2[] memory wordsDynamic;
        uint256 length = SUB_PARSER_WORD_PARSERS_LENGTH;
        assembly ("memory-safe") {
            wordsDynamic := wordsFixed
            mstore(wordsDynamic, length)
        }
        return abi.encode(wordsDynamic);
    }
}

/// @title RainterpreterReferenceExtern
/// This is a reference implementation of BOTH the sub parser and extern
/// interfaces. It is NOT REQUIRED that these be one and the same. It is entirely
/// possible to implement standalone parsers and extern contracts that each
/// implement the relevant interface. In that case, the parser could construct
/// extern dispatches that encode the address of the extern contract, rather than
/// using `this` as the extern address.
///
/// Parser implementation
/// ---------------------
/// The parser implementation overrides all the virtual functions of the base
/// contracts. This is mandatory for the default implementation to work. The
/// implementation also builds function pointers to sub parsers, literals and
/// operands as external functions so that tooling can check that the constants
/// compiled internally into the contract match what they would be if dynamically
/// calculated. Any discprepancy there is definitely a critical issue that causes
/// undefined behaviour in production, so ALWAYS test this, preferably in an
/// automated way.
///
/// Extern implementation
/// ---------------------
/// The extern implementation overrides the virtual functions of the base
/// contracts. This is mandatory for the default implementation to work. The
/// implementation also builds function pointers to opcodes and integrity checks
/// as external functions so that tooling can check that the constants compiled
/// internally into the contract match what they would be if dynamically
/// calculated. Any discprepancy there is definitely a critical issue that causes
/// undefined behaviour in production, so ALWAYS test this, preferably in an
/// automated way.
contract RainterpreterReferenceExtern is BaseRainterpreterSubParserNPE2, BaseRainterpreterExternNPE2 {
    function describedByMetaV1() external pure override returns (bytes32) {
        return DESCRIBED_BY_META_HASH;
    }

    /// Overrides the base parse meta for sub parsing. Simply returns the known
    /// constant value, which should allow the compiler to optimise the entire
    /// function call away.
    function subParserParseMeta() internal pure virtual override returns (bytes memory) {
        return SUB_PARSER_PARSE_META;
    }

    /// Overrides the base function pointers for sub parsing. Simply returns the
    /// known constant value, which should allow the compiler to optimise the
    /// entire function call away.
    function subParserWordParsers() internal pure override returns (bytes memory) {
        return SUB_PARSER_WORD_PARSERS;
    }

    /// Overrides the base operand handlers for sub parsing. Simply returns the
    /// known constant value, which should allow the compiler to optimise the
    /// entire function call away.
    function subParserOperandHandlers() internal pure override returns (bytes memory) {
        return OPERAND_HANDLER_FUNCTION_POINTERS;
    }

    /// Overrides the base literal parsers for sub parsing. Simply returns the
    /// known constant value, which should allow the compiler to optimise the
    /// entire function call away.
    function subParserLiteralParsers() internal pure override returns (bytes memory) {
        return LITERAL_PARSER_FUNCTION_POINTERS;
    }

    /// Overrides the base function pointers for opcodes. Simply returns the
    /// known constant value, which should allow the compiler to optimise the
    /// entire function call away.
    function opcodeFunctionPointers() internal pure override returns (bytes memory) {
        return OPCODE_FUNCTION_POINTERS;
    }

    /// Overrides the base function pointers for integrity checks. Simply returns
    /// the known constant value, which should allow the compiler to optimise the
    /// entire function call away.
    function integrityFunctionPointers() internal pure override returns (bytes memory) {
        return INTEGRITY_FUNCTION_POINTERS;
    }

    /// The literal parsers are the same as the main parser.
    /// @inheritdoc IParserToolingV1
    function buildLiteralParserFunctionPointers() external pure returns (bytes memory) {
        unchecked {
            function (uint256, uint256, uint256) internal pure returns (uint256) lengthPointer;
            uint256 length = SUB_PARSER_LITERAL_PARSERS_LENGTH;
            assembly ("memory-safe") {
                lengthPointer := length
            }
            function (uint256, uint256, uint256) internal pure returns (uint256)[SUB_PARSER_LITERAL_PARSERS_LENGTH + 1]
                memory parsersFixed = [lengthPointer, LibParseLiteralRepeat.parseRepeat];
            uint256[] memory parsersDynamic;
            assembly ("memory-safe") {
                parsersDynamic := parsersFixed
            }
            // Sanity check that the dynamic length is correct. Should be an
            // unreachable error.
            if (parsersDynamic.length != length) {
                revert BadDynamicLength(parsersDynamic.length, length);
            }
            return LibConvert.unsafeTo16BitBytes(parsersDynamic);
        }
    }

    function matchSubParseLiteralDispatch(uint256 cursor, uint256 end)
        internal
        pure
        virtual
        override
        returns (bool, uint256, bytes32)
    {
        unchecked {
            uint256 length = end - cursor;
            bytes32 word;
            assembly ("memory-safe") {
                word := mload(cursor)
            }
            if (
                length > SUB_PARSER_LITERAL_REPEAT_KEYWORD_BYTES_LENGTH
                    && (word & SUB_PARSER_LITERAL_REPEAT_KEYWORD_MASK) == SUB_PARSER_LITERAL_REPEAT_KEYWORD_BYTES32
            ) {
                ParseState memory state = LibParseState.newState("", "", "", "");
                // If we have a match on the keyword then the next chars MUST
                // be a decimal, otherwise it's an error.
                int256 signedCoefficient;
                int256 exponent;
                (cursor, signedCoefficient, exponent) = LibParseLiteralDecimal.parseDecimalFloat(
                    state, cursor + SUB_PARSER_LITERAL_REPEAT_KEYWORD_BYTES_LENGTH, end
                );
                // We can only repeat a single digit.
                if (LibDecimalFloat.gt(signedCoefficient, exponent, 9, 0)) {
                    revert InvalidRepeatCount();
                }

                return (
                    true,
                    SUB_PARSER_LITERAL_REPEAT_INDEX,
                    PackedFloat.unwrap(LibDecimalFloat.pack(signedCoefficient, exponent))
                );
            } else {
                return (false, 0, 0);
            }
        }
    }

    /// There's only one operand parser for this implementation, the disallowed
    /// parser. We haven't implemented any words with meaningful operands yet.
    /// @inheritdoc IParserToolingV1
    function buildOperandHandlerFunctionPointers() external pure override returns (bytes memory) {
        unchecked {
            function(bytes32[] memory) internal pure returns (OperandV2) lengthPointer;
            uint256 length = SUB_PARSER_WORD_PARSERS_LENGTH;
            assembly ("memory-safe") {
                lengthPointer := length
            }
            function(bytes32[] memory) internal pure returns (OperandV2)[SUB_PARSER_WORD_PARSERS_LENGTH + 1] memory
                handlersFixed = [
                    lengthPointer,
                    // inc
                    LibParseOperand.handleOperandDisallowed,
                    // Stack operand
                    LibParseOperand.handleOperandSingleFull,
                    // Context sender
                    LibParseOperand.handleOperandDisallowed,
                    // Context contract
                    LibParseOperand.handleOperandDisallowed,
                    // Context rainlen
                    LibParseOperand.handleOperandDisallowed
                ];
            uint256[] memory handlersDynamic;
            assembly ("memory-safe") {
                handlersDynamic := handlersFixed
            }
            // Sanity check that the dynamic length is correct. Should be an
            // unreachable error.
            if (handlersDynamic.length != length) {
                revert BadDynamicLength(handlersDynamic.length, length);
            }
            return LibConvert.unsafeTo16BitBytes(handlersDynamic);
        }
    }

    /// This mimics how `LibAllStandardOpsNP` builds bytes out of function
    /// pointers, but for sub parser functions. This is NOT intended to be
    /// called at runtime, instead tooling (e.g. the test suite) can call this
    /// function and compare it to `subParserFunctionPointers` to ensure they
    /// are in sync. This makes the runtime function pointer lookup much more
    /// gas efficient by allowing it to be constant. The reason this can't be
    /// done within the test itself is that the pointers need to be calculated
    /// relative to the bytecode of the current contract, not the test contract.
    /// @inheritdoc ISubParserToolingV1
    function buildSubParserWordParsers() external pure returns (bytes memory) {
        unchecked {
            function(uint256, uint256, OperandV2) internal view returns (bool, bytes memory, bytes32[] memory)
                lengthPointer;
            uint256 length = SUB_PARSER_WORD_PARSERS_LENGTH;
            assembly ("memory-safe") {
                lengthPointer := length
            }
            function(uint256, uint256, OperandV2) internal view returns (bool, bytes memory, bytes32[] memory)[SUB_PARSER_WORD_PARSERS_LENGTH
                + 1] memory pointersFixed = [
                    lengthPointer,
                    LibExternOpIntIncNPE2.subParser,
                    LibExternOpStackOperandNPE2.subParser,
                    LibExternOpContextSenderNPE2.subParser,
                    LibExternOpContextCallingContractNPE2.subParser,
                    LibExternOpContextRainlenNPE2.subParser
                ];
            uint256[] memory pointersDynamic;
            assembly ("memory-safe") {
                pointersDynamic := pointersFixed
            }
            // Sanity check that the dynamic length is correct. Should be an
            // unreachable error.
            if (pointersDynamic.length != length) {
                revert BadDynamicLength(pointersDynamic.length, length);
            }
            return LibConvert.unsafeTo16BitBytes(pointersDynamic);
        }
    }

    /// This mimics how LibAllStandardOpsNP builds function pointers for the
    /// Rainterpreter. The same pattern applies to externs but for a different
    /// function signature for each opcode. Call this function somehow, e.g. from
    /// within a test, and then copy the output into the
    /// `OPCODE_FUNCTION_POINTERS` if there is a mismatch. This makes the
    /// function pointer lookup much more gas efficient. The reason this can't be
    /// done within the test itself is that the pointers need to be calculated
    /// relative to the bytecode of the current contract, not the test contract.
    function buildOpcodeFunctionPointers() external pure returns (bytes memory) {
        unchecked {
            function(OperandV2, StackItem[] memory) internal view returns (StackItem[] memory) lengthPointer;
            uint256 length = OPCODE_FUNCTION_POINTERS_LENGTH;
            assembly ("memory-safe") {
                lengthPointer := length
            }
            function(OperandV2, StackItem[] memory) internal view returns (StackItem[] memory)[OPCODE_FUNCTION_POINTERS_LENGTH
                + 1] memory pointersFixed = [lengthPointer, LibExternOpIntIncNPE2.run];
            uint256[] memory pointersDynamic;
            assembly ("memory-safe") {
                pointersDynamic := pointersFixed
            }
            // Sanity check that the dynamic length is correct. Should be an
            // unreachable error.
            if (pointersDynamic.length != length) {
                revert BadDynamicLength(pointersDynamic.length, length);
            }
            return LibConvert.unsafeTo16BitBytes(pointersDynamic);
        }
    }

    /// This applies the same pattern to integrity function pointers as the
    /// opcode and parser function pointers on this same contract. Call this
    /// function somehow, e.g. from within a test, and then check there is no
    /// mismatch with the `INTEGRITY_FUNCTION_POINTERS` constant. This makes the
    /// function pointer lookup at runtime much more gas efficient by allowing
    /// it to be constant. The reason this can't be done within the test itself
    /// is that the pointers need to be calculated relative to the bytecode of
    /// the current contract, not the test contract.
    function buildIntegrityFunctionPointers() external pure returns (bytes memory) {
        unchecked {
            function(OperandV2, uint256, uint256) internal pure returns (uint256, uint256) lengthPointer;
            uint256 length = OPCODE_FUNCTION_POINTERS_LENGTH;
            assembly ("memory-safe") {
                lengthPointer := length
            }
            function(OperandV2, uint256, uint256) internal pure returns (uint256, uint256)[OPCODE_FUNCTION_POINTERS_LENGTH
                + 1] memory pointersFixed = [lengthPointer, LibExternOpIntIncNPE2.integrity];
            uint256[] memory pointersDynamic;
            assembly ("memory-safe") {
                pointersDynamic := pointersFixed
            }
            // Sanity check that the dynamic length is correct. Should be an
            // unreachable error.
            if (pointersDynamic.length != length) {
                revert BadDynamicLength(pointersDynamic.length, length);
            }
            return LibConvert.unsafeTo16BitBytes(pointersDynamic);
        }
    }

    /// This is only needed because the parser and extern base contracts both
    /// implement IERC165, and the compiler needs to be told how to resolve the
    /// ambiguity.
    /// @inheritdoc BaseRainterpreterSubParserNPE2
    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(BaseRainterpreterSubParserNPE2, BaseRainterpreterExternNPE2)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
