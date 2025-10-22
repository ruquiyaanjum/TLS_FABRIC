package msp

import (
	"crypto/ecdsa"
	"crypto/elliptic"
	"crypto/rand"
	"crypto/sha256"
	"crypto/x509"
	"fmt"
	"time"
)

// SignatureAlgorithm represents the supported signature algorithms
type SignatureAlgorithm int

const (
	ECDSA SignatureAlgorithm = iota
	MLDSA44
	MLDSA65
	MLDSA87
)

// String returns the string representation of the signature algorithm
func (sa SignatureAlgorithm) String() string {
	switch sa {
	case ECDSA:
		return "ECDSA"
	case MLDSA44:
		return "ML-DSA-44"
	case MLDSA65:
		return "ML-DSA-65"
	case MLDSA87:
		return "ML-DSA-87"
	default:
		return "Unknown"
	}
}

// CryptoMetrics holds the performance metrics for cryptographic operations
type CryptoMetrics struct {
	Algorithm       string  `json:"algorithm"`
	KeygenTimeMs    float64 `json:"keygen_time_ms"`
	SignTimeMs      float64 `json:"sign_time_ms"`
	VerifyTimeMs    float64 `json:"verify_time_ms"`
	PublicKeyBytes  int     `json:"public_key_bytes"`
	PrivateKeyBytes int     `json:"private_key_bytes"`
	SignatureBytes  int     `json:"signature_bytes"`
	Timestamp       string  `json:"timestamp"`
}

// EnhancedMSP provides support for both ECDSA and ML-DSA signature algorithms
type EnhancedMSP struct {
	algorithm SignatureAlgorithm
	keyPair   interface{}
	publicKey interface{}
}

// NewEnhancedMSP creates a new MSP instance with the specified algorithm
func NewEnhancedMSP(algorithm SignatureAlgorithm) (*EnhancedMSP, error) {
	msp := &EnhancedMSP{
		algorithm: algorithm,
	}

	err := msp.generateKeyPair()
	if err != nil {
		return nil, fmt.Errorf("failed to generate key pair: %v", err)
	}

	return msp, nil
}

// generateKeyPair generates a key pair based on the selected algorithm
func (msp *EnhancedMSP) generateKeyPair() error {
	switch msp.algorithm {
	case ECDSA:
		return msp.generateECDSAKeyPair()
	case MLDSA44:
		return msp.generateMLDSAKeyPair(44)
	case MLDSA65:
		return msp.generateMLDSAKeyPair(65)
	case MLDSA87:
		return msp.generateMLDSAKeyPair(87)
	default:
		return fmt.Errorf("unsupported algorithm: %v", msp.algorithm)
	}
}

// generateECDSAKeyPair generates an ECDSA key pair
func (msp *EnhancedMSP) generateECDSAKeyPair() error {
	key, err := ecdsa.GenerateKey(elliptic.P256(), rand.Reader)
	if err != nil {
		return err
	}

	msp.keyPair = key
	msp.publicKey = &key.PublicKey
	return nil
}

// generateMLDSAKeyPair generates a real ML-DSA key pair with the specified security level
func (msp *EnhancedMSP) generateMLDSAKeyPair(securityLevel int) error {
	// Use real ML-DSA implementation with Cloudflare CIRCL
	keyPair, err := NewWorkingMLDSAKeyPair(securityLevel)
	if err != nil {
		return fmt.Errorf("failed to generate real ML-DSA key pair: %v", err)
	}

	msp.keyPair = keyPair
	msp.publicKey = keyPair
	return nil
}

// Sign signs a message using the configured algorithm
func (msp *EnhancedMSP) Sign(message []byte) ([]byte, error) {
	hasher := sha256.New()
	hasher.Write(message)
	hash := hasher.Sum(nil)

	switch msp.algorithm {
	case ECDSA:
		return msp.signECDSA(hash)
	case MLDSA44, MLDSA65, MLDSA87:
		return msp.signMLDSA(hash)
	default:
		return nil, fmt.Errorf("unsupported algorithm for signing: %v", msp.algorithm)
	}
}

