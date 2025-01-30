// SPDX-License-Identifier: CAL
pragma solidity ^0.8.18;

import {OpTest} from "test/abstract/OpTest.sol";

import {NotAnExternContract} from "src/error/ErrExtern.sol";
import {IntegrityCheckState} from "src/lib/integrity/LibIntegrityCheckNP.sol";
import {InterpreterState} from "src/lib/state/LibInterpreterState.sol";
import {OperandV2} from "rain.interpreter.interface/interface/unstable/IInterpreterV4.sol";
import {LibOpExternNP} from "src/lib/op/00/LibOpExternNP.sol";
import {LibExtern} from "src/lib/extern/LibExtern.sol";
import {
    EncodedExternDispatch,
    IInterpreterExternV3,
    ExternDispatch
} from "rain.interpreter.interface/interface/IInterpreterExternV3.sol";
import {IERC165} from "openzeppelin-contracts/contracts/utils/introspection/IERC165.sol";
import {LibOperand} from "test/lib/operand/LibOperand.sol";
import {LibUint256Array} from "rain.solmem/lib/LibUint256Array.sol";
import {LibDecimalFloat} from "rain.math.float/lib/LibDecimalFloat.sol";

/// @title LibOpExternNPTest
/// @notice Test the runtime and integrity time logic of LibOpExternNP.
contract LibOpExternNPTest is OpTest {
    using LibUint256Array for uint256[];

    function mockImplementsERC165IInterpreterExternV3(IInterpreterExternV3 extern) internal {
        // Extern needs to implement ERC165 for the interface.
        vm.mockCall(
            address(extern),
            abi.encodeWithSelector(IERC165.supportsInterface.selector, type(IInterpreterExternV3).interfaceId),
            abi.encode(true)
        );
        vm.mockCall(
            address(extern),
            abi.encodeWithSelector(IERC165.supportsInterface.selector, type(IERC165).interfaceId),
            abi.encode(true)
        );
        vm.mockCall(
            address(extern),
            abi.encodeWithSelector(IERC165.supportsInterface.selector, bytes4(0xFFFFFFFF)),
            abi.encode(false)
        );
    }

    function testOpExternNPIntegrityHappy(
        IntegrityCheckState memory state,
        IInterpreterExternV3 extern,
        uint16 constantIndex,
        uint8 inputs,
        uint8 outputs
    ) external {
        inputs = uint8(bound(inputs, 0, 0x0F));
        outputs = uint8(bound(outputs, 0, 0x0F));

        assumeEtchable(address(extern));
        vm.etch(address(extern), hex"fe");
        mockImplementsERC165IInterpreterExternV3(extern);

        vm.assume(state.constants.length > 0);
        constantIndex = uint16(bound(constantIndex, 0, state.constants.length - 1));

        OperandV2 operand = LibOperand.build(inputs, outputs, constantIndex);
        ExternDispatch externDispatch = LibExtern.encodeExternDispatch(0, operand);
        EncodedExternDispatch encodedExternDispatch = LibExtern.encodeExternCall(extern, externDispatch);
        state.constants[constantIndex] = EncodedExternDispatch.unwrap(encodedExternDispatch);

        // Extern integrity needs to match the inputs and outputs.
        vm.mockCall(
            address(extern),
            abi.encodeWithSelector(IInterpreterExternV3.externIntegrity.selector, externDispatch),
            // Have the mock modify the inputs and outputs slightly so we know
            // the implementation is hitting the mock.
            abi.encode(inputs + 1, outputs + 1)
        );
        vm.expectCall(
            address(extern), abi.encodeWithSelector(IInterpreterExternV3.externIntegrity.selector, externDispatch), 1
        );
        (uint256 calcInputs, uint256 calcOutputs) = LibOpExternNP.integrity(state, operand);

        assertEq(calcInputs, inputs + 1, "inputs");
        assertEq(calcOutputs, outputs + 1, "outputs");
    }

    function testOpExternNPIntegrityNotAnExternContract(
        IntegrityCheckState memory state,
        IInterpreterExternV3 extern,
        uint16 constantIndex,
        uint8 inputs,
        uint8 outputs
    ) external {
        inputs = uint8(bound(inputs, 0, 0x0F));
        outputs = uint8(bound(outputs, 0, 0x0F));

        assumeEtchable(address(extern));
        vm.etch(address(extern), hex"fe");
        // Extern needs to implement ERC165 for the interface.
        vm.mockCall(
            address(extern),
            abi.encodeWithSelector(IERC165.supportsInterface.selector, type(IInterpreterExternV3).interfaceId),
            // If this is false then the contract is not an extern.
            abi.encode(false)
        );
        vm.mockCall(
            address(extern),
            abi.encodeWithSelector(IERC165.supportsInterface.selector, type(IERC165).interfaceId),
            abi.encode(true)
        );
        vm.mockCall(
            address(extern),
            abi.encodeWithSelector(IERC165.supportsInterface.selector, bytes4(0xFFFFFFFF)),
            abi.encode(false)
        );

        vm.assume(state.constants.length > 0);
        constantIndex = uint16(bound(constantIndex, 0, state.constants.length - 1));

        OperandV2 operand = LibOperand.build(inputs, outputs, constantIndex);
        ExternDispatch externDispatch = LibExtern.encodeExternDispatch(0, operand);
        EncodedExternDispatch encodedExternDispatch = LibExtern.encodeExternCall(extern, externDispatch);
        state.constants[constantIndex] = EncodedExternDispatch.unwrap(encodedExternDispatch);

        vm.expectRevert(abi.encodeWithSelector(NotAnExternContract.selector, address(extern)));
        this.externalIntegrity(state, operand);
    }

    /// This needs to be exposed externally so that mocks and reverts play nice
    /// with each other.
    function externalIntegrity(IntegrityCheckState memory state, OperandV2 operand)
        external
        view
        returns (uint256, uint256)
    {
        return LibOpExternNP.integrity(state, operand);
    }

    /// Test the eval of extern directly.
    function testOpExternNPRunHappy(
        IInterpreterExternV3 extern,
        uint256[] memory constants,
        uint16 constantIndex,
        uint256[] memory inputs,
        uint256[] memory outputs
    ) external {
        vm.assume(constants.length > 0);
        if (inputs.length > 0x0F) {
            inputs.truncate(0x0F);
        }
        if (outputs.length > 0x0F) {
            outputs.truncate(0x0F);
        }

        InterpreterState memory state = opTestDefaultInterpreterState();
        state.constants = constants;

        assumeEtchable(address(extern));
        vm.etch(address(extern), hex"fe");
        mockImplementsERC165IInterpreterExternV3(extern);

        constantIndex = uint16(bound(constantIndex, 0, state.constants.length - 1));

        OperandV2 operand = LibOperand.build(uint8(inputs.length), uint8(outputs.length), constantIndex);
        ExternDispatch externDispatch = LibExtern.encodeExternDispatch(0, operand);
        EncodedExternDispatch encodedExternDispatch = LibExtern.encodeExternCall(extern, externDispatch);
        state.constants[constantIndex] = EncodedExternDispatch.unwrap(encodedExternDispatch);

        // Extern integrity needs to match the inputs and outputs.
        vm.mockCall(
            address(extern),
            abi.encodeWithSelector(IInterpreterExternV3.externIntegrity.selector, externDispatch),
            abi.encode(inputs.length, outputs.length)
        );

        // Extern run needs to match the inputs and outputs.
        vm.mockCall(
            address(extern),
            abi.encodeWithSelector(IInterpreterExternV3.extern.selector, externDispatch, inputs),
            abi.encode(outputs)
        );
        // Expect this for both the reference fn and the run.
        vm.expectCall(
            address(extern), abi.encodeWithSelector(IInterpreterExternV3.extern.selector, externDispatch, inputs), 2
        );

        opReferenceCheck(state, operand, LibOpExternNP.referenceFn, LibOpExternNP.integrity, LibOpExternNP.run, inputs);
    }

    /// Test the eval of extern parsed from a string.
    function testOpExternNPEvalHappy() external {
        IInterpreterExternV3 extern = IInterpreterExternV3(address(0xdeadbeef));
        vm.etch(address(extern), hex"fe");
        uint256 opcode = 5;
        OperandV2 operand = OperandV2.wrap(0x10);

        ExternDispatch externDispatch = LibExtern.encodeExternDispatch(opcode, operand);
        assertEq(
            ExternDispatch.unwrap(externDispatch), 0x0000000000000000000000000000000000000000000000000000000000050010
        );

        EncodedExternDispatch encodedExternDispatch = LibExtern.encodeExternCall(extern, externDispatch);
        assertEq(
            EncodedExternDispatch.unwrap(encodedExternDispatch),
            0x00000000000000000005001000000000000000000000000000000000deadbeef
        );

        mockImplementsERC165IInterpreterExternV3(extern);
        // Extern integrity needs to match the inputs and outputs.
        vm.mockCall(
            address(extern),
            abi.encodeWithSelector(IInterpreterExternV3.externIntegrity.selector, externDispatch),
            abi.encode(2, 1)
        );

        uint256[] memory externInputs = new uint256[](2);
        externInputs[0] = LibDecimalFloat.pack(20e36, -36);
        externInputs[1] = LibDecimalFloat.pack(83e36, -36);
        uint256[] memory externOutputs = new uint256[](1);
        externOutputs[0] = LibDecimalFloat.pack(99e36, -36);
        vm.mockCall(
            address(extern),
            abi.encodeWithSelector(IInterpreterExternV3.extern.selector, externDispatch, externInputs),
            abi.encode(externOutputs)
        );

        uint256[] memory expectedStack = new uint256[](2);
        expectedStack[0] = LibDecimalFloat.pack(99e36, -36);
        expectedStack[1] = 0x00000000000000000005001000000000000000000000000000000000deadbeef;

        checkHappy(
            // Need the constant in the constant array to be indexable in the operand.
            "_: 0x00000000000000000005001000000000000000000000000000000000deadbeef,"
            // Operand is the constant index of the dispatch then the number of outputs.
            // 2 inputs and 1 output matches the mocked integrity check.
            "_: extern<0>(20 83);",
            expectedStack,
            "0xdeadbeef 20 83 99"
        );
    }

    /// Test the eval of extern parsed from a string with multiple inputs and
    /// outputs.
    function testOpExternNPEvalMultipleInputsOutputsHappy() external {
        IInterpreterExternV3 extern = IInterpreterExternV3(address(0xdeadbeef));
        vm.etch(address(extern), hex"fe");
        uint256 opcode = 5;
        OperandV2 operand = OperandV2.wrap(0x10);

        ExternDispatch externDispatch = LibExtern.encodeExternDispatch(opcode, operand);
        assertEq(
            ExternDispatch.unwrap(externDispatch), 0x0000000000000000000000000000000000000000000000000000000000050010
        );

        EncodedExternDispatch encodedExternDispatch = LibExtern.encodeExternCall(extern, externDispatch);
        assertEq(
            EncodedExternDispatch.unwrap(encodedExternDispatch),
            0x00000000000000000005001000000000000000000000000000000000deadbeef
        );

        mockImplementsERC165IInterpreterExternV3(extern);
        // Extern integrity needs to match the inputs and outputs.
        vm.mockCall(
            address(extern),
            abi.encodeWithSelector(IInterpreterExternV3.externIntegrity.selector, externDispatch),
            abi.encode(3, 3)
        );

        uint256[] memory externInputs = new uint256[](3);
        externInputs[0] = LibDecimalFloat.pack(1e37, -37);
        externInputs[1] = LibDecimalFloat.pack(2e37, -37);
        externInputs[2] = LibDecimalFloat.pack(3e37, -37);

        uint256[] memory externOutputs = new uint256[](3);
        externOutputs[0] = LibDecimalFloat.pack(4e37, -37);
        externOutputs[1] = LibDecimalFloat.pack(5e37, -37);
        externOutputs[2] = LibDecimalFloat.pack(6e37, -37);

        uint256[] memory expectedStack = new uint256[](4);
        expectedStack[0] = LibDecimalFloat.pack(6e37, -37);
        expectedStack[1] = LibDecimalFloat.pack(5e37, -37);
        expectedStack[2] = LibDecimalFloat.pack(4e37, -37);
        expectedStack[3] = 0x00000000000000000005001000000000000000000000000000000000deadbeef;

        vm.mockCall(
            address(extern),
            abi.encodeWithSelector(IInterpreterExternV3.extern.selector, externDispatch, externInputs),
            abi.encode(externOutputs)
        );
        vm.expectCall(
            address(extern),
            abi.encodeWithSelector(IInterpreterExternV3.extern.selector, externDispatch, externInputs),
            1
        );

        checkHappy(
            // Need the constant in the constant array to be indexable in the operand.
            "_: 0x00000000000000000005001000000000000000000000000000000000deadbeef,"
            // Operand is the constant index of the dispatch then the number of outputs.
            // 3 inputs and 3 outputs matches the mocked integrity check.
            "four five six: extern<0>(1 2 3);",
            expectedStack,
            "0xdeadbeef 1 2 3 4 5 6"
        );
    }
}
