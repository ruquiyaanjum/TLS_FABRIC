"""
Blockchain Cryptographic Performance Simulation

This script compares the performance of different cryptographic signature algorithms:
- ECDSA (Elliptic Curve Digital Signature Algorithm) - Traditional cryptography
- ML-DSA-44, ML-DSA-65, ML-DSA-87 - Post-Quantum Cryptography algorithms
"""

import time
import json
import hashlib
import random
import os
from datetime import datetime
from statistics import mean
from cryptography.hazmat.primitives.asymmetric import ec
from cryptography.hazmat.primitives import hashes, serialization
from pqcrypto.sign import ml_dsa_44, ml_dsa_65, ml_dsa_87

TX_PER_BLOCK = 100
TOTAL_BLOCKS = 5

def serialize_tx(tx):
    return json.dumps(tx, sort_keys=True).encode()

def hash_data(data):
    return hashlib.sha256(data).digest()

def generate_ecdsa_keys():
    sk = ec.generate_private_key(ec.SECP256R1())
    pk = sk.public_key()
    return sk, pk

def generate_mldsa_keys(mod):
    pk, sk = mod.generate_keypair()
    return sk, pk

def sign_ecdsa(sk, msg):
    return sk.sign(msg, ec.ECDSA(hashes.SHA256()))

def verify_ecdsa(pk, msg, sig):
    pk.verify(sig, msg, ec.ECDSA(hashes.SHA256()))

def run_simulation(alg_name, sign_mod=None):
    sign_times, verify_times, tx_latencies, block_times, block_sizes = [], [], [], [], []

    if alg_name == "ECDSA":
        sk, pk = generate_ecdsa_keys()
    else:
        sk, pk = generate_mldsa_keys(sign_mod)

    all_transactions = []

    for blk in range(TOTAL_BLOCKS):
        transactions = []
        block_start = time.perf_counter()

        for i in range(TX_PER_BLOCK):
            created_at = time.perf_counter()
            tx_data = {
                "from": f"user{i%10}",
                "to": f"user{(i+1)%10}",
                "amount": random.randint(1, 100),
                "txid": f"tx-{blk}-{i}"
            }
            tx_bytes = serialize_tx(tx_data)
            msg_hash = hash_data(tx_bytes)

            # Sign
            sign_start = time.perf_counter()
            if alg_name == "ECDSA":
                signature = sign_ecdsa(sk, msg_hash)
            else:
                signature = sign_mod.sign(sk, msg_hash)
            sign_end = time.perf_counter()
            sign_times.append(sign_end - sign_start)

            # Verify
            verify_start = time.perf_counter()
            if alg_name == "ECDSA":
                verify_ecdsa(pk, msg_hash, signature)
            else:
                assert sign_mod.verify(pk, msg_hash, signature)
            verify_end = time.perf_counter()
            verify_times.append(verify_end - verify_start)

            included_at = time.perf_counter()
            latency = included_at - created_at
            tx_latencies.append(latency)

            tx_data["signature"] = signature.hex()
            tx_data["public_key"] = pk.hex() if isinstance(pk, bytes) else pk.public_bytes(
                serialization.Encoding.DER,
                serialization.PublicFormat.SubjectPublicKeyInfo
            ).hex()
            transactions.append(tx_data)

        block = {
            "version": 1,
            "prev_hash": "00"*32,
            "timestamp": int(time.time()),
            "transactions": transactions,
            "height": blk
        }

        block_serialized = json.dumps(block, sort_keys=True).encode()
        block_hash = hashlib.sha256(block_serialized).digest()
        block_sizes.append(len(block_serialized))

        if alg_name == "ECDSA":
            _ = sign_ecdsa(sk, block_hash)
        else:
            _ = sign_mod.sign(sk, block_hash)

        block_end = time.perf_counter()
        block_times.append(block_end - block_start)

    total_tx = TX_PER_BLOCK * TOTAL_BLOCKS
    total_time = sum(block_times)
    tps = total_tx / total_time

    return {
        "algorithm": alg_name,
        "tps": tps,
        "avg_sign_time_ms": mean(sign_times) * 1000,
        "avg_verify_time_ms": mean(verify_times) * 1000,
        "avg_latency_ms": mean(tx_latencies) * 1000,
        "avg_block_time_ms": mean(block_times) * 1000,
        "avg_block_size_bytes": mean(block_sizes)
    }