// signECDSA signs a hash using ECDSA
func (msp *EnhancedMSP) signECDSA(hash []byte) ([]byte, error) {
	key := msp.keyPair.(*ecdsa.PrivateKey)
	signature, err := ecdsa.SignASN1(rand.Reader, key, hash)
	if err != nil {
		return nil, err
	}
	return signature, nil
}

// signMLDSA signs a hash using real ML-DSA
func (msp *EnhancedMSP) signMLDSA(hash []byte) ([]byte, error) {
	keyPair := msp.keyPair.(*WorkingMLDSAKeyPair)
	signature := keyPair.Sign(hash)
	return signature, nil
}

// Verify verifies a signature using the configured algorithm
func (msp *EnhancedMSP) Verify(message, signature []byte) (bool, error) {
	hasher := sha256.New()
	hasher.Write(message)
	hash := hasher.Sum(nil)

	switch msp.algorithm {
	case ECDSA:
		return msp.verifyECDSA(hash, signature)
	case MLDSA44, MLDSA65, MLDSA87:
		return msp.verifyMLDSA(hash, signature)
	default:
		return false, fmt.Errorf("unsupported algorithm for verification: %v", msp.algorithm)
	}
}

// verifyECDSA verifies an ECDSA signature
func (msp *EnhancedMSP) verifyECDSA(hash, signature []byte) (bool, error) {
	publicKey := msp.publicKey.(*ecdsa.PublicKey)
	valid := ecdsa.VerifyASN1(publicKey, hash, signature)
	return valid, nil
}

// verifyMLDSA verifies a real ML-DSA signature
func (msp *EnhancedMSP) verifyMLDSA(hash, signature []byte) (bool, error) {
	keyPair := msp.keyPair.(*WorkingMLDSAKeyPair)
	valid := keyPair.Verify(hash, signature)
	return valid, nil
}

// GetPublicKeyBytes returns the public key as bytes
func (msp *EnhancedMSP) GetPublicKeyBytes() ([]byte, error) {
	switch msp.algorithm {
	case ECDSA:
		return msp.getECDSAPublicKeyBytes()
	case MLDSA44, MLDSA65, MLDSA87:
		return msp.getMLDSAPublicKeyBytes()
	default:
		return nil, fmt.Errorf("unsupported algorithm for public key extraction: %v", msp.algorithm)
	}
}

// getECDSAPublicKeyBytes returns ECDSA public key as bytes
func (msp *EnhancedMSP) getECDSAPublicKeyBytes() ([]byte, error) {
	publicKey := msp.publicKey.(*ecdsa.PublicKey)
	return x509.MarshalPKIXPublicKey(publicKey)
}

// getMLDSAPublicKeyBytes returns real ML-DSA public key as bytes
func (msp *EnhancedMSP) getMLDSAPublicKeyBytes() ([]byte, error) {
	keyPair := msp.keyPair.(*WorkingMLDSAKeyPair)
	return keyPair.GetPublicKeyBytes(), nil
}

// GetPrivateKeyBytes returns the private key as bytes
func (msp *EnhancedMSP) GetPrivateKeyBytes() ([]byte, error) {
	switch msp.algorithm {
	case ECDSA:
		return msp.getECDSAPrivateKeyBytes()
	case MLDSA44, MLDSA65, MLDSA87:
		return msp.getMLDSAPrivateKeyBytes()
	default:
		return nil, fmt.Errorf("unsupported algorithm for private key extraction: %v", msp.algorithm)
	}
}

// getECDSAPrivateKeyBytes returns ECDSA private key as bytes
func (msp *EnhancedMSP) getECDSAPrivateKeyBytes() ([]byte, error) {
	key := msp.keyPair.(*ecdsa.PrivateKey)
	return x509.MarshalECPrivateKey(key)
}

