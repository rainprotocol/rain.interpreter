// SPDX-License-Identifier: CAL
pragma solidity =0.8.19;

import "test/util/abstract/OpTest.sol";
import "src/lib/caller/LibContext.sol";

contract LibOpGreaterThanNPTest is OpTest {
    /// Directly test the integrity logic of LibOpGreaterThanNP. No matter the
    /// operand inputs, the calc inputs must be 2, and the calc outputs must be
    /// 1.
    function testOpGreaterThanNPIntegrityHappy(IntegrityCheckStateNP memory state, uint8 inputs) external {
        (uint256 calcInputs, uint256 calcOutputs) =
            LibOpGreaterThanNP.integrity(state, Operand.wrap(uint256(inputs) << 0x10));

        // The inputs from the operand are ignored. The op is always 2 inputs.
        assertEq(calcInputs, 2);
        assertEq(calcOutputs, 1);
    }

    /// Directly test the runtime logic of LibOpGreaterThanNP.
    function testOpGreaterThanNPRun(InterpreterStateNP memory state, uint256 seed, uint256 input1, uint256 input2)
        external
    {
        uint256[] memory inputs = new uint256[](2);
        inputs[0] = input1;
        inputs[1] = input2;
        Operand operand = Operand.wrap(inputs.length << 0x10);
        opReferenceCheck(
            state,
            seed,
            operand,
            LibOpGreaterThanNP.referenceFn,
            LibOpGreaterThanNP.integrity,
            LibOpGreaterThanNP.run,
            inputs
        );
    }

    /// Test the eval of greater than opcode parsed from a string. Tests 2
    /// inputs. Both inputs are 0.
    function testOpGreaterThanNPEval2ZeroInputs() external {
        (bytes memory bytecode, uint256[] memory constants) = iDeployer.parse("_: greater-than(0 0);");
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

    /// Test the eval of greater than opcode parsed from a string. Tests 2
    /// inputs. The first input is 0, the second input is 1.
    function testOpGreaterThanNPEval2InputsFirstZeroSecondOne() external {
        (bytes memory bytecode, uint256[] memory constants) = iDeployer.parse("_: greater-than(0 1);");
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

    /// Test the eval of greater than opcode parsed from a string. Tests 2
    /// inputs. The first input is 1, the second input is 0.
    function testOpGreaterThanNPEval2InputsFirstOneSecondZero() external {
        (bytes memory bytecode, uint256[] memory constants) = iDeployer.parse("_: greater-than(1 0);");
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

    /// Test the eval of greater than opcode parsed from a string. Tests 2
    /// inputs. Both inputs are 1.
    function testOpGreaterThanNPEval2InputsBothOne() external {
        (bytes memory bytecode, uint256[] memory constants) = iDeployer.parse("_: greater-than(1 1);");
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

    /// Test that a greater than without inputs fails integrity check.
    function testOpGreaterThanNPEvalFail0Inputs() public {
        (bytes memory bytecode, uint256[] memory constants) = iDeployer.parse("_: greater-than();");
        uint256[] memory minOutputs = new uint256[](1);
        minOutputs[0] = 1;
        vm.expectRevert(abi.encodeWithSelector(BadOpInputsLength.selector, 0, 2, 0));
        iDeployer.integrityCheck(bytecode, constants, minOutputs);
    }

    /// Test that a greater than with 1 input fails integrity check.
    function testOpGreaterThanNPEvalFail1Input() public {
        (bytes memory bytecode, uint256[] memory constants) = iDeployer.parse("_: greater-than(0x00);");
        uint256[] memory minOutputs = new uint256[](1);
        minOutputs[0] = 1;
        vm.expectRevert(abi.encodeWithSelector(BadOpInputsLength.selector, 1, 2, 1));
        iDeployer.integrityCheck(bytecode, constants, minOutputs);
    }

    /// Test that a greater than with 3 inputs fails integrity check.
    function testOpGreaterThanNPEvalFail3Inputs() public {
        (bytes memory bytecode, uint256[] memory constants) = iDeployer.parse("_: greater-than(0x00 0x00 0x00);");
        uint256[] memory minOutputs = new uint256[](1);
        minOutputs[0] = 1;
        vm.expectRevert(abi.encodeWithSelector(BadOpInputsLength.selector, 3, 2, 3));
        iDeployer.integrityCheck(bytecode, constants, minOutputs);
    }
}