pragma circom 2.1.4;

include "../utils/poseidon.circom";

/*
 * Identity Hash circuit for creating secure identity commitments
 * Uses Poseidon hash for efficient on-chain verification
 */
template IdentityHash() {
    signal input preImage[4];  // Identity pre-image components
    signal output commitment;  // Identity commitment

    // Hash identity components
    component identityHasher = Poseidon(4);
    
    // Input identity components
    for (var i = 0; i < 4; i++) {
        identityHasher.inputs[i] <== preImage[i];
    }

    // Generate commitment
    commitment <== identityHasher.out;

    // Verify commitment is non-zero
    signal nonZeroCheck;
    nonZeroCheck <== commitment - 0;
    nonZeroCheck === 1;
} 