def print_results(result):
    print(f"\n--- {result['algorithm']} ---")
    print(f"TPS                    : {result['tps']:.2f}")
    print(f"Avg Sign Time          : {result['avg_sign_time_ms']:.3f} ms")
    print(f"Avg Verify Time        : {result['avg_verify_time_ms']:.3f} ms")
    print(f"Avg Tx Latency         : {result['avg_latency_ms']:.3f} ms")
    print(f"Avg Block Time         : {result['avg_block_time_ms']:.3f} ms")
    print(f"Avg Block Size         : {result['avg_block_size_bytes']:.1f} bytes")

def save_results_to_json(sequential_results, parallel_results, filename_prefix="blockchain_tps"):
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    filename = f"{filename_prefix}_{timestamp}.json"
    
    # Create results directory if it doesn't exist
    results_dir = "results"
    if not os.path.exists(results_dir):
        os.makedirs(results_dir)
    
    filepath = os.path.join(results_dir, filename)
    
    # Prepare data for JSON serialization
    json_data = {
        "simulation_info": {
            "timestamp": datetime.now().isoformat(),
            "tx_per_block": TX_PER_BLOCK,
            "total_blocks": TOTAL_BLOCKS,
            "total_transactions": TX_PER_BLOCK * TOTAL_BLOCKS,
            "simulation_types": ["sequential", "parallel"]
        },
        "sequential_results": sequential_results,
        "parallel_results": parallel_results
    }
    
    with open(filepath, 'w') as f:
        json.dump(json_data, f, indent=2)
    
    print(f"\nResults saved to: {filepath}")
    return filepath

def run_sequential_simulation():
    """Run sequential simulation and return results"""
    print("Starting Sequential Simulation")
    print("=" * 50)
    
    results = []
    results.append(run_simulation("ECDSA"))
    results.append(run_simulation("ML-DSA-44", ml_dsa_44))
    results.append(run_simulation("ML-DSA-65", ml_dsa_65))
    results.append(run_simulation("ML-DSA-87", ml_dsa_87))

    # Print results to console
    for res in results:
        print_results(res)
    
    return results

