pragma circom 2.1.4;

include "../utils/poseidon.circom";

/*
 * Merkle Inclusion circuit for verifying membership proofs
 * Supports Merkle trees with configurable depth
 */
template MerkleInclusion(levels) {
    signal input leaf;
    signal input pathElements[levels];
    signal input pathIndices[levels];
    signal output root;

    // Compute Merkle path
    signal computedHash[levels + 1];
    computedHash[0] <== leaf;

    // For each level
    for (var i = 0; i < levels; i++) {
        // Ensure pathIndices are binary
        pathIndices[i] * (pathIndices[i] - 1) === 0;

        // Create hasher for this level
        component levelHasher = Poseidon(2);

        // Select input order based on pathIndex
        signal leftInput;
        signal rightInput;
        leftInput <== (1 - pathIndices[i]) * computedHash[i] + pathIndices[i] * pathElements[i];
        rightInput <== pathIndices[i] * computedHash[i] + (1 - pathIndices[i]) * pathElements[i];

        // Hash the inputs
        levelHasher.inputs[0] <== leftInput;
        levelHasher.inputs[1] <== rightInput;
        computedHash[i + 1] <== levelHasher.out;
    }

    // Output the computed root
    root <== computedHash[levels];
} 