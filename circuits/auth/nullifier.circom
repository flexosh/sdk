pragma circom 2.1.4;

include "../utils/poseidon.circom";

/*
 * Nullifier circuit to prevent double-spending in Wave flows
 * Generates a unique nullifier based on identity and flow parameters
 */
template NullifierHash() {
    signal input identity;
    signal input flowNonce;
    signal input timestamp;
    signal output nullifier;

    // Create nullifier using Poseidon hash
    component nullifierHasher = Poseidon(3);
    nullifierHasher.inputs[0] <== identity;
    nullifierHasher.inputs[1] <== flowNonce;
    nullifierHasher.inputs[2] <== timestamp;

    // Output the nullifier hash
    nullifier <== nullifierHasher.out;

    // Add range checks
    signal timestampValid;
    timestampValid <== timestamp;
    component rangeCheck = Num2Bits(64);
    rangeCheck.in <== timestampValid;
} 