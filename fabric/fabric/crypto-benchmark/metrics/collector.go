package metrics

import (
	"encoding/json"
	"fmt"
	"os"
	"path/filepath"
	"time"

	"crypto-benchmark/msp"
)

// BenchmarkResult holds the complete benchmark results for all algorithms
type BenchmarkResult struct {
	TestConfiguration TestConfig     `json:"test_configuration"`
	Results          []msp.CryptoMetrics `json:"results"`
	Summary          Summary         `json:"summary"`
	Timestamp        string          `json:"timestamp"`
}

// TestConfig holds the test configuration parameters
type TestConfig struct {
	TestMessage    string `json:"test_message"`
	Iterations     int    `json:"iterations"`
	Algorithms     []string `json:"algorithms"`
	TestDuration   string `json:"test_duration"`
}

// Summary provides statistical summary of the benchmark results
type Summary struct {
	FastestKeygen    AlgorithmStats `json:"fastest_keygen"`
	FastestSign      AlgorithmStats `json:"fastest_sign"`
	FastestVerify    AlgorithmStats `json:"fastest_verify"`
	SmallestPubKey   AlgorithmStats `json:"smallest_public_key"`
	SmallestPrivKey  AlgorithmStats `json:"smallest_private_key"`
	SmallestSig      AlgorithmStats `json:"smallest_signature"`
}

// AlgorithmStats holds statistics for a specific metric
type AlgorithmStats struct {
	Algorithm string  `json:"algorithm"`
	Value     float64 `json:"value"`
	Unit      string  `json:"unit"`
}

// MetricsCollector handles the collection and storage of benchmark metrics
type MetricsCollector struct {
	results    []msp.CryptoMetrics
	config     TestConfig
	startTime  time.Time
}

// NewMetricsCollector creates a new metrics collector
func NewMetricsCollector(testMessage string, iterations int, algorithms []string) *MetricsCollector {
	return &MetricsCollector{
		results: make([]msp.CryptoMetrics, 0),
		config: TestConfig{
			TestMessage: testMessage,
			Iterations:  iterations,
			Algorithms:  algorithms,
		},
		startTime: time.Now(),
	}
}

// AddResult adds a benchmark result to the collector
func (mc *MetricsCollector) AddResult(result msp.CryptoMetrics) {
	mc.results = append(mc.results, result)
}

// GenerateSummary creates a statistical summary of the results
func (mc *MetricsCollector) GenerateSummary() Summary {
	if len(mc.results) == 0 {
		return Summary{}
	}
	
	summary := Summary{}
	
	// Find fastest key generation
	fastestKeygen := mc.results[0]
	for _, result := range mc.results[1:] {
		if result.KeygenTimeMs < fastestKeygen.KeygenTimeMs {
			fastestKeygen = result
		}
	}
	summary.FastestKeygen = AlgorithmStats{
		Algorithm: fastestKeygen.Algorithm,
		Value:     fastestKeygen.KeygenTimeMs,
		Unit:      "ms",
	}
	
	// Find fastest signing
	fastestSign := mc.results[0]
	for _, result := range mc.results[1:] {
		if result.SignTimeMs < fastestSign.SignTimeMs {
			fastestSign = result
		}
	}
	summary.FastestSign = AlgorithmStats{
		Algorithm: fastestSign.Algorithm,
		Value:     fastestSign.SignTimeMs,
		Unit:      "ms",
	}
	
	// Find fastest verification
	fastestVerify := mc.results[0]
	for _, result := range mc.results[1:] {
		if result.VerifyTimeMs < fastestVerify.VerifyTimeMs {
			fastestVerify = result
		}
	}
	summary.FastestVerify = AlgorithmStats{
		Algorithm: fastestVerify.Algorithm,
		Value:     fastestVerify.VerifyTimeMs,
		Unit:      "ms",
	}
	
	// Find smallest public key
	smallestPubKey := mc.results[0]
	for _, result := range mc.results[1:] {
		if result.PublicKeyBytes < smallestPubKey.PublicKeyBytes {
			smallestPubKey = result
		}
	}
	summary.SmallestPubKey = AlgorithmStats{
		Algorithm: smallestPubKey.Algorithm,
		Value:     float64(smallestPubKey.PublicKeyBytes),
		Unit:      "bytes",
	}
	
	// Find smallest private key
	smallestPrivKey := mc.results[0]
	for _, result := range mc.results[1:] {
		if result.PrivateKeyBytes < smallestPrivKey.PrivateKeyBytes {
			smallestPrivKey = result
		}
	}
	summary.SmallestPrivKey = AlgorithmStats{
		Algorithm: smallestPrivKey.Algorithm,
		Value:     float64(smallestPrivKey.PrivateKeyBytes),
		Unit:      "bytes",
	}
	
	// Find smallest signature
	smallestSig := mc.results[0]
	for _, result := range mc.results[1:] {
		if result.SignatureBytes < smallestSig.SignatureBytes {
			smallestSig = result
		}
	}
	summary.SmallestSig = AlgorithmStats{
		Algorithm: smallestSig.Algorithm,
		Value:     float64(smallestSig.SignatureBytes),
		Unit:      "bytes",
	}
	
	return summary
}

