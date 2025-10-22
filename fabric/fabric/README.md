# Base Fabric Implementation (WORKING)

## PQC_FABRIC (integration Work in Progress) isolated testing in `/crypto-benchmark`

## Network Architecture

| Node | Fabric Role(s)           | Ports |
|------|-------------------------|-------|
| nodeA | Orderer, Peer0 of Org1 | 7050, 7051, 7052, 9443 |
| nodeB | Peer1 of Org1          | 8051, 8052, 9444 |
| nodeC | Orderer, Peer0 of Org2 | 8050, 9051, 9052, 9445 |
| nodeD | Peer1 of Org2          | 10051, 10052, 9446 |
| nodeE | Orderer only           | 9050 |

## Prerequisites

1. **Docker and Docker Compose**
   ```bash
   # Install Docker Desktop
   # Ensure Docker is running
   ```

2. **Hyperledger Fabric Binaries** Add to $PATH!
   ```bash
   curl -sSL https://bit.ly/2ysbOFE | bash
   ```

3. **Go and Node.js** (for chaincode)
   ```bash
   # Install Go 1.19+ and Node.js 16+
   ```

## Quick Start

### 1. Setup the Network
```bash
# Generate crypto materials and channel artifacts
./setup.sh
```

### 2. Start the Network
```bash
# Start all containers
./start.sh
```

### 3. Create and Join Channel
```bash
# Access CLI container
./cli.sh

# Inside CLI container, run:
./create-channel.sh
```

### 4. Test the Network
```bash
# Inside CLI container, run:
./test-network.sh
```

## Scripts Overview

- **`setup.sh`** - Generates crypto materials and channel artifacts
- **`start.sh`** - Starts the Fabric network containers
- **`stop.sh`** - Stops the Fabric network
- **`cli.sh`** - Access the CLI container
- **`create-channel.sh`** - Creates channel and joins peers (runs inside CLI)
- **`test-network.sh`** - Tests network connectivity (runs inside CLI)
- **`logs.sh`** - View network logs

## Network Components

### Orderers
- **nodeA.orderer.qkd** (Port 7050) - Primary orderer
- **nodeC.orderer.qkd** (Port 8050) - Secondary orderer  
- **nodeE.orderer.qkd** (Port 9050) - Tertiary orderer

### Peers
- **Org1**:
  - nodeA-peer0.org1.qkd (Port 7051) - Anchor peer
  - nodeB-peer1.org1.qkd (Port 8051)
- **Org2**:
  - nodeC-peer0.org2.qkd (Port 9051) - Anchor peer
  - nodeD-peer1.org2.qkd (Port 10051)

### Consensus
- Uses **etcdraft** consensus with 3 orderers
- Requires majority (2 out of 3) for consensus

## Channel Configuration

- **Channel Name**: mychannel
- **Organizations**: Org1, Org2
- **Anchor Peers**: 
  - Org1: nodeA-peer0.org1.qkd
  - Org2: nodeC-peer0.org2.qkd

## Troubleshooting

### Common Issues

1. **Port conflicts**
   ```bash
   # Check if ports are in use
   netstat -tulpn | grep :7050
   ```

2. **Container startup failures**
   ```bash
   # View logs
   ./logs.sh
   
   # Check container status
   docker ps --format "table {{.Names}}\t{{.Image}}\t{{.Status}}\t{{.Ports}}"
   ```

3. **Crypto material issues**
   ```bash
   # Regenerate crypto materials
   rm -rf crypto-config
   ./setup.sh
   ```

## Security Features

- **TLS Enabled**: All communications are encrypted
- **MSP-based Authentication**: X.509 certificates for identity
- **Private Permissioned**: Only authorized organizations can participate
- **Channel Isolation**: Organizations can create private channels

## Cleanup

```bash
# Stop network
./stop.sh

# Remove all data (optional)
docker system prune -a
rm -rf crypto-config channel-artifacts
```

---

PQC implementaions in `MSP` are in /crpto-benchmark