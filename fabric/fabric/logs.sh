#!/bin/bash
export MSYS_NO_PATHCONV=1

echo "Viewing Hyperledger Fabric Network Logs"
echo "======================================="

# Check if containers are running
if ! docker ps | grep -q "orderer\|peer"; then
    echo "Error: No Fabric containers are running. Start the network first with ./start.sh"
    exit 1
fi

echo "Available options:"
echo "1. View all logs"
echo "2. View specific container logs"
echo "3. Follow logs (real-time)"
echo "4. View error logs only"
echo "5. Save logs to file"

read -p "Enter your choice (1-5): " choice

case $choice in
    1)
        echo "Viewing all logs..."
        docker-compose -f docker-compose.yaml logs
        ;;
    2)
        echo "Available containers:"
        docker ps --format "table {{.Names}}\t{{.Image}}\t{{.Status}}"
        echo ""
        read -p "Enter container name: " container_name
        if docker ps | grep -q "$container_name"; then
            docker logs "$container_name"
        else
            echo "Error: Container not found"
        fi
        ;;
    3)
        echo "Following logs (press Ctrl+C to stop)..."
        docker-compose -f docker-compose.yaml logs -f
        ;;
    4)
        echo "Viewing error logs only..."
        docker-compose -f docker-compose.yaml logs | grep -i error
        ;;
    5)
        echo "Saving logs to logs.txt..."
        docker-compose -f docker-compose.yaml logs > logs.txt
        echo "Logs saved to logs.txt"
        ;;
    *)
        echo "Invalid choice"
        exit 1
        ;;
esac 

read -n 1 -s -r -p "Press any key to exit"
echo 