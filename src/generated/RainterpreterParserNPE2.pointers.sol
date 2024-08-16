// THIS FILE IS AUTOGENERATED BY ./script/BuildPointers.sol

// This file is committed to the repository because there is a circular
// dependency between the contract and its pointers file. The contract
// needs the pointers file to exist so that it can compile, and the pointers
// file needs the contract to exist so that it can be compiled.

// SPDX-License-Identifier: CAL
pragma solidity =0.8.25;

/// @dev Hash of the known bytecode.
bytes32 constant BYTECODE_HASH = bytes32(0x11aba6006d98ab79c4372ab4f0d673880a1efc51f9c1f901f06e706029c052d7);

/// @dev The parse meta that is used to lookup word definitions.
/// The structure of the parse meta is:
/// - 1 byte: The depth of the bloom filters
/// - 1 byte: The hashing seed
/// - The bloom filters, each is 32 bytes long, one for each build depth.
/// - All the items for each word, each is 4 bytes long. Each item's first byte
///   is its opcode index, the remaining 3 bytes are the word fingerprint.
/// To do a lookup, the word is hashed with the seed, then the first byte of the
/// hash is compared against the bloom filter. If there is a hit then we count
/// the number of 1 bits in the bloom filter up to this item's 1 bit. We then
/// treat this a the index of the item in the items array. We then compare the
/// word fingerprint against the fingerprint of the item at this index. If the
/// fingerprints equal then we have a match, else we increment the seed and try
/// again with the next bloom filter, offsetting all the indexes by the total
/// bit count of the previous bloom filter. If we reach the end of the bloom
/// filters then we have a miss.
bytes constant PARSE_META =
    hex"010200000000800008000300082000000000900000402000a004000a00020a000000014832da0d028f7805527c9b0776a0de0988ed9c040b9b8a03903325117a837c00ba92eb0b7c28ea084e315a0c4f390206be54af0ffa93c7104b03a802a9c1290e858ded0aa744f9";

/// @dev The build depth of the parser meta.

uint8 constant PARSE_META_BUILD_DEPTH = 2;

/// @dev Every two bytes is a function pointer for an operand handler.
/// These positional indexes all map to the same indexes looked up in the parse
/// meta.
bytes constant OPERAND_HANDLER_FUNCTION_POINTERS =
    hex"13ef13ef13ef145414cd14cd14cd1454145413ef13ef13ef14cd14cd14cd14cd14cd14cd";

/// @dev Every two bytes is a function pointer for a literal parser.
/// Literal dispatches are determined by the first byte(s) of the literal
/// rather than a full word lookup, and are done with simple conditional
/// jumps as the possibilities are limited compared to the number of words we
/// have.
bytes constant LITERAL_PARSER_FUNCTION_POINTERS = hex"0dab1073112411fe";
