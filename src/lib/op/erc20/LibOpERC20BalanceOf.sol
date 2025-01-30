// SPDX-License-Identifier: CAL
pragma solidity ^0.8.18;

// import {IERC20} from "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
// import {Pointer} from "rain.solmem/lib/LibPointer.sol";
// import {IntegrityCheckState} from "../../integrity/LibIntegrityCheckNP.sol";
// import {OperandV2} from "rain.interpreter.interface/interface/unstable/IInterpreterV4.sol";
// import {InterpreterState} from "../../state/LibInterpreterState.sol";
// import {IERC20Metadata} from "openzeppelin-contracts/contracts/token/ERC20/extensions/IERC20Metadata.sol";

// /// @title LibOpERC20BalanceOf
// /// @notice Opcode for getting the current erc20 balance of an account.
// library LibOpERC20BalanceOf {
//     function integrity(IntegrityCheckState memory, Operand) internal pure returns (uint256, uint256) {
//         // Always 2 inputs, the token and the account.
//         // Always 1 output, the balance.
//         return (2, 1);
//     }

//     function run(InterpreterState memory, Operand, Pointer stackTop) internal view returns (Pointer) {
//         uint256 token;
//         uint256 account;
//         assembly ("memory-safe") {
//             token := mload(stackTop)
//             stackTop := add(stackTop, 0x20)
//             account := mload(stackTop)
//         }
//         uint256 tokenBalance = IERC20(address(uint160(token))).balanceOf(address(uint160(account)));

//         // This can fail as `decimals` is an OPTIONAL part of the ERC20 standard.
//         uint256 tokenDecimals = IERC20Metadata(address(uint160(token))).decimals();
//         tokenBalance = LibFixedPointDecimalScale.scale18(
//             tokenBalance,
//             tokenDecimals,
//             // Error on overflow as balance is a critical value.
//             // Rounding down is the default.
//             0
//         );

//         assembly ("memory-safe") {
//             mstore(stackTop, tokenBalance)
//         }
//         return stackTop;
//     }

//     function referenceFn(InterpreterState memory, Operand, uint256[] memory inputs)
//         internal
//         view
//         returns (uint256[] memory)
//     {
//         uint256 token = inputs[0];
//         uint256 account = inputs[1];

//         uint256 tokenBalance = IERC20(address(uint160(token))).balanceOf(address(uint160(account)));

//         uint256 tokenDecimals = IERC20Metadata(address(uint160(token))).decimals();
//         tokenBalance = LibFixedPointDecimalScale.scale18(
//             tokenBalance,
//             tokenDecimals,
//             // Error on overflow as balance is a critical value.
//             // Rounding down is the default.
//             0
//         );

//         uint256[] memory outputs = new uint256[](1);
//         outputs[0] = tokenBalance;
//         return outputs;
//     }
// }
