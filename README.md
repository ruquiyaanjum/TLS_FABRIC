
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