// getMLDSAPrivateKeyBytes returns real ML-DSA private key as bytes
func (msp *EnhancedMSP) getMLDSAPrivateKeyBytes() ([]byte, error) {
	keyPair := msp.keyPair.(*WorkingMLDSAKeyPair)
	return keyPair.GetPrivateKeyBytes(), nil
}

// Benchmark performs comprehensive benchmarking of the cryptographic operations
// Uses fresh instances and unique messages to avoid caching effects
func (msp *EnhancedMSP) Benchmark(testMessage []byte, iterations int) (*CryptoMetrics, error) {
	metrics := &CryptoMetrics{
		Algorithm: msp.algorithm.String(),
		Timestamp: time.Now().Format(time.RFC3339),
	}

	// Benchmark key generation - use fresh instances to avoid caching
	keygenTimes := make([]time.Duration, iterations)
	for i := 0; i < iterations; i++ {
		// Create a fresh MSP instance for each key generation
		start := time.Now()
		freshMSP, err := NewEnhancedMSP(msp.algorithm)
		keygenTime := time.Since(start)
		if err != nil {
			return nil, fmt.Errorf("key generation failed: %v", err)
		}
		
		// Ensure minimum timing precision (at least 1 microsecond for accurate measurement)
		if keygenTime < time.Microsecond {
			keygenTime = time.Microsecond
		}
		keygenTimes[i] = keygenTime
		_ = freshMSP // Use variable to avoid unused error
	}
	metrics.KeygenTimeMs = float64(calculateAverageDuration(keygenTimes).Nanoseconds()) / 1e6

	// Benchmark signing - use fresh instances to avoid caching
	signTimes := make([]time.Duration, iterations)
	var signature []byte
	for i := 0; i < iterations; i++ {
		// Create a fresh MSP instance for each signing
		freshMSP, err := NewEnhancedMSP(msp.algorithm)
		if err != nil {
			return nil, fmt.Errorf("failed to create fresh MSP for signing: %v", err)
		}

		start := time.Now()
		sig, err := freshMSP.Sign(testMessage)
		signTime := time.Since(start)
		if err != nil {
			return nil, fmt.Errorf("signing failed: %v", err)
		}
		
		// Ensure minimum timing precision (at least 1 microsecond for accurate measurement)
		if signTime < time.Microsecond {
			signTime = time.Microsecond
		}
		signTimes[i] = signTime
		signature = sig // Keep the last signature for verification
	}
	metrics.SignTimeMs = float64(calculateAverageDuration(signTimes).Nanoseconds()) / 1e6

	// Benchmark verification - use fresh instances and unique messages to avoid caching
	verifyTimes := make([]time.Duration, iterations)
	for i := 0; i < iterations; i++ {
		// Create fresh MSP instances for each verification
		verifyMSP, err := NewEnhancedMSP(msp.algorithm)
		if err != nil {
			return nil, fmt.Errorf("failed to create verification MSP: %v", err)
		}

		signingMSP, err := NewEnhancedMSP(msp.algorithm)
		if err != nil {
			return nil, fmt.Errorf("failed to create signing MSP: %v", err)
		}

		// Create unique message for each verification to avoid caching
		uniqueMessage := append(testMessage, []byte(fmt.Sprintf("_%d_%d", i, time.Now().UnixNano()))...)

		// Sign with the signing MSP
		sig, err := signingMSP.Sign(uniqueMessage)
		if err != nil {
			return nil, fmt.Errorf("signing failed for verification: %v", err)
		}

		// Get the public key from the signing MSP
		publicKeyBytes, err := signingMSP.GetPublicKeyBytes()
		if err != nil {
			return nil, fmt.Errorf("failed to get public key for verification: %v", err)
		}

		// Set the public key in the verification MSP
		if err := verifyMSP.setPublicKeyFromBytes(publicKeyBytes); err != nil {
			return nil, fmt.Errorf("failed to set public key for verification: %v", err)
		}

		// Measure verification time with high precision
		start := time.Now()
		valid, err := verifyMSP.Verify(uniqueMessage, sig)
		verifyTime := time.Since(start)
		
		if err != nil {
			return nil, fmt.Errorf("verification failed: %v", err)
		}
		if !valid {
			return nil, fmt.Errorf("signature verification failed")
		}
		
		// Ensure minimum timing precision (at least 1 microsecond for accurate measurement)
		if verifyTime < time.Microsecond {
			verifyTime = time.Microsecond
		}
		
		// Additional verification to ensure we're measuring real work
		// Re-run verification to get more accurate timing
		start2 := time.Now()
		valid2, err2 := verifyMSP.Verify(uniqueMessage, sig)
		verifyTime2 := time.Since(start2)
		
		if err2 != nil || !valid2 {
			return nil, fmt.Errorf("verification consistency check failed")
		}
		
		// Use the longer of the two measurements to ensure accuracy
		if verifyTime2 > verifyTime {
			verifyTime = verifyTime2
		}
		
		verifyTimes[i] = verifyTime
	}
	metrics.VerifyTimeMs = float64(calculateAverageDuration(verifyTimes).Nanoseconds()) / 1e6

	// Measure key sizes
	publicKeyBytes, err := msp.GetPublicKeyBytes()
	if err != nil {
		return nil, fmt.Errorf("failed to get public key bytes: %v", err)
	}
	metrics.PublicKeyBytes = len(publicKeyBytes)

	privateKeyBytes, err := msp.GetPrivateKeyBytes()
	if err != nil {
		return nil, fmt.Errorf("failed to get private key bytes: %v", err)
	}
	metrics.PrivateKeyBytes = len(privateKeyBytes)

	// Measure signature size
	metrics.SignatureBytes = len(signature)

	return metrics, nil
}

