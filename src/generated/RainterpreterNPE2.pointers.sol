// THIS FILE IS AUTOGENERATED BY ./script/BuildPointers.sol

// This file is committed to the repository because there is a circular
// dependency between the interpreter and the pointers file. The interpreter
// needs the pointers file to exist so that it can compile, and the pointers
// file needs the interpreter to exist so that it can be compiled.

// SPDX-License-Identifier: CAL
pragma solidity =0.8.25;

/// @dev Hash of the known interpreter bytecode.
bytes32 constant INTERPRETER_BYTECODE_HASH = bytes32(0x082edcc97843fd74ff6dc51867110b8633b0e419bac46f53765f5a833f36d024);

/// @dev The function pointers known to the interpreter for dynamic dispatch.
/// By setting these as a constant they can be inlined into the interpreter
/// and loaded at eval time for very low gas (~100) due to the compiler
/// optimising it to a single `codecopy` to build the in memory bytes array.
bytes constant OPCODE_FUNCTION_POINTERS = hex"0e060e570e991065114c115e1170119311d512271238124912eb132813e6149613e6151a15bc1634166d16a616f5172e1793186718ba18ce1927193b1950196a19751989199e19d619fd1a7d1acb1b191b671b7f1b981be61bf41c021c1d1c321c4a1c631c711c7f1c8d1c9b1ce91d371d851dd31deb1deb1e021e301e301e471e761ecb1ed91ed91f7d2064";
