.PHONY: all clean test build prove setup

CIRCUITS_DIR = circuits
BUILD_DIR = build
PHASE1_FILE = build/pot12_0000.ptau
CIRCUIT_FILES = $(wildcard $(CIRCUITS_DIR)/**/*.circom)

all: build test

# Download or generate Powers of Tau parameters
setup:
	@mkdir -p $(BUILD_DIR)
	@if [ ! -f $(PHASE1_FILE) ]; then \
		echo "Downloading Powers of Tau parameters..."; \
		curl -o $(PHASE1_FILE) https://hermez.s3-eu-west-1.amazonaws.com/powersOfTau28_hez_final_12.ptau; \
	fi

# Build all circuits
build: setup
	@echo "Building circuits..."
	@./scripts/compile.sh

# Run circuit tests
test:
	@echo "Running tests..."
	@npm test

# Generate proofs
prove:
	@echo "Generating proofs..."
	@./scripts/prove.sh

# Clean build artifacts
clean:
	@echo "Cleaning build artifacts..."
	@rm -rf $(BUILD_DIR)
	@rm -f *.r1cs
	@rm -f *.sym
	@rm -f *.wasm
	@rm -f *.zkey
	@rm -f *.wtns
	@rm -f *.json

# Generate circuit parameters
params:
	@echo "Generating circuit parameters..."
	@npm run generate-params

# Install dependencies
install:
	@echo "Installing dependencies..."
	@npm install

# Help command
help:
	@echo "Available commands:"
	@echo "  make setup    - Download or generate Powers of Tau parameters"
	@echo "  make build    - Build all circuits"
	@echo "  make test     - Run circuit tests"
	@echo "  make prove    - Generate proofs"
	@echo "  make clean    - Clean build artifacts"
	@echo "  make params   - Generate circuit parameters"
	@echo "  make install  - Install dependencies"
	@echo "  make all      - Build and test all circuits" 