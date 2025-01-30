// SPDX-License-Identifier: CAL
pragma solidity ^0.8.18;

// import {IERC20} from "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
// import {Pointer} from "rain.solmem/lib/LibPointer.sol";
// import {IntegrityCheckState} from "../../integrity/LibIntegrityCheckNP.sol";
// import {OperandV2} from "rain.interpreter.interface/interface/unstable/IInterpreterV4.sol";
// import {InterpreterState} from "../../state/LibInterpreterState.sol";
// import {IERC20Metadata} from "openzeppelin-contracts/contracts/token/ERC20/extensions/IERC20Metadata.sol";

// /// @title LibOpERC20Allowance
// /// @notice Opcode for getting the current erc20 allowance of an account.
// library LibOpERC20Allowance {
//     function integrity(IntegrityCheckState memory, Operand) internal pure returns (uint256, uint256) {
//         // Always 3 inputs, the token, the owner and the spender.
//         // Always 1 output, the allowance.
//         return (3, 1);
//     }

//     function run(InterpreterState memory, Operand, Pointer stackTop) internal view returns (Pointer) {
//         uint256 token;
//         uint256 owner;
//         uint256 spender;
//         assembly ("memory-safe") {
//             token := mload(stackTop)
//             owner := mload(add(stackTop, 0x20))
//             stackTop := add(stackTop, 0x40)
//             spender := mload(stackTop)
//         }
//         uint256 tokenAllowance =
//             IERC20(address(uint160(token))).allowance(address(uint160(owner)), address(uint160(spender)));

//         // This can fail as `decimals` is an OPTIONAL part of the ERC20 standard.
//         uint256 tokenDecimals = IERC20Metadata(address(uint160(token))).decimals();
//         tokenAllowance = LibFixedPointDecimalScale.scale18(
//             tokenAllowance,
//             tokenDecimals,
//             // Saturate scaling as "infinite approve" is a fairly common pattern
//             // so erroring would make a lot of contracts unusable in practise.
//             // Rounding down is the default.
//             FLAG_SATURATE
//         );

//         assembly ("memory-safe") {
//             mstore(stackTop, tokenAllowance)
//         }
//         return stackTop;
//     }

//     function referenceFn(InterpreterState memory, Operand, uint256[] memory inputs)
//         internal
//         view
//         returns (uint256[] memory)
//     {
//         uint256 token = inputs[0];
//         uint256 owner = inputs[1];
//         uint256 spender = inputs[2];

//         uint256 tokenDecimals = IERC20Metadata(address(uint160(token))).decimals();
//         uint256 tokenAllowance =
//             IERC20(address(uint160(token))).allowance(address(uint160(owner)), address(uint160(spender)));
//         tokenAllowance = LibFixedPointDecimalScale.scale18(tokenAllowance, tokenDecimals, FLAG_SATURATE);

//         uint256[] memory outputs = new uint256[](1);
//         outputs[0] = tokenAllowance;
//         return outputs;
//     }
// }
