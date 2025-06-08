pragma circom 2.1.4;

include "../utils/poseidon.circom";

/*
 * Base Flow template that defines the core structure for Wave flows
 * Inputs:
 * - flowId: Unique identifier for the flow
 * - nullifier: Prevents double-spending
 * - identity: User's identity commitment
 */
template BaseFlow() {
    signal input flowId;
    signal input nullifier;
    signal input identity;
    signal output valid;

    // Hash the flow parameters to create a unique commitment
    component hasher = Poseidon(3);
    hasher.inputs[0] <== flowId;
    hasher.inputs[1] <== nullifier;
    hasher.inputs[2] <== identity;

    // Validate flow parameters
    signal flowValid;
    flowValid <== hasher.out;

    // Output validation result
    valid <== flowValid;
} 