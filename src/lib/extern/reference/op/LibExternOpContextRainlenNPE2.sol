// SPDX-License-Identifier: CAL
pragma solidity ^0.8.25;

import {OperandV2} from "rain.interpreter.interface/interface/unstable/IInterpreterV4.sol";
import {LibSubParse} from "../../../parse/LibSubParse.sol";
import {IInterpreterExternV3} from "rain.interpreter.interface/interface/IInterpreterExternV3.sol";

uint256 constant CONTEXT_CALLER_CONTEXT_COLUMN = 1;
uint256 constant CONTEXT_CALLER_CONTEXT_ROW_RAINLEN = 0;

/// @title LibExternOpContextRainlenNPE2
/// This op is a simple reference to the length of the rainlang bytes. It is
/// used to demonstrate how to implement context references.
library LibExternOpContextRainlenNPE2 {
    /// The sub parser for the extern increment opcode. It has no special logic
    /// so uses the default sub parser from `LibSubParse`.
    //slither-disable-next-line dead-code
    function subParser(uint256, uint256, OperandV2) internal pure returns (bool, bytes memory, bytes32[] memory) {
        //slither-disable-next-line unused-return
        return LibSubParse.subParserContext(CONTEXT_CALLER_CONTEXT_COLUMN, CONTEXT_CALLER_CONTEXT_ROW_RAINLEN);
    }
}
