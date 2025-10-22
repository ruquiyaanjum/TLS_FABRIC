#!/bin/bash
export MSYS_NO_PATHCONV=1

echo "Stopping Hyperledger Fabric Network"
echo "==================================="

# Stop all containers
echo "Stopping all containers..."
docker-compose -f docker-compose.yaml down -v
if [ $? -ne 0 ]; then
    echo "WARNING: Failed to stop containers - continuing anyway..."
else
    echo "All containers stopped successfully!"
fi

# Remove volumes
echo "Removing volumes..."
docker volume prune -f
if [ $? -ne 0 ]; then
    echo "WARNING: Failed to remove volumes - continuing anyway..."
else
    echo "Volumes removed successfully!"
fi

# Remove networks
echo "Removing networks..."
docker network prune -f
if [ $? -ne 0 ]; then
    echo "WARNING: Failed to remove networks - continuing anyway..."
else
    echo "Networks removed successfully!"
fi

echo "Network stopped successfully!"
echo "All containers, volumes, and networks have been cleaned up."
echo "Press any key to continue..."
read -n 1 