#!/bin/bash
export MSYS_NO_PATHCONV=1

echo "Accessing Hyperledger Fabric CLI"
echo "================================"

# Check if CLI container is running
if ! docker ps | grep -q "cli"; then
    echo "Error: CLI container is not running. Start the network first with ./start.sh"
    exit 1
fi

echo "Entering CLI container..."
echo "Available commands:"
echo "- ./create-channel.sh (create and join channel)"
echo "- ./test-network.sh (test the network)"
echo "- exit (to leave CLI)"

docker exec -it cli bash 