// SaveResults saves the benchmark results to a JSON file
func (mc *MetricsCollector) SaveResults(filename string) error {
	mc.config.TestDuration = time.Since(mc.startTime).String()
	
	result := BenchmarkResult{
		TestConfiguration: mc.config,
		Results:          mc.results,
		Summary:          mc.GenerateSummary(),
		Timestamp:        time.Now().Format(time.RFC3339),
	}
	
	// Ensure the results directory exists
	dir := filepath.Dir(filename)
	if err := os.MkdirAll(dir, 0755); err != nil {
		return fmt.Errorf("failed to create results directory: %v", err)
	}
	
	// Marshal to JSON with pretty printing
	jsonData, err := json.MarshalIndent(result, "", "  ")
	if err != nil {
		return fmt.Errorf("failed to marshal results to JSON: %v", err)
	}
	
	// Write to file
	err = os.WriteFile(filename, jsonData, 0644)
	if err != nil {
		return fmt.Errorf("failed to write results to file: %v", err)
	}
	
	return nil
}

// GetResults returns the current results
func (mc *MetricsCollector) GetResults() []msp.CryptoMetrics {
	return mc.results
}

// PrintSummary prints a human-readable summary of the results
func (mc *MetricsCollector) PrintSummary() {
	fmt.Println("\n=== BENCHMARK SUMMARY ===")
	fmt.Printf("Test Configuration:\n")
	fmt.Printf("  Message: %s\n", mc.config.TestMessage)
	fmt.Printf("  Iterations: %d\n", mc.config.Iterations)
	fmt.Printf("  Duration: %s\n", mc.config.TestDuration)
	fmt.Printf("  Algorithms: %v\n", mc.config.Algorithms)
	
	fmt.Println("\nResults by Algorithm:")
	for _, result := range mc.results {
		fmt.Printf("\n%s:\n", result.Algorithm)
		fmt.Printf("  Key Generation: %.3f ms\n", result.KeygenTimeMs)
		fmt.Printf("  Signing: %.3f ms\n", result.SignTimeMs)
		fmt.Printf("  Verification: %.3f ms\n", result.VerifyTimeMs)
		fmt.Printf("  Public Key: %d bytes\n", result.PublicKeyBytes)
		fmt.Printf("  Private Key: %d bytes\n", result.PrivateKeyBytes)
		fmt.Printf("  Signature: %d bytes\n", result.SignatureBytes)
	}
	
	summary := mc.GenerateSummary()
	fmt.Println("\nPerformance Leaders:")
	fmt.Printf("  Fastest Key Generation: %s (%.3f ms)\n", 
		summary.FastestKeygen.Algorithm, summary.FastestKeygen.Value)
	fmt.Printf("  Fastest Signing: %s (%.3f ms)\n", 
		summary.FastestSign.Algorithm, summary.FastestSign.Value)
	fmt.Printf("  Fastest Verification: %s (%.3f ms)\n", 
		summary.FastestVerify.Algorithm, summary.FastestVerify.Value)
	fmt.Printf("  Smallest Public Key: %s (%d bytes)\n", 
		summary.SmallestPubKey.Algorithm, int(summary.SmallestPubKey.Value))
	fmt.Printf("  Smallest Private Key: %s (%d bytes)\n", 
		summary.SmallestPrivKey.Algorithm, int(summary.SmallestPrivKey.Value))
	fmt.Printf("  Smallest Signature: %s (%d bytes)\n", 
		summary.SmallestSig.Algorithm, int(summary.SmallestSig.Value))
}
