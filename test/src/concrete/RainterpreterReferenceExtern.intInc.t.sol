// SPDX-License-Identifier: CAL
pragma solidity =0.8.25;

import {OpTest} from "test/abstract/OpTest.sol";
import {
    RainterpreterReferenceExtern,
    OPCODE_FUNCTION_POINTERS,
    INTEGRITY_FUNCTION_POINTERS,
    OP_INDEX_INCREMENT,
    LibExternOpIntIncNPE2
} from "src/concrete/extern/RainterpreterReferenceExtern.sol";
import {
    ExternDispatchV2,
    EncodedExternDispatchV2,
    IInterpreterExternV4,
    StackItem
} from "rain.interpreter.interface/interface/unstable/IInterpreterExternV4.sol";
import {OperandV2} from "rain.interpreter.interface/interface/unstable/IInterpreterV4.sol";
import {LibExtern} from "src/lib/extern/LibExtern.sol";
import {Strings} from "openzeppelin-contracts/contracts/utils/Strings.sol";
import {OPCODE_EXTERN} from "rain.interpreter.interface/interface/unstable/IInterpreterV4.sol";
import {ExternDispatchConstantsHeightOverflow} from "src/error/ErrSubParse.sol";
import {LibDecimalFloat, PackedFloat} from "rain.math.float/lib/LibDecimalFloat.sol";

