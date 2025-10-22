### 1. `main.go` - Main Application
**Purpose**: Entry point and orchestration

**Critical Functions**:
- `validateImplementation()`: 5-step validation ensuring no stub code
- `main()`: Orchestrates entire benchmark process
- Error handling: Graceful failure with detailed error messages

### 2. `msp/enhanced_msp.go` - Core Implementation
**Purpose**: Enhanced MSP supporting both ECDSA and ML-DSA

**Critical Functions**:
- `Benchmark()`: Comprehensive performance measurement
- `Sign()`/`Verify()`: Real cryptographic operations
- `generateKeyPair()`: Algorithm-specific key generation
- Timing measurement with nanosecond precision

### 3. `msp/working_mldsa.go` - ML-DSA Implementation

**Critical Functions**:
- `NewWorkingMLDSAKeyPair()`: Creates real ML-DSA key pairs
- `Sign()`/`Verify()`: Real Dilithium operations
- Key serialization methods

### 4. `metrics/collector.go` - Results Management
**Purpose**: Collection, analysis, and storage of benchmark results

**Critical Functions**:
- `GenerateSummary()`: Statistical analysis
- `SaveResults()`: JSON output with proper formatting
- `PrintSummary()`: Human-readable results

### 5. `bk_tps.py` - Blockchain Throughput Simulation Test with PQC Signatures
**Purpose**:  Simulate blockchain transactions (both sequential and paralletl) and measure throughput with PQC singatures. Stores results in `/results`.

## Timing Measurement Methodology

### High-Precision Timing Implementation
```go
// Example from enhanced_msp.go
start := time.Now()
freshMSP, err := NewEnhancedMSP(msp.algorithm)
keygenTime := time.Since(start)

// Minimum precision enforcement
if keygenTime < time.Nanosecond {
    keygenTime = time.Nanosecond
}
```

### Fresh Instance Testing
- Each operation creates new MSP instances
- Prevents caching effects and optimization artifacts
- Ensures realistic performance measurements

### Double Verification
- Runs verification twice and uses longer measurement
- Accounts for timing variability
- Ensures measurement accuracy

## Performance Results (100 iterations)

### ECDSA (P-256)
- **Key Generation**: 0.028 ms
- **Signing**: 0.057 ms
- **Verification**: 0.231 ms
- **Public Key**: 91 bytes
- **Private Key**: 121 bytes
- **Signature**: 71 bytes

### ML-DSA-44 (Dilithium2)
- **Key Generation**: 0.086 ms
- **Signing**: 0.223 ms
- **Verification**: 0.082 ms
- **Public Key**: 1,312 bytes
- **Private Key**: 2,528 bytes
- **Signature**: 2,420 bytes

### ML-DSA-65 (Dilithium3)
- **Key Generation**: 0.209 ms
- **Signing**: 0.346 ms
- **Verification**: 0.111 ms
- **Public Key**: 1,952 bytes
- **Private Key**: 4,000 bytes
- **Signature**: 3,293 bytes

### ML-DSA-87 (Dilithium5)
- **Key Generation**: 0.310 ms
- **Signing**: 0.514 ms
- **Verification**: 0.017 ms
- **Public Key**: 2,592 bytes
- **Private Key**: 4,864 bytes
- **Signature**: 4,595 bytes

## How to Run Benchmarks

### Basic Usage
```bash
# Build the benchmark (if ./benchmark does not exist)
go build -o benchmark main.go

# Run with validation 
./benchmark --iterations 100 --validate

# Simulate and test blockchain throughput
python bk_tps.py
```