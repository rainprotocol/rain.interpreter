// SPDX-License-Identifier: CAL
pragma solidity =0.8.25;

import {Test} from "forge-std/Test.sol";

import {ExpectedOperand, UnclosedOperand} from "src/error/ErrParse.sol";
import {AuthoringMetaV2} from "rain.interpreter.interface/interface/IParserV2.sol";
import {LibParseMeta} from "rain.interpreter.interface/lib/parse/LibParseMeta.sol";
import {LibParse, DuplicateLHSItem, WordSize} from "src/lib/parse/LibParse.sol";
import {LibBytecode} from "rain.interpreter.interface/lib/bytecode/LibBytecode.sol";
import {LibMetaFixture} from "test/lib/parse/LibMetaFixture.sol";
import {LibParseState, ParseState} from "src/lib/parse/LibParseState.sol";
import {LibParseLiteral} from "src/lib/parse/literal/LibParseLiteral.sol";
import {OperandV2, LibParseOperand} from "src/lib/parse/LibParseOperand.sol";
import {LibConvert} from "rain.lib.typecast/LibConvert.sol";
import {LibAllStandardOpsNP} from "src/lib/op/LibAllStandardOpsNP.sol";
import {LibGenParseMeta} from "rain.sol.codegen/lib/LibGenParseMeta.sol";
import {LibDecimalFloat} from "rain.math.float/lib/LibDecimalFloat.sol";

