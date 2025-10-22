
# 🧠 Quantum-Resistant Blockchain Network Setup  
### *(Hyperledger Besu + Hyperledger Fabric)*  
**Work by Nishantak**

---

## 🔍 Overview
This project provides a comprehensive guide for setting up **quantum-resilient blockchain environments** based on:

- **Hyperledger Besu (IBFT 2.0)** with **Quantum-Resistant TLS Proxy Wrapping**  
- **Hyperledger Fabric** with **PQC-Enhanced MSP Integration**

---

## ⚙️ Part I: Quantum-Resistant TLS-Proxy Wrapped Hyperledger Besu Network

### 1️⃣ Overview
The **Quantum-Resistant Besu Network** operates on **IBFT 2.0 (Proof of Authority)** consensus with **four validator nodes**.  
It supports two configurations:

- 🧩 **Classical Besu**
- 🔒 **Quantum TLS-Proxied Besu** – Node-to-node communication encapsulated in **post-quantum TLS tunnels** using **stunnel** and **MAQAN QKD Pre-Shared Keys (PSKs)**.

---

### 2️⃣ Prerequisites
- Hyperledger Besu (latest version)  
- Curl or any REST client  
- Stunnel  
- MAQAN QKD or PQC PSK source  
- Windows or Linux shell environment  

---

### 3️⃣ Directory Structure
besu_testing/
├── cl_besu_testing/ # Classical IBFT setup
├── qu_besu_testing/ # Quantum TLS-Proxied setup
├── scripts/
│ ├── start_nodes.sh
│ └── stunnel_path.sh
└── keys/
├── node1/
├── node2/
├── ...

---

### 4️⃣ Classical IBFT 2.0 Setup

1. Create node directories  
2. Define configuration in `ibftConfigFile.json`  
3. Generate network artifacts  
4. Launch nodes  
5. For other nodes: specify **bootnode enode URL** and **unique ports**  
6. Verify successful network formation  

---

### 5️⃣ Quantum-Resistant (TLS Proxy) Setup

#### ⚙️ Automation
Use `stunnel_path.sh` to update stunnel paths and environment variables.  
Run the sequence as:

```bash
./stunnel_path.sh
./run_qubesu.sh
| Layer                | Description                        | Purpose                           |
| -------------------- | ---------------------------------- | --------------------------------- |
| **Besu (IBFT 2.0)**  | Byzantine fault-tolerant consensus | Core ledger                       |
| **Stunnel Proxy**    | TLS channel encapsulation          | Secure node-to-node communication |
| **PSK (QKD source)** | Quantum symmetric key exchange     | Quantum resistance                |
| **Test Scripts**     | Automated validation               | Performance and handshake metrics |

🧬 Part II: PQC_Fabric Network Setup (Integration Work in Progress)
1️⃣ Overview

The PQC_Fabric testbed integrates Post-Quantum Cryptography (PQC) within the Membership Service Provider (MSP).
Testing is conducted in /crypto-benchmark, focusing on hybrid MSPs that combine classical X.509 and PQC keypairs (e.g., Kyber / Dilithium).

2️⃣ Network Architecture
Node	Fabric Role(s)	Ports
nodeA	Orderer, Peer0 of Org1	7050, 7051, 7052, 9443
nodeB	Peer1 of Org1	8051, 8052, 9444
nodeC	Orderer, Peer0 of Org2	8050, 9051, 9052, 9445
nodeD	Peer1 of Org2	10051, 10052, 9446
nodeE	Orderer only	9050
3️⃣ Prerequisites
🐳 Docker & Docker Compose

Install Docker Desktop or Docker Engine.
Verify installation:

docker --version
docker-compose --version

⚙️ Fabric Binaries

Download Fabric binaries and samples:

curl -sSL https://bit.ly/2ysbOFE | bash

💻 Go & Node.js (for Chaincode)

Install required runtimes:

# Go (1.19+)
sudo apt install golang-go

# Node.js (16+)
sudo apt install nodejs npm

4️⃣ Setup & Execution

Generate crypto materials using cryptogen or Fabric CA

Configure docker-compose.yaml for network topology

Launch the network:

./network.sh up


Deploy chaincode and test PQC-enhanced transactions

5️⃣ Components

Orderer Nodes: Maintain transaction order

Peers: Execute and endorse transactions

CA: Issues certificates (extended to support PQC)

Chaincode: Smart contract logic for PQC testing

6️⃣ Troubleshooting
⚠️ Port Conflicts

Ensure all port numbers (7050–10052) are free before launch.

🧩 Container Failures

Check logs with:

docker ps -a
docker logs <container_id>

🔐 Regenerate Crypto

If certificates mismatch or expire:

./network.sh down
./network.sh generate

7️⃣ Cleanup

Shut down the network and remove all containers:

./network.sh down
docker system prune -f

🧾 Summary

This repository demonstrates:

A Quantum-Resistant Hyperledger Besu network using Post-Quantum TLS Proxies, and

A PQC-integrated Fabric testbed focusing on quantum-safe cryptography at the MSP layer.

