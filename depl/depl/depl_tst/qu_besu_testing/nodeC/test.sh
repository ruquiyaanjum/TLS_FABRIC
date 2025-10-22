#!/bin/bash

# --- CONFIG ---
BESU_RPC="http://127.0.0.1:19546"   # Besu RPC endpoint
PEER_IDS=(
  "cca729ff625685484fee9c6de6d0a23acff38f5539c16c8b6058ac5cf31c02917d1f77e2daa15924bbf4ae90e964502724932ed6128947dfed0f71a9bd8f28ba"
  "1a712f4c1153bb63f946ac1c38e01829fb228fd9cfcf6af5ec75baa36eb58862d80a92526b936fe4f449339ae211d75a62b470e786b4b150633d6146ffe9fbb6"
)

WAIT=1        # Wait between steps (seconds)
TIMEOUT=5    # Max wait for handshake completion (seconds)

# --- FUNCTION TO GET CURRENT TIME IN MS ---
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