contract RainterpreterReferenceExternIntIncTest is OpTest {
    using Strings for address;

    function testRainterpreterReferenceExternIntIncHappyUnsugared() external {
        RainterpreterReferenceExtern extern = new RainterpreterReferenceExtern();

        uint256 intIncOpcode = 0;

        ExternDispatchV2 externDispatch = LibExtern.encodeExternDispatch(intIncOpcode, OperandV2.wrap(0));
        EncodedExternDispatchV2 encodedExternDispatch = LibExtern.encodeExternCall(extern, externDispatch);

        assertEq(
            EncodedExternDispatchV2.unwrap(encodedExternDispatch),
            0x000000000000000000000000c7183455a4c133ae270771860664b6b7ec320bb1
        );

        StackItem[] memory expectedStack = new StackItem[](3);
        expectedStack[0] = StackItem.wrap(PackedFloat.unwrap(LibDecimalFloat.pack(4e37, -37)));
        expectedStack[1] = StackItem.wrap(PackedFloat.unwrap(LibDecimalFloat.pack(3e37, -37)));
        expectedStack[2] = StackItem.wrap(EncodedExternDispatchV2.unwrap(encodedExternDispatch));

        checkHappy(
            // Need the constant in the constant array to be indexable in the operand.
            "_: 0x000000000000000000000000c7183455a4c133ae270771860664b6b7ec320bb1,"
            // Operand is the constant index of the dispatch.
            "three four: extern<0>(2 3);",
            expectedStack,
            "inc 2 3 = 3 4"
        );
    }

    function testRainterpreterReferenceExternIntIncHappySugared() external {
        RainterpreterReferenceExtern extern = new RainterpreterReferenceExtern();

        StackItem[] memory expectedStack = new StackItem[](2);
        expectedStack[0] = StackItem.wrap(PackedFloat.unwrap(LibDecimalFloat.pack(4e37, -37)));
        expectedStack[1] = StackItem.wrap(PackedFloat.unwrap(LibDecimalFloat.pack(3e37, -37)));

        checkHappy(
            bytes(
                string.concat("using-words-from ", address(extern).toHexString(), " three four: ref-extern-inc(2 3);")
            ),
            expectedStack,
            "sugared inc 2 3 = 3 4"
        );
    }

    /// Directly test the subparsing of the reference extern opcode.
    /// forge-config: default.fuzz.runs = 100
    function testRainterpreterReferenceExternIntIncSubParseKnownWord(uint16 constantsHeight, bytes1 ioByte) external {
        // Extern "only" supports up to constant height of 0xFF.
        constantsHeight = uint16(bound(constantsHeight, 0, 0xFF));
        RainterpreterReferenceExtern subParser = new RainterpreterReferenceExtern();

        bytes memory wordToParse = bytes("ref-extern-inc");
        (bool success, bytes memory bytecode, bytes32[] memory constants) = subParser.subParseWord2(
            bytes.concat(bytes2(constantsHeight), ioByte, bytes2(uint16(wordToParse.length)), wordToParse, bytes32(0))
        );
        assertTrue(success);

        assertEq(bytecode.length, 4);
        assertEq(uint256(uint8(bytecode[0])), OPCODE_EXTERN);
        assertEq(bytecode[1], ioByte);
        // Low bytes for the extern opcode is the constants index of the extern
        // dispatch.
        assertEq((uint16(uint8(bytecode[2])) << 8) | uint16(uint8(bytecode[3])), constantsHeight);

        assertEq(constants.length, 1);
        (IInterpreterExternV4 decodedExtern, ExternDispatchV2 decodedExternDispatch) =
            LibExtern.decodeExternCall(EncodedExternDispatchV2.wrap(constants[0]));

        // The sub parser is also the extern contract because the reference
        // implementation includes both.
        assertEq(address(decodedExtern), address(subParser));

        (uint256 opcode, OperandV2 operand) = LibExtern.decodeExternDispatch(decodedExternDispatch);
        assertEq(opcode, OP_INDEX_INCREMENT);
        assertEq(OperandV2.unwrap(operand), 0);
    }

    /// Directly test the subparsing of the reference extern opcode. Check that
    /// we get a false for success if the subparser doesn't recognize the word
    /// but the data is otherwise valid.
    /// forge-config: default.fuzz.runs = 100
    function testRainterpreterReferenceExternIntIncSubParseUnknownWord(
        uint16 constantsHeight,
        bytes1 ioByte,
        bytes memory unknownWord
    ) external {
        vm.assume(keccak256(unknownWord) != keccak256("ref-extern-inc"));
        vm.assume(unknownWord.length < 32);
        // Extern "only" supports up to constant height of 0xFF.
        constantsHeight = uint16(bound(constantsHeight, 0, 0xFF));
        RainterpreterReferenceExtern subParser = new RainterpreterReferenceExtern();

        (bool success, bytes memory bytecode, bytes32[] memory constants) = subParser.subParseWord2(
            bytes.concat(bytes2(constantsHeight), ioByte, bytes2(uint16(unknownWord.length)), unknownWord, bytes32(0))
        );
        assertFalse(success);
        assertEq(bytecode.length, 0);
        assertEq(constants.length, 0);
    }

    /// Test the inc library directly. The run function should increment every
    /// value it is passed by 1.
    /// forge-config: default.fuzz.runs = 100
    function testRainterpreterReferenceExternIntIncRun(OperandV2 operand, StackItem[] memory inputs) external pure {
        StackItem[] memory expectedOutputs = new StackItem[](inputs.length);
        for (uint256 i = 0; i < inputs.length; i++) {
            inputs[i] = StackItem.wrap(
                bytes32(bound(uint256(StackItem.unwrap(inputs[i])), 0, uint256(int256(type(int128).max))))
            );
            (int256 signedCoefficient, int256 exponent) =
                LibDecimalFloat.unpack(PackedFloat.wrap(StackItem.unwrap(inputs[i])));
            (signedCoefficient, exponent) = LibDecimalFloat.add(signedCoefficient, exponent, 1e37, -37);
            expectedOutputs[i] = StackItem.wrap(PackedFloat.unwrap(LibDecimalFloat.pack(signedCoefficient, exponent)));
        }

        StackItem[] memory actualOutputs = LibExternOpIntIncNPE2.run(operand, inputs);
        assertEq(actualOutputs.length, expectedOutputs.length);
        for (uint256 i = 0; i < actualOutputs.length; i++) {
            assertEq(StackItem.unwrap(actualOutputs[i]), StackItem.unwrap(expectedOutputs[i]));
        }
    }

    /// Test the inc library directly. The integrity function should return the
    /// same inputs and outputs.
    /// forge-config: default.fuzz.runs = 100
    function testRainterpreterReferenceExternIntIncIntegrity(OperandV2 operand, uint256 inputs, uint256 outputs)
        external
        pure
    {
        (uint256 calcInputs, uint256 calcOutputs) = LibExternOpIntIncNPE2.integrity(operand, inputs, outputs);
        assertEq(calcInputs, inputs);
        assertEq(calcOutputs, inputs);
    }
}
