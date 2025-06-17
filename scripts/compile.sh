#!/bin/bash

# Wave Circuits Compilation Script
# This script compiles all circuits and generates necessary artifacts

# Ensure we're in the project root
cd "$(dirname "$0")/.."

# Create build directory if it doesn't exist
mkdir -p build

# Function to compile a circuit
compile_circuit() {
    local circuit=$1
    local name=$(basename "$circuit" .circom)
    echo "Compiling $name..."
    
    # Compile the circuit
    circom "$circuit" --r1cs --wasm --sym --c -o build/
    
    # Generate witness generation files
    cd build/"$name"_js
    node generate_witness.js "$name".wasm ../../inputs/example_input.json witness.wtns
    cd ../..
    
    # Generate proving key
    snarkjs powersoftau new bn128 12 build/"$name"_pot12_0000.ptau -v
    snarkjs powersoftau contribute build/"$name"_pot12_0000.ptau build/"$name"_pot12_0001.ptau --name="First contribution" -v
    snarkjs powersoftau prepare phase2 build/"$name"_pot12_0001.ptau build/"$name"_pot12_final.ptau -v
    snarkjs groth16 setup build/"$name".r1cs build/"$name"_pot12_final.ptau build/"$name"_0000.zkey
    snarkjs zkey contribute build/"$name"_0000.zkey build/"$name"_0001.zkey --name="1st Contributor" -v
    snarkjs zkey export verificationkey build/"$name"_0001.zkey build/"$name"_verification_key.json
}

# Compile all circuits
for circuit in circuits/**/*.circom; do
    compile_circuit "$circuit"
done

echo "Compilation complete! Artifacts are in the build directory." 