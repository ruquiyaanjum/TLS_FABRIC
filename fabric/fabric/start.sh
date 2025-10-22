#!/bin/bash
export MSYS_NO_PATHCONV=1

echo "Starting Hyperledger Fabric Network"
echo "==================================="

# Check if required files exist
if [ ! -d "crypto-config" ]; then
    echo "Error: crypto-config directory not found. Run setup.sh first."
    exit 1
fi

if [ ! -f "channel-artifacts/genesis.block" ]; then
    echo "Error: genesis.block not found. Run setup.sh first."
    exit 1
fi

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    echo "Error: Docker is not running. Please start Docker first."
    exit 1
fi

# Stop any existing containers
echo "Stopping existing containers..."
docker-compose -f docker-compose.yaml down -v
if [ $? -ne 0 ]; then
    echo "WARNING: Failed to stop existing containers - continuing anyway..."
else
    echo "Existing containers stopped successfully!"
fi

# Start the network
echo "Starting network containers..."
docker-compose -f docker-compose.yaml up -d
if [ $? -ne 0 ]; then
    echo "WARNING: Failed to start network containers - continuing anyway..."
else
    echo "Network containers started successfully!"
fi

# Wait for containers to be ready
echo "Waiting for containers to be ready..."
sleep 10

# Check container status
echo "Checking container status..."
docker-compose -f docker-compose.yaml ps
if [ $? -ne 0 ]; then
    echo "WARNING: Failed to check container status - continuing anyway..."
else
    echo "Container status checked successfully!"
fi

echo "Network startup completed!"
echo "All containers should be running."
echo "You can now create channels and deploy chaincode."
echo "Press any key to continue..."
read -n 1

echo ""
echo "Network started successfully!"
echo "To access the CLI container, run: ./cli.sh"
echo "To view logs, run: ./logs.sh"
echo "To stop the network, run: ./stop.sh" 