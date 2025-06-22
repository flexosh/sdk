pragma circom 2.1.4;

include "../base/base_flow.circom";
include "../auth/nullifier.circom";
include "../auth/identity_hash.circom";
include "../gates/boolean_switch.circom";
include "../gates/constant_check.circom";
include "../merkle/merkle_inclusion.circom";

/*
 * Cloud Flow Template that combines various Wave circuit components
 * This template demonstrates how to compose different circuit components
 * for a complete flow validation
 */
template CloudFlow(merkleTreeDepth) {
    // Flow identification
    signal input flowId;
    signal input timestamp;
    
    // Identity and nullifier
    signal input identityPreImage[4];
    signal input flowNonce;
    
    // Merkle proof inputs
    signal input merklePathElements[merkleTreeDepth];
    signal input merklePathIndices[merkleTreeDepth];
    
    // Flow control
    signal input conditionValue;
    signal input conditionConstant;
    signal input conditionType;
    
    // Outputs
    signal output valid;
    signal output nullifierHash;
    signal output merkleRoot;

    // Identity verification
    component identityVerifier = IdentityHash();
    for (var i = 0; i < 4; i++) {
        identityVerifier.preImage[i] <== identityPreImage[i];
    }

    // Nullifier computation
    component nullifierGen = NullifierHash();
    nullifierGen.identity <== identityVerifier.commitment;
    nullifierGen.flowNonce <== flowNonce;
    nullifierGen.timestamp <== timestamp;
    nullifierHash <== nullifierGen.nullifier;

    // Merkle membership verification
    component merkleVerifier = MerkleInclusion(merkleTreeDepth);
    merkleVerifier.leaf <== identityVerifier.commitment;
    for (var i = 0; i < merkleTreeDepth; i++) {
        merkleVerifier.pathElements[i] <== merklePathElements[i];
        merkleVerifier.pathIndices[i] <== merklePathIndices[i];
    }
    merkleRoot <== merkleVerifier.root;

    // Condition checking
    component conditionChecker = ConstantCheck();
    conditionChecker.value <== conditionValue;
    conditionChecker.constant <== conditionConstant;
    conditionChecker.compareType <== conditionType;

    // Base flow validation
    component baseFlowCheck = BaseFlow();
    baseFlowCheck.flowId <== flowId;
    baseFlowCheck.nullifier <== nullifierGen.nullifier;
    baseFlowCheck.identity <== identityVerifier.commitment;

    // Final validation combining all checks
    component finalCheck = BooleanSwitch();
    finalCheck.in[0] <== baseFlowCheck.valid;
    finalCheck.in[1] <== conditionChecker.isValid;
    finalCheck.selector <== 0; // AND gate

    valid <== finalCheck.out;
} 