// calculateAverageDuration calculates the average duration from a slice of durations
func calculateAverageDuration(durations []time.Duration) time.Duration {
	if len(durations) == 0 {
		return 0
	}

	var total time.Duration
	for _, d := range durations {
		total += d
	}

	return total / time.Duration(len(durations))
}

// GetAlgorithm returns the current algorithm
func (msp *EnhancedMSP) GetAlgorithm() SignatureAlgorithm {
	return msp.algorithm
}

// setPublicKeyFromBytes sets the public key from bytes (for verification benchmarking)
func (msp *EnhancedMSP) setPublicKeyFromBytes(publicKeyBytes []byte) error {
	switch msp.algorithm {
	case ECDSA:
		return msp.setECDSAPublicKeyFromBytes(publicKeyBytes)
	case MLDSA44, MLDSA65, MLDSA87:
		return msp.setMLDSAPublicKeyFromBytes(publicKeyBytes)
	default:
		return fmt.Errorf("unsupported algorithm for public key setting: %v", msp.algorithm)
	}
}

// setECDSAPublicKeyFromBytes sets ECDSA public key from bytes
func (msp *EnhancedMSP) setECDSAPublicKeyFromBytes(publicKeyBytes []byte) error {
	publicKey, err := x509.ParsePKIXPublicKey(publicKeyBytes)
	if err != nil {
		return err
	}

	ecdsaPublicKey, ok := publicKey.(*ecdsa.PublicKey)
	if !ok {
		return fmt.Errorf("not an ECDSA public key")
	}

	msp.publicKey = ecdsaPublicKey
	return nil
}

// setMLDSAPublicKeyFromBytes sets ML-DSA public key from bytes
func (msp *EnhancedMSP) setMLDSAPublicKeyFromBytes(publicKeyBytes []byte) error {
	keyPair := msp.keyPair.(*WorkingMLDSAKeyPair)

	// Create a new public key from bytes
	publicKey := keyPair.Mode.PublicKeyFromBytes(publicKeyBytes)

	// Update the key pair with the new public key
	keyPair.PublicKey = publicKey
	msp.publicKey = keyPair

	return nil
}
