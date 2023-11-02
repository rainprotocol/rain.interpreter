// SPDX-License-Identifier: CAL
pragma solidity =0.8.19;

import {LibUint256Array} from "rain.solmem/lib/LibUint256Array.sol";
import {Test} from "forge-std/Test.sol";
import {LibWillOverflow} from "rain.math.fixedpoint/lib/LibWillOverflow.sol";
import {AggregatorV3Interface} from "rain.chainlink/interface/AggregatorV3Interface.sol";
import {LibChainlink} from "rain.chainlink/lib/LibChainlink.sol";

import {IInterpreterV2, Operand} from "src/interface/unstable/IInterpreterV2.sol";
import {LibExtern} from "src/lib/extern/LibExtern.sol";
import {RainterpreterExternNPE2} from "src/concrete/RainterpreterExternNPE2.sol";

/// @title RainterpreterExternChainlinkTest
/// Test the RainterpreterExtern implementation of the Chainlink opcode.
contract RainterpreterExternChainlinkTest is Test {
    /// Test that the Chainlink oracle price opcode works.
    function testRainterpreterExternChainlinkOraclePrice(
        uint256 currentTimestamp,
        uint256 feed,
        uint256 staleAfter,
        uint256 scalingFlags,
        uint80 roundId,
        int256 answer,
        uint256 startedAt,
        uint256 updatedAt,
        uint80 answeredInRound,
        uint8 decimals
    ) external {
        {
            vm.warp(currentTimestamp);
            answer = bound(answer, 1, type(int256).max);
            vm.assume(!LibWillOverflow.scale18WillOverflow(uint256(answer), decimals, scalingFlags));
            updatedAt = bound(updatedAt, 0, currentTimestamp);
            staleAfter = bound(staleAfter, currentTimestamp - updatedAt, type(uint256).max);
        }

        uint256 price =
            LibChainlink.roundDataToPrice(currentTimestamp, staleAfter, scalingFlags, answer, updatedAt, decimals);

        RainterpreterExternNPE2 extern = new RainterpreterExternNPE2();

        {
            vm.assume(address(uint160(feed)) != address(extern));
            vm.assume(address(uint160(feed)) != address(this));
            vm.assume(address(uint160(feed)) != address(vm));
        }

        {
            assumeNotPrecompile(address(uint160(feed)));
            vm.etch(address(uint160(feed)), hex"00");
            vm.mockCall(
                address(uint160(feed)),
                abi.encodeWithSelector(AggregatorV3Interface.latestRoundData.selector),
                abi.encode(roundId, answer, startedAt, updatedAt, answeredInRound)
            );
            vm.mockCall(
                address(uint160(feed)),
                abi.encodeWithSelector(AggregatorV3Interface.decimals.selector),
                abi.encode(decimals)
            );
        }

        uint256[] memory outputs = extern.extern(
            LibExtern.encodeExternDispatch(0, Operand.wrap(scalingFlags & type(uint16).max)),
            LibUint256Array.arrayFrom(feed, staleAfter)
        );
        assertEq(outputs.length, 1);
        assertEq(outputs[0], price);
    }
}
