// SPDX-License-Identifier: CAL
pragma solidity =0.8.25;

// import {OpTest} from "test/abstract/OpTest.sol";
// import {IntegrityCheckState} from "src/lib/integrity/LibIntegrityCheckNP.sol";
// import {OperandV2} from "rain.interpreter.interface/interface/unstable/IInterpreterV4.sol";
// import {LibOpERC20Allowance} from "src/lib/op/erc20/LibOpERC20Allowance.sol";
// import {IERC20} from "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
// import {UnexpectedOperand} from "src/error/ErrParse.sol";
// import {LibOperand} from "test/lib/operand/LibOperand.sol";
// import {IERC20Metadata} from "openzeppelin-contracts/contracts/token/ERC20/extensions/IERC20Metadata.sol";
// import {FLAG_SATURATE, LibFixedPointDecimalScale} from "rain.math.fixedpoint/lib/LibFixedPointDecimalScale.sol";

// /// @title LibOpERC20AllowanceTest
// /// @notice Test the opcode for getting the allowance of an erc20 token.
// contract LibOpERC20AllowanceTest is OpTest {
//     function testOpERC20AllowanceNPIntegrity(IntegrityCheckState memory state, Operand operand) external pure {
//         (uint256 calcInputs, uint256 calcOutputs) = LibOpERC20Allowance.integrity(state, operand);

//         assertEq(calcInputs, 3);
//         assertEq(calcOutputs, 1);
//     }

//     function testOpERC20AllowanceNPRun(address token, address owner, address spender, uint256 allowance, uint8 decimals)
//         external
//     {
//         assumeEtchable(token);
//         vm.etch(token, hex"fe");

//         uint256[] memory inputs = new uint256[](3);
//         inputs[0] = uint256(uint160(token));
//         inputs[1] = uint256(uint160(owner));
//         inputs[2] = uint256(uint160(spender));
//         Operand operand = LibOperand.build(3, 1, 0);

//         vm.mockCall(token, abi.encodeWithSelector(IERC20.allowance.selector, owner, spender), abi.encode(allowance));
//         // called once for reference, once for run
//         vm.expectCall(token, abi.encodeWithSelector(IERC20.allowance.selector, owner, spender), 2);

//         vm.mockCall(token, abi.encodeWithSelector(IERC20Metadata.decimals.selector), abi.encode(decimals));

//         opReferenceCheck(
//             opTestDefaultInterpreterState(),
//             operand,
//             LibOpERC20Allowance.referenceFn,
//             LibOpERC20Allowance.integrity,
//             LibOpERC20Allowance.run,
//             inputs
//         );
//     }

//     /// Test the eval of allowance parsed from a string.
//     function testOpERC20AllowanceNPEvalHappy(uint256 allowance, uint8 decimals) external {
//         vm.mockCall(
//             address(0xdeadbeef),
//             abi.encodeWithSelector(IERC20.allowance.selector, address(0xdeadc0de), address(0xdeaddead)),
//             abi.encode(allowance)
//         );
//         vm.mockCall(address(0xdeadbeef), abi.encodeWithSelector(IERC20Metadata.decimals.selector), abi.encode(decimals));
//         allowance = LibFixedPointDecimalScale.scale18(allowance, decimals, FLAG_SATURATE);
//         checkHappy(
//             "_: erc20-allowance(0xdeadbeef 0xdeadc0de 0xdeaddead);", allowance, "0xdeadbeef 0xdeadc0de 0xdeaddead"
//         );
//     }

//     /// Test that a allowance with bad inputs fails integrity.
//     function testOpERC20AllowanceNPEvalZeroInputs() external {
//         checkBadInputs("_: erc20-allowance();", 0, 3, 0);
//     }

//     function testOpERC20AllowanceNPEvalOneInput() external {
//         checkBadInputs("_: erc20-allowance(0xdeadbeef);", 1, 3, 1);
//     }

//     function testOpERC20AllowanceNPEvalTwoInputs() external {
//         checkBadInputs("_: erc20-allowance(0xdeadbeef 0xdeadc0de);", 2, 3, 2);
//     }

//     function testOpERC20AllowanceNPEvalFourInputs() external {
//         checkBadInputs("_: erc20-allowance(0xdeadbeef 0xdeadc0de 0xdeaddead 0xdeaddead);", 4, 3, 4);
//     }

//     function testOpERC20AllowanceNPEvalZeroOutputs() external {
//         checkBadOutputs(": erc20-allowance(0xdeadbeef 0xdeadc0de 0xdeaddead);", 3, 1, 0);
//     }

//     function testOpERC20AllowanceNPEvalTwoOutputs() external {
//         checkBadOutputs("_ _: erc20-allowance(0xdeadbeef 0xdeadc0de 0xdeaddead);", 3, 1, 2);
//     }

//     /// Test that operand is disallowed.
//     function testOpERC20AllowanceNPEvalOperandDisallowed() external {
//         checkUnhappyParse(
//             "_: erc20-allowance<0>(0xdeadbeef 0xdeadc0de 0xdeaddead);",
//             abi.encodeWithSelector(UnexpectedOperand.selector)
//         );
//     }
// }
