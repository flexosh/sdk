const chai = require('chai');
const path = require('path');
const wasm_tester = require('circom_tester').wasm;
const F1Field = require('ffjavascript').F1Field;
const Scalar = require('ffjavascript').Scalar;

const p = Scalar.fromString('21888242871839275222246405745257275088548364400416034343698204186575808495617');
const Fr = new F1Field(p);

describe('Wave Circuits Test Suite', function() {
    this.timeout(100000);

    describe('Base Flow Circuit', () => {
        let circuit;

        before(async () => {
            circuit = await wasm_tester(path.join(__dirname, 'circuits', 'base', 'base_flow.circom'));
        });

        it('should generate valid proof for correct inputs', async () => {
            const input = {
                flowId: '123456789',
                nullifier: '987654321',
                identity: '456789123'
            };

            const witness = await circuit.calculateWitness(input);
            await circuit.checkConstraints(witness);
        });
    });

    describe('Identity Hash Circuit', () => {
        let circuit;

        before(async () => {
            circuit = await wasm_tester(path.join(__dirname, 'circuits', 'auth', 'identity_hash.circom'));
        });

        it('should generate correct commitment', async () => {
            const input = {
                preImage: ['1', '2', '3', '4']
            };

            const witness = await circuit.calculateWitness(input);
            await circuit.checkConstraints(witness);
        });
    });

    describe('Account Shield Circuit', () => {
        let circuit;

        before(async () => {
            circuit = await wasm_tester(path.join(__dirname, 'circuits', 'templates', 'cloud_flow_template.circom'));
        });

        it('should validate private transfer', async () => {
            const input = {
                oldStateRoot: '123456789',
                newStateRoot: '987654321',
                nullifierHash: '456789123',
                privateState: ['1', '2', '3', '4'],
                stateBlinding: '123456',
                merklePathElements: Array(20).fill('1')
            };

            const witness = await circuit.calculateWitness(input);
            await circuit.checkConstraints(witness);
        });
    });
}); 