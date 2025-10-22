#!/bin/bash
export MSYS_NO_PATHCONV=1

echo "Testing Hyperledger Fabric Network"
echo "=================================="

# Test channel listing
echo "Testing channel listing..."
docker exec cli bash -c "
export FABRIC_LOGGING_SPEC=ERROR
export CORE_PEER_ADDRESS=nodeA-peer0.org1.qkd:7051
export CORE_PEER_LOCALMSPID=Org1MSP
export CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.qkd/peers/nodeA-peer0.org1.qkd/tls/ca.crt
export CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.qkd/users/Admin@org1.qkd/msp
echo 'Channels joined by nodeA-peer0.org1.qkd:'
peer channel list
"
if [ $? -ne 0 ]; then
    echo "WARNING: Failed to list channels for nodeA-peer0.org1.qkd"
fi

echo ""
echo "Testing network connectivity..."

# Test Org1 peers
echo "Testing Org1 peers..."
echo "nodeA-peer0.org1.qkd:"
docker exec cli bash -c "
export FABRIC_LOGGING_SPEC=ERROR
export CORE_PEER_ADDRESS=nodeA-peer0.org1.qkd:7051
export CORE_PEER_LOCALMSPID=Org1MSP
export CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.qkd/peers/nodeA-peer0.org1.qkd/tls/ca.crt
export CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.qkd/users/Admin@org1.qkd/msp
peer channel list
"
if [ $? -ne 0 ]; then
    echo "WARNING: Failed to list channels for nodeA-peer0.org1.qkd"
fi

echo "nodeB-peer1.org1.qkd:"
docker exec cli bash -c "
export FABRIC_LOGGING_SPEC=ERROR
export CORE_PEER_ADDRESS=nodeB-peer1.org1.qkd:7051
export CORE_PEER_LOCALMSPID=Org1MSP
export CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.qkd/peers/nodeA-peer0.org1.qkd/tls/ca.crt
export CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.qkd/users/Admin@org1.qkd/msp
peer channel list
"
if [ $? -ne 0 ]; then
    echo "WARNING: Failed to list channels for nodeB-peer1.org1.qkd"
fi

# Test Org2 peers
echo "Testing Org2 peers..."
echo "nodeC-peer0.org2.qkd:"
docker exec cli bash -c "
export FABRIC_LOGGING_SPEC=ERROR
export CORE_PEER_ADDRESS=nodeC-peer0.org2.qkd:7051
export CORE_PEER_LOCALMSPID=Org2MSP
export CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.qkd/peers/nodeC-peer0.org2.qkd/tls/ca.crt
export CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.qkd/users/Admin@org2.qkd/msp
peer channel list
"
if [ $? -ne 0 ]; then
    echo "WARNING: Failed to list channels for nodeC-peer0.org2.qkd"
fi

echo "nodeD-peer1.org2.qkd:"
docker exec cli bash -c "
export FABRIC_LOGGING_SPEC=ERROR
export CORE_PEER_ADDRESS=nodeD-peer1.org2.qkd:7051
export CORE_PEER_LOCALMSPID=Org2MSP
export CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.qkd/peers/nodeC-peer0.org2.qkd/tls/ca.crt
export CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.qkd/users/Admin@org2.qkd/msp
peer channel list
"
if [ $? -ne 0 ]; then
    echo "WARNING: Failed to list channels for nodeD-peer1.org2.qkd"
fi

echo ""
echo "Network test completed!"
echo "All peers should show 'mychannel' in their channel list."
echo "Press any key to continue..."
read -n 1 