#!/bin/bash

# --- CONFIG ---
BESU_RPC="http://127.0.0.1:8546"   # Besu RPC endpoint
PEER_IDS=(
  "2035ca3e9aaed436a565210289224559ddc47cc721ba1f323150354a0e5bce15472749a4a8bdf257b599a510bc3b495e8c955ce81570756086599f3f3ef0bd1b"
)

WAIT=1       
TIMEOUT=5    # Max wait for handshake completion (seconds)

current_ms() {
    echo $(($(date +%s%N)/1000000))
}

echo "Measuring latency for each peer..."
printf "%-20s | %-10s | %-15s | %-10s\n" "Peer ID (short)" "TCP connect" "Full P2P handshake" "Payload"
echo "---------------------------------------------------------------------------------"

for PEER_ID in "${PEER_IDS[@]}"; do
    SHORT_ID=${PEER_ID:0:12}

    # Full P2P handshake via admin_peers
    START_P2P=$(current_ms)
    HANDSHAKE_COMPLETE=0
    ELAPSED=0
    while [[ $HANDSHAKE_COMPLETE -eq 0 && $ELAPSED -lt $TIMEOUT ]]; do
        PEERS_JSON=$(curl -s -X POST \
            --data '{"jsonrpc":"2.0","method":"admin_peers","params":[],"id":1}' \
            $BESU_RPC)
        if echo "$PEERS_JSON" | grep -q "$PEER_ID"; then
            HANDSHAKE_COMPLETE=1
            END_P2P=$(current_ms)
        else
            sleep 1
            ELAPSED=$((ELAPSED+1))
        fi
    done

    if [[ $HANDSHAKE_COMPLETE -eq 0 ]]; then
        P2P_LATENCY="timeout"
    else
        P2P_LATENCY=$((END_P2P-START_P2P))
    fi

    # Payload latency (simple RPC call)
    sleep $WAIT
    START_PAYLOAD=$(current_ms)
    curl -s -X POST \
        --data '{"jsonrpc":"2.0","method":"net_peerCount","params":[],"id":1}' \
        $BESU_RPC > /dev/null
    END_PAYLOAD=$(current_ms)
    PAYLOAD_LATENCY=$((END_PAYLOAD-START_PAYLOAD))

    # Print results
    printf "%-20s | %-10s | %-15s | %-10s\n" "$SHORT_ID" "$TCP_LATENCY" "$P2P_LATENCY" "$PAYLOAD_LATENCY"
done

echo ""
echo "Done. Press ENTER to exit..."
read
