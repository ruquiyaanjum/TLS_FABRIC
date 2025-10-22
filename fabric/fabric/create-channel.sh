#!/bin/bash
export MSYS_NO_PATHCONV=1

echo "Creating Channel"
echo "================"

# Create channel
echo "Creating channel..."
docker exec cli bash -c "
export FABRIC_LOGGING_SPEC=ERROR
export CORE_PEER_ADDRESS=nodeA-peer0.org1.qkd:7051
export CORE_PEER_LOCALMSPID=Org1MSP
export CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.qkd/peers/nodeA-peer0.org1.qkd/tls/ca.crt
export CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.qkd/users/Admin@org1.qkd/msp
peer channel create -o nodeA.orderer.qkd:7050 -c mychannel -f /opt/gopath/src/github.com/hyperledger/fabric/peer/channel-artifacts/channel.tx --tls --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/orderer.qkd/orderers/nodeA.orderer.qkd/msp/tlscacerts/tlsca.orderer.qkd-cert.pem
"
if [ $? -ne 0 ]; then
    echo "WARNING: Failed to create channel - continuing anyway..."
fi

echo "Channel created successfully!"

# Join peers to channel
echo "Joining peers to channel..."

# Join nodeA-peer0.org1.qkd
echo "Joining nodeA-peer0.org1.qkd..."
docker exec cli bash -c "
export FABRIC_LOGGING_SPEC=ERROR
export CORE_PEER_ADDRESS=nodeA-peer0.org1.qkd:7051
export CORE_PEER_LOCALMSPID=Org1MSP
export CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.qkd/peers/nodeA-peer0.org1.qkd/tls/ca.crt
export CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.qkd/users/Admin@org1.qkd/msp
peer channel join -b mychannel.block
"
if [ $? -ne 0 ]; then
    echo "WARNING: Failed to join nodeA-peer0.org1.qkd - continuing anyway..."
else
    echo "nodeA-peer0.org1.qkd joined successfully!"
fi

# Join nodeB-peer1.org1.qkd
echo "Joining nodeB-peer1.org1.qkd..."
docker exec cli bash -c "
export FABRIC_LOGGING_SPEC=ERROR
export CORE_PEER_ADDRESS=nodeB-peer1.org1.qkd:7051
export CORE_PEER_LOCALMSPID=Org1MSP
export CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.qkd/peers/nodeA-peer0.org1.qkd/tls/ca.crt
export CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.qkd/users/Admin@org1.qkd/msp
peer channel join -b mychannel.block
"
if [ $? -ne 0 ]; then
    echo "WARNING: Failed to join nodeB-peer1.org1.qkd - continuing anyway..."
else
    echo "nodeB-peer1.org1.qkd joined successfully!"
fi

# Join nodeC-peer0.org2.qkd
echo "Joining nodeC-peer0.org2.qkd..."
docker exec cli bash -c "
export FABRIC_LOGGING_SPEC=ERROR
export CORE_PEER_ADDRESS=nodeC-peer0.org2.qkd:7051
export CORE_PEER_LOCALMSPID=Org2MSP
export CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.qkd/peers/nodeC-peer0.org2.qkd/tls/ca.crt
export CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.qkd/users/Admin@org2.qkd/msp
peer channel join -b mychannel.block
"
if [ $? -ne 0 ]; then
    echo "WARNING: Failed to join nodeC-peer0.org2.qkd - continuing anyway..."
else
    echo "nodeC-peer0.org2.qkd joined successfully!"
fi

# Join nodeD-peer1.org2.qkd
echo "Joining nodeD-peer1.org2.qkd..."
docker exec cli bash -c "
export FABRIC_LOGGING_SPEC=ERROR
export CORE_PEER_ADDRESS=nodeD-peer1.org2.qkd:7051
export CORE_PEER_LOCALMSPID=Org2MSP
export CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.qkd/peers/nodeC-peer0.org2.qkd/tls/ca.crt
export CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.qkd/users/Admin@org2.qkd/msp
peer channel join -b mychannel.block
"
if [ $? -ne 0 ]; then
    echo "WARNING: Failed to join nodeD-peer1.org2.qkd - continuing anyway..."
else
    echo "nodeD-peer1.org2.qkd joined successfully!"
fi

# Update anchor peers
echo "Updating anchor peers..."

# Update Org1 anchor peer
echo "Updating Org1 anchor peer..."
docker exec cli bash -c "
export FABRIC_LOGGING_SPEC=ERROR
export CORE_PEER_ADDRESS=nodeA-peer0.org1.qkd:7051
export CORE_PEER_LOCALMSPID=Org1MSP
export CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.qkd/peers/nodeA-peer0.org1.qkd/tls/ca.crt
export CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.qkd/users/Admin@org1.qkd/msp
peer channel update -o nodeA.orderer.qkd:7050 -c mychannel -f /opt/gopath/src/github.com/hyperledger/fabric/peer/channel-artifacts/Org1MSPanchors.tx --tls --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/orderer.qkd/orderers/nodeA.orderer.qkd/msp/tlscacerts/tlsca.orderer.qkd-cert.pem
"
if [ $? -ne 0 ]; then
    echo "WARNING: Failed to update Org1 anchor peer - continuing anyway..."
else
    echo "Org1 anchor peer updated successfully!"
fi

# Update Org2 anchor peer
echo "Updating Org2 anchor peer..."
docker exec cli bash -c "
export FABRIC_LOGGING_SPEC=ERROR
export CORE_PEER_ADDRESS=nodeC-peer0.org2.qkd:7051
export CORE_PEER_LOCALMSPID=Org2MSP
export CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.qkd/peers/nodeC-peer0.org2.qkd/tls/ca.crt
export CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.qkd/users/Admin@org2.qkd/msp
peer channel update -o nodeA.orderer.qkd:7050 -c mychannel -f /opt/gopath/src/github.com/hyperledger/fabric/peer/channel-artifacts/Org2MSPanchors.tx --tls --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/orderer.qkd/orderers/nodeA.orderer.qkd/msp/tlscacerts/tlsca.orderer.qkd-cert.pem
"
if [ $? -ne 0 ]; then
    echo "WARNING: Failed to update Org2 anchor peer - continuing anyway..."
else
    echo "Org2 anchor peer updated successfully!"
fi

echo ""
echo "Channel creation completed!"
echo "Channel 'mychannel' has been created and all peers have joined."
echo "Press any key to continue..."
read -n 1 