package msp

import (
	"crypto/rand"
	"fmt"

	"github.com/cloudflare/circl/sign/dilithium"
)

// WorkingMLDSAKeyPair represents a working ML-DSA key pair using Cloudflare CIRCL
type WorkingMLDSAKeyPair struct {
	SecurityLevel int
	PrivateKey    dilithium.PrivateKey
	PublicKey     dilithium.PublicKey
	Mode          dilithium.Mode
}

// NewWorkingMLDSAKeyPair creates a new working ML-DSA key pair
func NewWorkingMLDSAKeyPair(securityLevel int) (*WorkingMLDSAKeyPair, error) {
	var mode dilithium.Mode

	switch securityLevel {
	case 44:
		mode = dilithium.Mode2 // ML-DSA-44 (Dilithium2)
	case 65:
		mode = dilithium.Mode3 // ML-DSA-65 (Dilithium3)
	case 87:
		mode = dilithium.Mode5 // ML-DSA-87 (Dilithium5)
	default:
		return nil, fmt.Errorf("unsupported ML-DSA security level: %d", securityLevel)
	}

	// Generate real key pair using CIRCL
	publicKey, privateKey, err := mode.GenerateKey(rand.Reader)
	if err != nil {
		return nil, fmt.Errorf("failed to generate ML-DSA key pair: %v", err)
	}

	return &WorkingMLDSAKeyPair{
		SecurityLevel: securityLevel,
		PrivateKey:    privateKey,
		PublicKey:     publicKey,
		Mode:          mode,
	}, nil
}

// Sign signs a message using the real ML-DSA implementation
func (k *WorkingMLDSAKeyPair) Sign(message []byte) []byte {
	// Use real Dilithium signing from CIRCL library
	return k.Mode.Sign(k.PrivateKey, message)
}

// Verify verifies a signature using the real ML-DSA implementation
func (k *WorkingMLDSAKeyPair) Verify(message, signature []byte) bool {
	// Use real Dilithium verification from CIRCL library
	return k.Mode.Verify(k.PublicKey, message, signature)
}

// GetPublicKeyBytes returns the public key as bytes
func (k *WorkingMLDSAKeyPair) GetPublicKeyBytes() []byte {
	return k.PublicKey.Bytes()
}

// GetPrivateKeyBytes returns the private key as bytes
func (k *WorkingMLDSAKeyPair) GetPrivateKeyBytes() []byte {
	return k.PrivateKey.Bytes()
}

// GetSignatureSize returns the signature size for the security level
func (k *WorkingMLDSAKeyPair) GetSignatureSize() int {
	return k.Mode.SignatureSize()
}

// GetPublicKeySize returns the public key size for the security level
func (k *WorkingMLDSAKeyPair) GetPublicKeySize() int {
	return k.Mode.PublicKeySize()
}

// GetPrivateKeySize returns the private key size for the security level
func (k *WorkingMLDSAKeyPair) GetPrivateKeySize() int {
	return k.Mode.PrivateKeySize()
}