/// @title LibParseNamedLHSTest
contract LibParseNamedLHSTest is Test {
    using LibParse for ParseState;

    /// A few simple examples that should create some empty sources.
    function testParseNamedLHSEmptySourceExamples() external view {
        string[3] memory examples0 = ["a _:;", "a b:;", "foo bar:;"];
        for (uint256 i = 0; i < examples0.length; i++) {
            (bytes memory bytecode0, uint256[] memory constants0) = LibMetaFixture.newState(examples0[i]).parse();
            assertEq(LibBytecode.sourceCount(bytecode0), 1);
            uint256 sourceIndex0 = 0;
            assertEq(LibBytecode.sourceRelativeOffset(bytecode0, sourceIndex0), 0);
            assertEq(LibBytecode.sourceOpsCount(bytecode0, sourceIndex0), 0);
            assertEq(LibBytecode.sourceStackAllocation(bytecode0, sourceIndex0), 2);
            (uint256 inputs0, uint256 outputs0) = LibBytecode.sourceInputsOutputsLength(bytecode0, sourceIndex0);
            assertEq(inputs0, 2);
            assertEq(outputs0, 2);
            assertEq(constants0.length, 0);
        }
    }

    /// Two sources with one named input each.
    function testParseNamedLHSTwoInputs() external view {
        (bytes memory bytecode, uint256[] memory constants) = LibMetaFixture.newState("a:;b:;").parse();
        assertEq(
            bytecode,
            // 2 sources.
            hex"02"
            // offset 0
            hex"0000"
            // offset 4
            hex"0004"
            // 0 ops
            hex"00"
            // 1 stack allocation
            hex"01"
            // 1 input
            hex"01"
            // 1 output
            hex"01"
            // 0 ops
            hex"00"
            // 1 stack allocation
            hex"01"
            // 1 input
            hex"01"
            // 1 output
            hex"01"
        );

        assertEq(LibBytecode.sourceCount(bytecode), 2);

        uint256 sourceIndex = 0;
        assertEq(LibBytecode.sourceRelativeOffset(bytecode, sourceIndex), 0);
        assertEq(LibBytecode.sourceOpsCount(bytecode, sourceIndex), 0);
        assertEq(LibBytecode.sourceStackAllocation(bytecode, sourceIndex), 1);
        (uint256 inputs, uint256 outputs) = LibBytecode.sourceInputsOutputsLength(bytecode, sourceIndex);
        assertEq(inputs, 1);
        assertEq(outputs, 1);

        sourceIndex = 1;
        assertEq(LibBytecode.sourceRelativeOffset(bytecode, sourceIndex), 4);
        assertEq(LibBytecode.sourceOpsCount(bytecode, sourceIndex), 0);
        assertEq(LibBytecode.sourceStackAllocation(bytecode, sourceIndex), 1);
        (inputs, outputs) = LibBytecode.sourceInputsOutputsLength(bytecode, sourceIndex);
        assertEq(inputs, 1);
        assertEq(outputs, 1);

        assertEq(constants.length, 0);
    }

    /// Exceeding the maximum length of a word should revert. Testing a 32 char
    /// is right at the limit.
    function testParseNamedError32() external {
        // Only the first 32 chars are visible in the error.
        vm.expectRevert(abi.encodeWithSelector(WordSize.selector, "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"));
        // 32 chars is too long.
        LibMetaFixture.newState("aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa:;").parse();
    }

    /// Exceeding the maximum length of a word should revert. Testing a 33 char
    /// word shows the difference between the actual source and the error.
    /// (The latter is truncated).
    function testParseNamedError33() external {
        // Only the first 32 chars are visible in the error.
        vm.expectRevert(abi.encodeWithSelector(WordSize.selector, "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"));
        // 33 chars is too long.
        LibMetaFixture.newState("aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa:;").parse();
    }

    /// Stack needs to index items by name correctly across lines.
    function testParseNamedLHSStackIndex() external view {
        AuthoringMetaV2[] memory meta = new AuthoringMetaV2[](3);
        meta[0] = AuthoringMetaV2("stack", "stack");
        meta[1] = AuthoringMetaV2("constant", "constant");
        meta[2] = AuthoringMetaV2("c", "c");
        bytes memory parseMeta = LibGenParseMeta.buildParseMetaV2(meta, 1);

        function (uint256[] memory) internal pure returns (OperandV2)[] memory operandHandlers =
            new function (uint256[] memory) internal pure returns (OperandV2)[](3);
        operandHandlers[0] = LibParseOperand.handleOperandDisallowed;
        operandHandlers[1] = LibParseOperand.handleOperandDisallowed;
        operandHandlers[2] = LibParseOperand.handleOperandSingleFull;
        uint256[] memory pointers;
        assembly ("memory-safe") {
            pointers := operandHandlers
        }
        bytes memory operandHandlerPointers = LibConvert.unsafeTo16BitBytes(pointers);

        (bytes memory bytecode, uint256[] memory constants) = LibParseState.newState(
            bytes("a _:1 2,b:a,:c(),d:3,e:d;"),
            parseMeta,
            operandHandlerPointers,
            LibAllStandardOpsNP.literalParserFunctionPointers()
        ).parse();
        assertEq(
            bytecode,
            // 2 sources.
            hex"01"
            // offset 0
            hex"0000"
            // 6 ops
            hex"06"
            // 5 stack allocation
            hex"05"
            // 0 input
            hex"00"
            // 5 output
            hex"05"
            // constant 0
            hex"01100000"
            // constant 1
            hex"01100001"
            // stack 0
            hex"00100000"
            // c
            hex"02000000"
            // constant 2
            hex"01100002"
            // stack 3
            hex"00100003"
        );
        assertEq(constants.length, 3);
        assertEq(constants[0], LibDecimalFloat.pack(1e37, -37));
        assertEq(constants[1], LibDecimalFloat.pack(2e37, -37));
        assertEq(constants[2], LibDecimalFloat.pack(3e37, -37));
    }

    /// Duplicate names are disallowed in the same source.
    function testParseNamedErrorDuplicateSameSource() external {
        vm.expectRevert(abi.encodeWithSelector(DuplicateLHSItem.selector, 4));
        LibMetaFixture.newState("a:,a:;").parse();
    }

    /// Duplicate names are allowed across different sources.
    function testParseNamedDuplicateDifferentSource() external view {
        (bytes memory bytecode, uint256[] memory constants) = LibParseState.newState(
            "a b:1 2, e:a;c d:3 4,e:d;", "", "", LibAllStandardOpsNP.literalParserFunctionPointers()
        ).parse();
        assertEq(
            bytecode,
            // 2 sources.
            hex"02"
            // offset 0
            hex"0000"
            // offset 16
            hex"0010"
            // 3 ops
            hex"03"
            // 3 stack allocation
            hex"03"
            // 0 input
            hex"00"
            // 3 output
            hex"03"
            // constant 0
            hex"01100000"
            // constant 1
            hex"01100001"
            // stack 0
            hex"00100000"
            // 3 ops
            hex"03"
            // 1 stack allocation
            hex"03"
            // 0 input
            hex"00"
            // 3 outputs
            hex"03"
            // constant 2
            hex"01100002"
            // constant 3
            hex"01100003"
            // stack 1
            hex"00100001"
        );
        assertEq(constants.length, 4);
        assertEq(constants[0], LibDecimalFloat.pack(1e37, -37));
        assertEq(constants[1], LibDecimalFloat.pack(2e37, -37));
        assertEq(constants[2], LibDecimalFloat.pack(3e37, -37));
        assertEq(constants[3], LibDecimalFloat.pack(4e37, -37));
    }
}
