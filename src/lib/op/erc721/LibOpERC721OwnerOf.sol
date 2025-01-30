// SPDX-License-Identifier: CAL
pragma solidity ^0.8.18;

import {IERC721} from "openzeppelin-contracts/contracts/token/ERC721/IERC721.sol";
import {Pointer} from "rain.solmem/lib/LibPointer.sol";
import {IntegrityCheckState} from "../../integrity/LibIntegrityCheckNP.sol";
import {OperandV2} from "rain.interpreter.interface/interface/unstable/IInterpreterV4.sol";
import {InterpreterState} from "../../state/LibInterpreterState.sol";

/// @title LibOpERC721OwnerOf
/// @notice Opcode for getting the current owner of an erc721 token.
library LibOpERC721OwnerOf {
    function integrity(IntegrityCheckState memory, OperandV2) internal pure returns (uint256, uint256) {
        // Always 2 inputs, the token and the tokenId.
        // Always 1 output, the owner.
        return (2, 1);
    }

    function run(InterpreterState memory, OperandV2, Pointer stackTop) internal view returns (Pointer) {
        uint256 token;
        uint256 tokenId;
        assembly ("memory-safe") {
            token := mload(stackTop)
            stackTop := add(stackTop, 0x20)
            tokenId := mload(stackTop)
        }
        address tokenOwner = IERC721(address(uint160(token))).ownerOf(tokenId);
        assembly ("memory-safe") {
            mstore(stackTop, tokenOwner)
        }
        return stackTop;
    }

    function referenceFn(InterpreterState memory, OperandV2, uint256[] memory inputs)
        internal
        view
        returns (uint256[] memory)
    {
        uint256 token = inputs[0];
        uint256 tokenId = inputs[1];
        address tokenOwner = IERC721(address(uint160(token))).ownerOf(tokenId);
        uint256[] memory outputs = new uint256[](1);
        outputs[0] = uint256(uint160(tokenOwner));
        return outputs;
    }
}
