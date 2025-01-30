// SPDX-License-Identifier: CAL
pragma solidity ^0.8.25;

import {OperandV2} from "rain.interpreter.interface/interface/unstable/IInterpreterV4.sol";
import {LibSubParse} from "../../../parse/LibSubParse.sol";
import {IInterpreterExternV4, StackItem} from "rain.interpreter.interface/interface/unstable/IInterpreterExternV4.sol";
import {LibDecimalFloat, PackedFloat} from "rain.math.float/lib/LibDecimalFloat.sol";

/// @dev Opcode index of the extern increment opcode. Needs to be manually kept
/// in sync with the extern opcode function pointers. Definitely write tests for
/// this to ensure a mismatch doesn't happen silently.
uint256 constant OP_INDEX_INCREMENT = 0;

/// @title LibExternOpIntIncNPE2
/// This op is a simple increment of every input by 1. It is used to demonstrate
/// handling both multiple inputs and outputs in extern dispatching logic.
library LibExternOpIntIncNPE2 {
    /// Running the extern increments every input by 1. By allowing many inputs
    /// we can test multi input/output logic is implemented correctly for
    /// externs.
    //slither-disable-next-line dead-code
    function run(OperandV2, StackItem[] memory inputs) internal pure returns (StackItem[] memory) {
        for (uint256 i = 0; i < inputs.length; i++) {
            (int256 signedCoefficient, int256 exponent) =
                LibDecimalFloat.unpack(PackedFloat.wrap(StackItem.unwrap(inputs[i])));
            (signedCoefficient, exponent) = LibDecimalFloat.add(signedCoefficient, exponent, 1e37, -37);
            inputs[i] = StackItem.wrap(PackedFloat.unwrap(LibDecimalFloat.pack(signedCoefficient, exponent)));
        }
        return inputs;
    }

    /// The integrity check for the extern increment opcode. The inputs and
    /// outputs are the same always.
    //slither-disable-next-line dead-code
    function integrity(OperandV2, uint256 inputs, uint256) internal pure returns (uint256, uint256) {
        return (inputs, inputs);
    }

    /// The sub parser for the extern increment opcode. It has no special logic
    /// so uses the default sub parser from `LibSubParse`.
    //slither-disable-next-line dead-code
    function subParser(uint256 constantsHeight, uint256 ioByte, OperandV2 operand)
        internal
        view
        returns (bool, bytes memory, bytes32[] memory)
    {
        //slither-disable-next-line unused-return
        return LibSubParse.subParserExtern(
            IInterpreterExternV4(address(this)), constantsHeight, ioByte, operand, OP_INDEX_INCREMENT
        );
    }
}
