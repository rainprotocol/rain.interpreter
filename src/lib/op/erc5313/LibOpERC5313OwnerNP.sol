// SPDX-License-Identifier: CAL
pragma solidity ^0.8.25;

import {IERC5313} from "openzeppelin-contracts/contracts/interfaces/IERC5313.sol";
import {Pointer} from "rain.solmem/lib/LibPointer.sol";
import {IntegrityCheckState} from "../../integrity/LibIntegrityCheckNP.sol";
import {OperandV2} from "rain.interpreter.interface/interface/unstable/IInterpreterV4.sol";
import {InterpreterState} from "../../state/LibInterpreterState.sol";

/// @title LibOpERC5313OwnerNP
/// @notice Opcode for ERC5313 `owner`.
library LibOpERC5313OwnerNP {
    function integrity(IntegrityCheckState memory, OperandV2) internal pure returns (uint256, uint256) {
        // Always 1 input, the contract.
        // Always 1 output, the owner.
        return (1, 1);
    }

    function run(InterpreterState memory, OperandV2, Pointer stackTop) internal view returns (Pointer) {
        uint256 account;
        assembly ("memory-safe") {
            account := mload(stackTop)
        }
        address owner = IERC5313(address(uint160(account))).owner();
        assembly ("memory-safe") {
            mstore(stackTop, owner)
        }
        return stackTop;
    }

    function referenceFn(InterpreterState memory, OperandV2, uint256[] memory inputs)
        internal
        view
        returns (uint256[] memory)
    {
        uint256 account = inputs[0];
        address owner = IERC5313(address(uint160(account))).owner();
        uint256[] memory outputs = new uint256[](1);
        outputs[0] = uint256(uint160(owner));
        return outputs;
    }
}
