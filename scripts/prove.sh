#!/bin/bash

# Wave Circuits Proving Script
# This script generates and verifies proofs for compiled circuits

# Ensure we're in the project root
cd "$(dirname "$0")/.."

# Function to generate and verify proof
generate_proof() {
    local circuit=$1
    local name=$(basename "$circuit" .circom)
    echo "Generating proof for $name..."
    
    cd build
    
    # Generate proof
    snarkjs groth16 prove "$name"_0001.zkey "$name"_js/witness.wtns proof.json public.json
    
    # Verify proof
    snarkjs groth16 verify "$name"_verification_key.json public.json proof.json
    
    # Generate Solidity verifier
    snarkjs zkey export solidityverifier "$name"_0001.zkey "$name"_verifier.sol
    
    # Generate and verify call data
    snarkjs zkey export soliditycalldata public.json proof.json > "$name"_calldata.txt
    
    cd ..
    
    echo "Proof generation and verification complete for $name!"
    echo "Verifier contract and calldata are in the build directory."
}

# Check if specific circuit is provided
if [ $# -eq 1 ]; then
    generate_proof "$1"
else
    # Generate proofs for all circuits
    for circuit in circuits/**/*.circom; do
        generate_proof "$circuit"
    done
fi 