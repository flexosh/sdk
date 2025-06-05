# Wave Circuits

Zero-knowledge circuit library designed for privacy-preserving applications on Solana Virtual Machine (SVM). Wave Circuits enables developers to build confidential smart contracts and private transactions while leveraging Solana's high performance and low fees.

## Overview

Wave Circuits provides the cryptographic foundation for privacy features in the Wave Protocol, a Solana fork focused on confidential computing. The library implements optimized zero-knowledge circuits that integrate seamlessly with Solana programs, allowing developers to add privacy features to their dApps while maintaining Solana's performance characteristics.

## Key Features

- **Solana Program Integration**: Native compatibility with Solana programs and the SVM instruction set
- **Optimized for Solana**: Circuit verification designed for Solana's parallel transaction processing
- **Privacy Primitives**: Core building blocks for confidential transactions and private state
- **Account Privacy**: Shield account balances and transaction history
- **Composable Logic**: Build complex private programs from simple components

## Circuit Components

### State Transition Circuit

Core circuit for private state updates in Solana programs:

```circom
template StateTransition() {
    // Public inputs
    signal input oldStateRoot;
    signal input newStateRoot;
    signal input nullifierHash;
    
    // Private inputs
    signal input privateState[4];
    signal input stateBlinding;
    signal input merklePathElements[20];
    
    // State commitment verification
    component stateHasher = Poseidon(5);
    stateHasher.inputs[0] <== privateState[0];
    stateHasher.inputs[1] <== privateState[1];
    stateHasher.inputs[2] <== privateState[2];
    stateHasher.inputs[3] <== privateState[3];
    stateHasher.inputs[4] <== stateBlinding;
    
    // Verify inclusion in old state tree
    component merkleVerifier = MerkleInclusion(20);
    merkleVerifier.leaf <== stateHasher.out;
    merkleVerifier.root <== oldStateRoot;
    merkleVerifier.pathElements <== merklePathElements;
}
```

### Account Shield Circuit

Enables private account operations on Solana:

```circom
template AccountShield() {
    // Public inputs
    signal input publicAmount;
    signal input commitment;
    
    // Private inputs
    signal input privateBalance;
    signal input blinding;
    signal input spendingKey;
    
    // Compute commitment
    component commitmentHasher = Poseidon(3);
    commitmentHasher.inputs[0] <== privateBalance;
    commitmentHasher.inputs[1] <== blinding;
    commitmentHasher.inputs[2] <== spendingKey;
    
    // Verify commitment
    commitment === commitmentHasher.out;
    
    // Range check on balance
    component rangeCheck = RangeCheck(64);
    rangeCheck.in <== privateBalance;
}
```

## Integration with Solana Programs

Example of verifying proofs in a Solana program:

```rust
use solana_program::{
    account_info::AccountInfo,
    entrypoint::ProgramResult,
    pubkey::Pubkey,
};
use wave_circuits::verify_proof;

pub fn process_private_transfer(
    program_id: &Pubkey,
    accounts: &[AccountInfo],
    proof: &[u8],
    public_inputs: &[u8],
) -> ProgramResult {
    // Verify the zero-knowledge proof
    verify_proof(proof, public_inputs)?;
    
    // Update program state
    // ... implementation ...
    
    Ok(())
}
```

## Performance on Solana

Benchmarks on Solana testnet (with 1.14.18 validator):

| Operation               | Compute Units | Time (ms) | Cost (SOL) |
|------------------------|---------------|-----------|------------|
| Proof Verification     | 150,000      | 0.8       | 0.000015   |
| State Update           | 200,000      | 1.2       | 0.000020   |
| Private Transfer       | 400,000      | 2.1       | 0.000040   |

## Development Setup

1. Install dependencies:
```bash
npm install
```

2. Build circuits and generate Solana verifier:
```bash
./scripts/build.sh
```

3. Deploy to Solana testnet:
```bash
solana program deploy target/deploy/wave_verifier.so
```

## Example: Private Transfer

```typescript
import { WaveProgram } from '@wave/sdk';
import { Connection, Keypair } from '@solana/web3.js';

async function privateTransfer() {
    const wave = new WaveProgram();
    
    // Generate proof for private transfer
    const proof = await wave.generateTransferProof({
        amount: 100,
        sender: senderKey,
        recipient: recipientAddress,
        blinding: Keypair.generate()
    });
    
    // Submit to Solana
    const tx = await wave.submitProof(proof);
    console.log(`Transaction: ${tx}`);
}
```

## Security Considerations

1. **Solana Account Model**
   - Each shielded account uses a unique Poseidon commitment
   - Account privacy relies on secure key generation
   - Supports Solana's parallel transaction execution

2. **Circuit Constraints**
   - Optimized for Solana's compute unit limits
   - Proof verification under 200k compute units
   - Compatible with Solana's block time

## License

This project is licensed under the MIT License.

## Security

This codebase is in active development and has not been audited. Use at your own risk in production environments.