// SPDX-License-Identifier: CAL
pragma solidity =0.8.25;

import {ERC165} from "openzeppelin-contracts/contracts/utils/introspection/ERC165.sol";

import {BadInputs} from "../error/ErrExtern.sol";
import {Pointer} from "rain.solmem/lib/LibPointer.sol";
import {LibStackPointer} from "rain.solmem/lib/LibStackPointer.sol";
import {LibUint256Array} from "rain.solmem/lib/LibUint256Array.sol";

import {OperandV2} from "rain.interpreter.interface/interface/unstable/IInterpreterV4.sol";
import {
    IInterpreterExternV4,
    ExternDispatchV2,
    StackItem
} from "rain.interpreter.interface/interface/unstable/IInterpreterExternV4.sol";
import {IIntegrityToolingV1} from "rain.sol.codegen/interface/IIntegrityToolingV1.sol";
import {IOpcodeToolingV1} from "rain.sol.codegen/interface/IOpcodeToolingV1.sol";

/// @dev Empty opcode function pointers constant. Inheriting contracts should
/// create their own constant and override `opcodeFunctionPointers` to use
/// theirs.
bytes constant OPCODE_FUNCTION_POINTERS = hex"";
/// @dev Empty integrity function pointers constant. Inheriting contracts should
/// create their own constant and override `integrityFunctionPointers` to use
/// theirs.
bytes constant INTEGRITY_FUNCTION_POINTERS = hex"";

/// Base implementation of `IInterpreterExternV3`. Inherit from this contract,
/// and override `functionPointers` to provide a list of function pointers.
abstract contract BaseRainterpreterExternNPE2 is IInterpreterExternV4, IIntegrityToolingV1, IOpcodeToolingV1, ERC165 {
    using LibStackPointer for uint256[];
    using LibStackPointer for Pointer;
    using LibUint256Array for uint256;
    using LibUint256Array for uint256[];

    /// @inheritdoc IInterpreterExternV4
    function extern(ExternDispatchV2 dispatch, StackItem[] memory inputs)
        external
        view
        virtual
        override
        returns (StackItem[] memory outputs)
    {
        unchecked {
            bytes memory fPointers = opcodeFunctionPointers();
            uint256 fsCount = fPointers.length / 2;
            uint256 fPointersStart;
            assembly ("memory-safe") {
                fPointersStart := add(fPointers, 0x20)
            }
            uint256 opcode = uint256((ExternDispatchV2.unwrap(dispatch) >> 0x10) & bytes32(uint256(type(uint16).max)));
            OperandV2 operand = OperandV2.wrap(ExternDispatchV2.unwrap(dispatch) & bytes32(uint256(type(uint16).max)));

            function(OperandV2, StackItem[] memory) internal view returns (StackItem[] memory) f;
            assembly ("memory-safe") {
                f := shr(0xf0, mload(add(fPointersStart, mul(mod(opcode, fsCount), 2))))
            }
            outputs = f(operand, inputs);
        }
    }

    /// @inheritdoc IInterpreterExternV4
    function externIntegrity(ExternDispatchV2 dispatch, uint256 expectedInputs, uint256 expectedOutputs)
        external
        pure
        virtual
        override
        returns (uint256 actualInputs, uint256 actualOutputs)
    {
        unchecked {
            bytes memory fPointers = integrityFunctionPointers();
            uint256 fsCount = fPointers.length / 2;
            uint256 fPointersStart;
            assembly ("memory-safe") {
                fPointersStart := add(fPointers, 0x20)
            }
            uint256 opcode = uint256((ExternDispatchV2.unwrap(dispatch) >> 0x10) & bytes32(uint256(type(uint16).max)));
            OperandV2 operand = OperandV2.wrap(ExternDispatchV2.unwrap(dispatch) & bytes32(uint256(type(uint16).max)));

            function(OperandV2, uint256, uint256) internal pure returns (uint256, uint256) f;
            assembly ("memory-safe") {
                f := shr(0xf0, mload(add(fPointersStart, mul(mod(opcode, fsCount), 2))))
            }
            (actualInputs, actualOutputs) = f(operand, expectedInputs, expectedOutputs);
        }
    }

    /// @inheritdoc ERC165
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IInterpreterExternV4).interfaceId || super.supportsInterface(interfaceId);
    }

    /// Overrideable function to provide the list of function pointers for
    /// word dispatches.
    //slither-disable-next-line dead-code
    function opcodeFunctionPointers() internal view virtual returns (bytes memory) {
        return OPCODE_FUNCTION_POINTERS;
    }

    /// Overrideable function to provide the list of function pointers for
    /// integrity checks.
    //slither-disable-next-line dead-code
    function integrityFunctionPointers() internal pure virtual returns (bytes memory) {
        return INTEGRITY_FUNCTION_POINTERS;
    }
}
