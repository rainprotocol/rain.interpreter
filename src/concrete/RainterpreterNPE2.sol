// SPDX-License-Identifier: CAL
pragma solidity =0.8.19;

import {ERC165} from "openzeppelin-contracts/contracts/utils/introspection/ERC165.sol";
import {LibPointer, Pointer} from "rain.solmem/lib/LibPointer.sol";
import {LibStackPointer} from "rain.solmem/lib/LibStackPointer.sol";
import {LibUint256Array} from "rain.solmem/lib/LibUint256Array.sol";
import {LibMemoryKV, MemoryKV} from "rain.lib.memkv/lib/LibMemoryKV.sol";
import {LibCast} from "rain.lib.typecast/LibCast.sol";
import {LibDataContract} from "rain.datacontract/lib/LibDataContract.sol";

import {LibEvalNP} from "../lib/eval/LibEvalNP.sol";
import {LibInterpreterStateDataContractNP} from "../lib/state/LibInterpreterStateDataContractNP.sol";
import {LibEncodedDispatch} from "../lib/caller/LibEncodedDispatch.sol";
import {InterpreterStateNP} from "../lib/state/LibInterpreterStateNP.sol";
import {LibAllStandardOpsNP} from "../lib/op/LibAllStandardOpsNP.sol";
import {
    SourceIndexV2,
    IInterpreterV2,
    StateNamespace,
    EncodedDispatch,
    FullyQualifiedNamespace
} from "../interface/unstable/IInterpreterV2.sol";
import {IInterpreterStoreV1} from "../interface/IInterpreterStoreV1.sol";

/// @dev Hash of the known interpreter bytecode.
bytes32 constant INTERPRETER_BYTECODE_HASH = bytes32(0xe105f239e060ed602d4867290a624375492c13344e8ff5c85fc83b063acb6057);

/// @dev The function pointers known to the interpreter for dynamic dispatch.
/// By setting these as a constant they can be inlined into the interpreter
/// and loaded at eval time for very low gas (~100) due to the compiler
/// optimising it to a single `codecopy` to build the in memory bytes array.
bytes constant OPCODE_FUNCTION_POINTERS =
    hex"0caf0cf70d320ef70fdb0fed0fff1018105a10ac10bd10ce117011aa126813181268139c143e14b614e5151415141563159215f4167c17231737178d17a117b617d017db17ef18041821182f18ac18ba18c818e318f81910191e192c193a1948199319ab19c319dd19dd19f41a0b1a601a6e1a6e1ab91b041b4f1b4f1b9a1b9a1be51c301c7b1c7b1d1c1e03";

/// @title RainterpreterNPE2
/// @notice Implementation of a Rainlang interpreter that is compatible with
/// native onchain Rainlang parsing.
contract RainterpreterNPE2 is IInterpreterV2, ERC165 {
    using LibEvalNP for InterpreterStateNP;
    using LibInterpreterStateDataContractNP for bytes;

    /// There are MANY ways that eval can be forced into undefined/corrupt
    /// behaviour by passing in invalid data. This is a deliberate design
    /// decision to allow for the interpreter to be as gas efficient as
    /// possible. The interpreter is provably read only, it contains no state
    /// changing evm opcodes reachable on any logic path. This means that
    /// the caller can only harm themselves by passing in invalid data and
    /// either reverting, exhausting gas or getting back some garbage data.
    /// The caller can trivially protect themselves from these OOB issues by
    /// ensuring the integrity check has successfully run over the bytecode
    /// before calling eval. Any smart contract caller can do this by using a
    /// trusted and appropriate deployer contract to deploy the bytecode, which
    /// will automatically run the integrity check during deployment, then
    /// keeping a registry of trusted expression addresses for itself in storage.
    ///
    /// This appears first in the contract in the hope that the compiler will
    /// put it in the most efficient internal dispatch location to save a few
    /// gas per eval call.
    ///
    /// @inheritdoc IInterpreterV2
    function eval2(
        IInterpreterStoreV1 store,
        FullyQualifiedNamespace namespace,
        EncodedDispatch dispatch,
        uint256[][] memory context,
        uint256[] memory inputs
    ) external view virtual returns (uint256[] memory, uint256[] memory) {
        // Decode the dispatch.
        (address expression, SourceIndexV2 sourceIndex, uint256 maxOutputs) = LibEncodedDispatch.decode2(dispatch);
        bytes memory expressionData = LibDataContract.read(expression);

        InterpreterStateNP memory state = expressionData.unsafeDeserializeNP(
            SourceIndexV2.unwrap(sourceIndex), namespace, store, context, OPCODE_FUNCTION_POINTERS
        );
        // We use the return by returning it. Slither false positive.
        //slither-disable-next-line unused-return
        return state.eval2(inputs, maxOutputs);
    }

    /// @inheritdoc ERC165
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IInterpreterV2).interfaceId || super.supportsInterface(interfaceId);
    }

    /// @inheritdoc IInterpreterV2
    function functionPointers() external view virtual returns (bytes memory) {
        return LibAllStandardOpsNP.opcodeFunctionPointers();
    }
}
