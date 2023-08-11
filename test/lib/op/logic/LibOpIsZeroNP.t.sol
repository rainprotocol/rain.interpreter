// SPDX-License-Identifier: CAL
pragma solidity =0.8.19;

import "test/util/abstract/OpTest.sol";
import "src/lib/caller/LibContext.sol";

import "rain.solmem/lib/LibUint256Array.sol";

contract LibOpIsZeroNPTest is OpTest {
    using LibUint256Array for uint256[];

    /// Directly test the integrity logic of LibOpIsZeroNP. This tests the happy
    /// path where the operand is valid. IsZero is a 1 input, 1 output op.
    function testOpIsZeroNPIntegrityHappy(IntegrityCheckStateNP memory state, uint8 inputs) external {
        (uint256 calcInputs, uint256 calcOutputs) =
            LibOpIsZeroNP.integrity(state, Operand.wrap(uint256(inputs) << 0x10));

        // The inputs from the operand are ignored. The op is always 1 input.
        assertEq(calcInputs, 1);
        assertEq(calcOutputs, 1);
    }

    /// Directly test the integrity logic of LibOpIsZeroNP. This tests the unhappy
    /// path where the operand body is non zero.
    function testOpIsZeroNPIntegrityUnhappyNonZeroBody(IntegrityCheckStateNP memory state, uint8 inputs, uint16 badOp)
        external
    {
        checkUnsupportedNonZeroOperandBody(state, inputs, badOp);
    }

    /// Directly test the runtime logic of LibOpIsZeroNP.
    function testOpIsZeroNPRun(InterpreterStateNP memory state, uint256 seed, uint256 input) external {
        uint256[] memory inputs = new uint256[](1);
        inputs[0] = input;
        Operand operand = Operand.wrap(inputs.length << 0x10);
        opReferenceCheck(
            state, seed, operand, LibOpIsZeroNP.referenceFn, LibOpIsZeroNP.integrity, LibOpIsZeroNP.run, inputs
        );
    }

    /// Test the eval of isZero opcode parsed from a string. Tests 1 nonzero input.
    function testOpIsZeroNPEval1NonZeroInput() external {
        (bytes memory bytecode, uint256[] memory constants) = iDeployer.parse("_: is-zero(30);");
        uint256[] memory minOutputs = new uint256[](1);
        minOutputs[0] = 1;
        (IInterpreterV1 interpreterDeployer, IInterpreterStoreV1 storeDeployer, address expression) =
            iDeployer.deployExpression(bytecode, constants, minOutputs);
        (uint256[] memory stack, uint256[] memory kvs) = interpreterDeployer.eval(
            storeDeployer,
            StateNamespace.wrap(0),
            LibEncodedDispatch.encode(expression, SourceIndex.wrap(0), 1),
            LibContext.build(new uint256[][](0), new SignedContextV1[](0))
        );

        assertEq(stack.length, 1);
        assertEq(stack[0], 0);
        assertEq(kvs.length, 0);
    }

    /// Test the eval of isZero opcode parsed from a string. Tests 1 zero input.
    function testOpIsZeroNPEval1ZeroInput() external {
        (bytes memory bytecode, uint256[] memory constants) = iDeployer.parse("_: is-zero(0);");
        uint256[] memory minOutputs = new uint256[](1);
        minOutputs[0] = 1;
        (IInterpreterV1 interpreterDeployer, IInterpreterStoreV1 storeDeployer, address expression) =
            iDeployer.deployExpression(bytecode, constants, minOutputs);
        (uint256[] memory stack, uint256[] memory kvs) = interpreterDeployer.eval(
            storeDeployer,
            StateNamespace.wrap(0),
            LibEncodedDispatch.encode(expression, SourceIndex.wrap(0), 1),
            LibContext.build(new uint256[][](0), new SignedContextV1[](0))
        );

        assertEq(stack.length, 1);
        assertEq(stack[0], 1);
        assertEq(kvs.length, 0);
    }
}