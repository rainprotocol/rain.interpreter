// SPDX-License-Identifier: CAL
pragma solidity =0.8.25;

// import {stdError} from "forge-std/Test.sol";
// import {OpTest} from "test/abstract/OpTest.sol";
// import {IntegrityCheckState} from "src/lib/integrity/LibIntegrityCheckNP.sol";
// import {OperandV2} from "rain.interpreter.interface/interface/unstable/IInterpreterV4.sol";
// import {LibOpERC20BalanceOf} from "src/lib/op/erc20/LibOpERC20BalanceOf.sol";
// import {IERC20} from "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
// import {UnexpectedOperand} from "src/error/ErrParse.sol";
// import {LibOperand} from "test/lib/operand/LibOperand.sol";
// import {LibFixedPointDecimalScale} from "rain.math.fixedpoint/lib/LibFixedPointDecimalScale.sol";
// import {IERC20Metadata} from "openzeppelin-contracts/contracts/token/ERC20/extensions/IERC20Metadata.sol";
// import {LibWillOverflow} from "rain.math.fixedpoint/lib/LibWillOverflow.sol";

// /// @title LibOpERC20BalanceOfTest
// /// @notice Test the opcode for getting the balance of an erc20 token.
// contract LibOpERC20BalanceOfTest is OpTest {
//     function testOpERC20BalanceOfNPIntegrity(IntegrityCheckState memory state, Operand operand) external pure {
//         (uint256 calcInputs, uint256 calcOutputs) = LibOpERC20BalanceOf.integrity(state, operand);

//         assertEq(calcInputs, 2);
//         assertEq(calcOutputs, 1);
//     }

//     function testOpERC20BalanceOfNPRun(
//         address token,
//         address account,
//         uint256 balance,
//         uint16 operandData,
//         uint8 decimals
//     ) external {
//         assumeEtchable(token);
//         vm.etch(token, hex"fe");

//         vm.assume(!LibWillOverflow.scale18WillOverflow(balance, decimals, 0));

//         uint256[] memory inputs = new uint256[](2);
//         inputs[0] = uint256(uint160(token));
//         inputs[1] = uint256(uint160(account));
//         Operand operand = LibOperand.build(2, 1, operandData);

//         vm.mockCall(token, abi.encodeWithSelector(IERC20.balanceOf.selector, account), abi.encode(balance));
//         // called once for reference, once for run
//         vm.expectCall(token, abi.encodeWithSelector(IERC20.balanceOf.selector, account), 2);

//         vm.mockCall(token, abi.encodeWithSelector(IERC20Metadata.decimals.selector), abi.encode(decimals));

//         opReferenceCheck(
//             opTestDefaultInterpreterState(),
//             operand,
//             LibOpERC20BalanceOf.referenceFn,
//             LibOpERC20BalanceOf.integrity,
//             LibOpERC20BalanceOf.run,
//             inputs
//         );
//     }

//     /// Test the eval of balanceOf parsed from a string.
//     function testOpERC20BalanceOfNPEvalHappy(uint256 balance, uint8 decimals) external {
//         vm.assume(!LibWillOverflow.scale18WillOverflow(balance, decimals, 0));
//         vm.mockCall(
//             address(0xdeadbeef),
//             abi.encodeWithSelector(IERC20.balanceOf.selector, address(0xdeadc0de)),
//             abi.encode(balance)
//         );
//         vm.mockCall(address(0xdeadbeef), abi.encodeWithSelector(IERC20Metadata.decimals.selector), abi.encode(decimals));
//         balance = LibFixedPointDecimalScale.scale18(balance, decimals, 0);
//         checkHappy("_: erc20-balance-of(0xdeadbeef 0xdeadc0de);", balance, "0xdeadbeef 0xdeadc0de");
//     }

//     /// Test overflow errors when rescaling.
//     function testOpERC20BalanceOfNPEvalOverflow(uint256 balance, uint8 decimals) external {
//         vm.assume(LibWillOverflow.scale18WillOverflow(balance, decimals, 0));
//         vm.mockCall(
//             address(0xdeadbeef),
//             abi.encodeWithSelector(IERC20.balanceOf.selector, address(0xdeadc0de)),
//             abi.encode(balance)
//         );
//         vm.mockCall(address(0xdeadbeef), abi.encodeWithSelector(IERC20Metadata.decimals.selector), abi.encode(decimals));
//         checkUnhappy("_: erc20-balance-of(0xdeadbeef 0xdeadc0de);", stdError.arithmeticError);
//     }

//     /// Test that a balanceOf with bad inputs fails integrity.
//     function testOpERC20BalanceOfNPEvalZeroInputs() external {
//         checkBadInputs("_: erc20-balance-of();", 0, 2, 0);
//     }

//     function testOpERC20BalanceOfNPEvalOneInput() external {
//         checkBadInputs("_: erc20-balance-of(0xdeadbeef);", 1, 2, 1);
//     }

//     function testOpERC20BalanceOfNPEvalThreeInputs() external {
//         checkBadInputs("_: erc20-balance-of(0xdeadbeef 0xdeadc0de 0xdeadc0de);", 3, 2, 3);
//     }

//     function testOpERC20BalanceOfNPEvalZeroOutputs() external {
//         checkBadOutputs(": erc20-balance-of(0xdeadbeef 0xdeadc0de);", 2, 1, 0);
//     }

//     function testOpERC20BalanceOfNPEvalTwoOutputs() external {
//         checkBadOutputs("_ _: erc20-balance-of(0xdeadbeef 0xdeadc0de);", 2, 1, 2);
//     }

//     /// Test that operand is disallowed.
//     function testOpERC20BalanceOfNPEvalOperandDisallowed() external {
//         checkUnhappyParse(
//             "_: erc20-balance-of<0>(0xdeadbeef 0xdeadc0de);", abi.encodeWithSelector(UnexpectedOperand.selector)
//         );
//     }
// }
