// SPDX-License-Identifier: CAL
pragma solidity ^0.8.25;

// import {IERC20} from "openzeppelin-contracts/contracts/interfaces/IERC20.sol";
// import {Pointer} from "rain.solmem/lib/LibPointer.sol";
// import {IntegrityCheckState} from "../../integrity/LibIntegrityCheckNP.sol";
// import {OperandV2} from "rain.interpreter.interface/interface/unstable/IInterpreterV4.sol";
// import {InterpreterState} from "../../state/LibInterpreterState.sol";
// import {IERC20Metadata} from "openzeppelin-contracts/contracts/token/ERC20/extensions/IERC20Metadata.sol";

// /// @title LibOpERC20TotalSupply
// /// @notice Opcode for ERC20 `totalSupply`.
// library LibOpERC20TotalSupply {
//     function integrity(IntegrityCheckState memory, Operand) internal pure returns (uint256, uint256) {
//         // Always 1 input, the contract.
//         // Always 1 output, the total supply.
//         return (1, 1);
//     }

//     function run(InterpreterState memory, Operand, Pointer stackTop) internal view returns (Pointer) {
//         uint256 token;
//         assembly ("memory-safe") {
//             token := mload(stackTop)
//         }
//         uint256 totalSupply = IERC20(address(uint160(token))).totalSupply();

//         uint256 tokenDecimals = IERC20Metadata(address(uint160(token))).decimals();
//         totalSupply = LibFixedPointDecimalScale.scale18(
//             totalSupply,
//             tokenDecimals,
//             // Error on overflow as total supply is a critical value.
//             // Rounding down is the default.
//             0
//         );

//         assembly ("memory-safe") {
//             mstore(stackTop, totalSupply)
//         }
//         return stackTop;
//     }

//     function referenceFn(InterpreterState memory, Operand, uint256[] memory inputs)
//         internal
//         view
//         returns (uint256[] memory)
//     {
//         uint256 account = inputs[0];
//         uint256 totalSupply = IERC20(address(uint160(account))).totalSupply();

//         uint256 tokenDecimals = IERC20Metadata(address(uint160(account))).decimals();
//         totalSupply = LibFixedPointDecimalScale.scale18(
//             totalSupply,
//             tokenDecimals,
//             // Error on overflow as total supply is a critical value.
//             // Rounding down is the default.
//             0
//         );

//         uint256[] memory outputs = new uint256[](1);
//         outputs[0] = totalSupply;
//         return outputs;
//     }
// }
