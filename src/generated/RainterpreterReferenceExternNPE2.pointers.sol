// THIS FILE IS AUTOGENERATED BY ./script/BuildPointers.sol

// This file is committed to the repository because there is a circular
// dependency between the contract and its pointers file. The contract
// needs the pointers file to exist so that it can compile, and the pointers
// file needs the contract to exist so that it can be compiled.

// SPDX-License-Identifier: CAL
pragma solidity =0.8.25;

/// @dev Hash of the known bytecode.
bytes32 constant BYTECODE_HASH = bytes32(0xd59d1011c367c6a13b88e483e9d6d8244c66154ab92191154175c0410418a2df);

/// @dev The hash of the meta that describes the contract.
bytes32 constant DESCRIBED_BY_META_HASH = bytes32(0xadf71693c6ecf3fd560904bc46973d1b6e651440d15366673f9b3984749e7c16);

/// @dev Encodes the parser meta that is used to lookup word definitions.
/// The structure of the parser meta is:
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
    hex"0100000000008000000000000000000000110000000000000020000000000000008000e438fc04aafc63025be81c0384254101285ca1";

/// @dev The build depth of the parser meta.
uint8 constant PARSE_META_BUILD_DEPTH = 1;

/// @dev Real function pointers to the sub parser functions that produce the
/// bytecode that this contract knows about. This is both constructing the extern
/// bytecode that dials back into this contract at eval time, and mapping
/// to things that happen entirely on the interpreter such as well known
/// constants and references to the context grid.
bytes constant SUB_PARSER_WORD_PARSERS = hex"076d078f079e07ae07bf";

/// @dev Every two bytes is a function pointer for an operand handler.
/// These positional indexes all map to the same indexes looked up in the parse
/// meta.
bytes constant OPERAND_HANDLER_FUNCTION_POINTERS =
    hex"0a1f0a640a1f0a1f0a1f";