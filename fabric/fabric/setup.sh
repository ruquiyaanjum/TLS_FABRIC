#!/bin/bash
export MSYS_NO_PATHCONV=1

echo "Setting up Hyperledger Fabric Network"
echo "====================================="

# Clean up previous artifacts
echo "Cleaning up previous artifacts..."
rm -rf crypto-config channel-artifacts
if [ $? -ne 0 ]; then
    echo "WARNING: Failed to clean up previous artifacts - continuing anyway..."
else
    echo "Previous artifacts cleaned up successfully!"
fi

# Generate crypto materials
echo "Generating crypto materials..."
cryptogen generate --config=./crypto-config.yaml
if [ $? -ne 0 ]; then
    echo "WARNING: Failed to generate crypto materials - continuing anyway..."
else
    echo "Crypto materials generated successfully!"
fi

# Create genesis block
echo "Creating genesis block..."
configtxgen -profile ThreeOrgsOrdererGenesis -channelID system-channel -outputBlock ./channel-artifacts/genesis.block
if [ $? -ne 0 ]; then
    echo "WARNING: Failed to create genesis block - continuing anyway..."
else
    echo "Genesis block created successfully!"
fi

# Create channel transaction
echo "Creating channel transaction..."
configtxgen -profile TwoOrgsChannel -outputCreateChannelTx ./channel-artifacts/channel.tx -channelID mychannel
if [ $? -ne 0 ]; then
    echo "WARNING: Failed to create channel transaction - continuing anyway..."
else
    echo "Channel transaction created successfully!"
fi

# Create anchor peer updates
echo "Creating anchor peer updates..."

echo "Creating Org1 anchor peer update..."
configtxgen -profile TwoOrgsChannel -outputAnchorPeersUpdate ./channel-artifacts/Org1MSPanchors.tx -channelID mychannel -asOrg Org1
if [ $? -ne 0 ]; then
    echo "WARNING: Failed to create Org1 anchor peer update - continuing anyway..."
else
    echo "Org1 anchor peer update created successfully!"
fi

echo "Creating Org2 anchor peer update..."
configtxgen -profile TwoOrgsChannel -outputAnchorPeersUpdate ./channel-artifacts/Org2MSPanchors.tx -channelID mychannel -asOrg Org2
if [ $? -ne 0 ]; then
    echo "WARNING: Failed to create Org2 anchor peer update - continuing anyway..."
else
    echo "Org2 anchor peer update created successfully!"
fi

find crypto-config -name "config.yaml" -exec sed -i 's|\\|/|g' {} \;

echo "Setup completed!"
echo "Generated artifacts:"
echo "- crypto-config/ (crypto materials)"
echo "- channel-artifacts/ (genesis block, channel tx, anchor updates)"
echo "Press any key to continue..."
read -n 1 