def run_parallel_simulation():
    """Run parallel simulation and return results"""
    print("\nStarting Parallel Simulation")
    print("=" * 50)
    
    # Import parallel simulation functions
    from concurrent.futures import ThreadPoolExecutor
    
    def simulate_transaction(tx_index, sk, pk, alg_name, sign_mod):
        tx_data = {
            "from": f"user{tx_index % 10}",
            "to": f"user{(tx_index + 1) % 10}",
            "amount": random.randint(1, 100),
            "txid": f"tx-{tx_index}"
        }

        tx_bytes = json.dumps(tx_data, sort_keys=True).encode()
        msg_hash = hashlib.sha256(tx_bytes).digest()

        # Signing
        sign_start = time.perf_counter()
        if alg_name == "ECDSA":
            signature = sk.sign(msg_hash, ec.ECDSA(hashes.SHA256()))
        else:
            signature = sign_mod.sign(sk, msg_hash)
        sign_end = time.perf_counter()
        sign_time = sign_end - sign_start

        # Simulate Endorser Verification
        verify_times = []
        NUM_ENDORSERS = 4
        for _ in range(NUM_ENDORSERS):
            verify_start = time.perf_counter()
            if alg_name == "ECDSA":
                pk.verify(signature, msg_hash, ec.ECDSA(hashes.SHA256()))
            else:
                assert sign_mod.verify(pk, msg_hash, signature)
            verify_end = time.perf_counter()
            verify_times.append(verify_end - verify_start)

        tx_data["signature"] = signature.hex()
        tx_data["public_key"] = (
            pk.public_bytes(
                serialization.Encoding.DER,
                serialization.PublicFormat.SubjectPublicKeyInfo
            ).hex()
            if alg_name == "ECDSA"
            else pk.hex()
        )

        return {
            "tx": tx_data,
            "sign_time": sign_time,
            "verify_time": mean(verify_times),
            "tx_latency": sign_time + mean(verify_times)
        }

    def run_parallel_sim(alg_name, sign_mod=None):
        sign_times, verify_times, tx_latencies, block_times, block_sizes = [], [], [], [], []

        if alg_name == "ECDSA":
            sk, pk = generate_ecdsa_keys()
        else:
            sk, pk = generate_mldsa_keys(sign_mod)

        total_tx_index = 0

        for blk in range(TOTAL_BLOCKS):
            block_start = time.perf_counter()

            with ThreadPoolExecutor(max_workers=TX_PER_BLOCK) as executor:
                futures = []
                for _ in range(TX_PER_BLOCK):
                    futures.append(
                        executor.submit(simulate_transaction, total_tx_index, sk, pk, alg_name, sign_mod)
                    )
                    total_tx_index += 1

                tx_results = [f.result() for f in futures]

            transactions = [r["tx"] for r in tx_results]
            sign_times += [r["sign_time"] for r in tx_results]
            verify_times += [r["verify_time"] for r in tx_results]
            tx_latencies += [r["tx_latency"] for r in tx_results]

            # Block Assembly
            block = {
                "version": 1,
                "height": blk,
                "timestamp": int(time.time()),
                "transactions": transactions,
                "prev_hash": "00" * 32
            }

            block_bytes = json.dumps(block, sort_keys=True).encode()
            block_hash = hashlib.sha256(block_bytes).digest()
            block_sizes.append(len(block_bytes))

            # Block Signing
            if alg_name == "ECDSA":
                _ = sk.sign(block_hash, ec.ECDSA(hashes.SHA256()))
            else:
                _ = sign_mod.sign(sk, block_hash)

            block_end = time.perf_counter()
            block_times.append(block_end - block_start)

        total_tx = TX_PER_BLOCK * TOTAL_BLOCKS
        tps = total_tx / sum(block_times)

        return {
            "algorithm": alg_name,
            "tps": tps,
            "avg_sign_time_ms": mean(sign_times) * 1000,
            "avg_verify_time_ms": mean(verify_times) * 1000,
            "avg_tx_latency_ms": mean(tx_latencies) * 1000,
            "avg_block_time_ms": mean(block_times) * 1000,
            "avg_block_size_bytes": mean(block_sizes)
        }

    def print_parallel_results(result):
        print(f"\n=== {result['algorithm']} ===")
        print(f"TPS                     : {result['tps']:.2f}")
        print(f"Avg Sign Time           : {result['avg_sign_time_ms']:.2f} ms")
        print(f"Avg Verify Time         : {result['avg_verify_time_ms']:.2f} ms")
        print(f"Avg Tx Latency          : {result['avg_tx_latency_ms']:.2f} ms")
        print(f"Avg Block Generation    : {result['avg_block_time_ms']:.2f} ms")
        print(f"Avg Block Size          : {result['avg_block_size_bytes']:.1f} bytes")

    results = []
    results.append(run_parallel_sim("ECDSA"))
    results.append(run_parallel_sim("ML-DSA-44", ml_dsa_44))
    results.append(run_parallel_sim("ML-DSA-65", ml_dsa_65))
    results.append(run_parallel_sim("ML-DSA-87", ml_dsa_87))

    # Print results to console
    for res in results:
        print_parallel_results(res)
    
    return results

def main():
    print("Starting Blockchain Cryptographic Performance Simulation")
    print("=" * 70)
    print("NOTE: Results will be automatically saved to JSON file")
    print("=" * 70)
    
    # Run sequential simulation
    sequential_results = run_sequential_simulation()
    
    # Run parallel simulation
    parallel_results = run_parallel_simulation()
    
    # Save all results to JSON file
    json_file = save_results_to_json(sequential_results, parallel_results)
    print(f"\nAll simulations completed! Check '{json_file}' for detailed results.")

if __name__ == "__main__":
    main()
