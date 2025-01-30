// SPDX-License-Identifier: CAL
pragma solidity =0.8.25;

import {ERC165} from "openzeppelin-contracts/contracts/utils/introspection/ERC165.sol";
import {LibPointer, Pointer} from "rain.solmem/lib/LibPointer.sol";
import {LibStackPointer} from "rain.solmem/lib/LibStackPointer.sol";
import {LibUint256Array} from "rain.solmem/lib/LibUint256Array.sol";
import {LibMemoryKV, MemoryKV, MemoryKVKey, MemoryKVVal} from "rain.lib.memkv/lib/LibMemoryKV.sol";
import {LibCast} from "rain.lib.typecast/LibCast.sol";
import {LibDataContract} from "rain.datacontract/lib/LibDataContract.sol";

import {LibEval} from "../lib/eval/LibEval.sol";
import {LibInterpreterStateDataContract} from "../lib/state/LibInterpreterStateDataContract.sol";
import {InterpreterState} from "../lib/state/LibInterpreterState.sol";
import {LibAllStandardOpsNP} from "../lib/op/LibAllStandardOpsNP.sol";
import {
    IInterpreterV4,
    SourceIndexV2,
    EvalV4,
    StackItem
} from "rain.interpreter.interface/interface/unstable/IInterpreterV4.sol";
import {
    BYTECODE_HASH as INTERPRETER_BYTECODE_HASH,
    OPCODE_FUNCTION_POINTERS
} from "../generated/Rainterpreter.pointers.sol";
import {IOpcodeToolingV1} from "rain.sol.codegen/interface/IOpcodeToolingV1.sol";

/// @title Rainterpreter
/// @notice Implementation of a Rainlang interpreter that is compatible with
/// native onchain Rainlang parsing.
contract Rainterpreter is IInterpreterV4, IOpcodeToolingV1, ERC165 {
    using LibEval for InterpreterState;
    using LibInterpreterStateDataContract for bytes;

    /// @inheritdoc IInterpreterV4
    function eval4(EvalV4 calldata eval)
        external
        view
        virtual
        override
        returns (StackItem[] memory, bytes32[] memory)
    {
        InterpreterState memory state = eval.bytecode.unsafeDeserialize(
            SourceIndexV2.unwrap(eval.sourceIndex), eval.namespace, eval.store, eval.context, OPCODE_FUNCTION_POINTERS
        );
        for (uint256 i = 0; i < eval.stateOverlay.length; i += 2) {
            state.stateKV = LibMemoryKV.set(
                state.stateKV, MemoryKVKey.wrap(eval.stateOverlay[i]), MemoryKVVal.wrap(eval.stateOverlay[i + 1])
            );
        }
        // We use the return by returning it. Slither false positive.
        //slither-disable-next-line unused-return
        return state.eval2(eval.inputs, type(uint256).max);
    }

    /// @inheritdoc ERC165
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IInterpreterV4).interfaceId || super.supportsInterface(interfaceId);
    }

    /// @inheritdoc IOpcodeToolingV1
    function buildOpcodeFunctionPointers() public view virtual override returns (bytes memory) {
        return LibAllStandardOpsNP.opcodeFunctionPointers();
    }
}
