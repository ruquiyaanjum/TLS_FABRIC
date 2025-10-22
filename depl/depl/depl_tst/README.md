# Quantum-Resistant TLS-proxy wrapped Hyperledger Besu

### Directory Structure

```plaintext
\depl_tst
|
|- \cl_besu_testing      # Classical Besu (no TLS proxy)
|  |- gen.bat
|  |- genesis.json
|  |- ibftConfigFile.json
|  |- \networkFiles
|  |  |- genesis.json
|  |  \- \keys\{addresses}\key, key.pub
|  |- \nodeA
|  |  |- start_all.bat
|  |  |- test.sh
|  |  \- \node_A_BOB@ERNET
|  |     |- besu_start.bat
|  |     |- static-nodes.json
|  |     \- \data\...
|  |- \nodeB
|  |  \- ...
|  |- \nodeC
|  |  \- ...
|  |- \nodeD
|  |  \- ...
|  \- \nodeE
|     \- ...
|
\- \qu_besu_testing      # Quantum-resistant TLS-proxy Besu
   |- gen.bat
   |- genesis.json
   |- ibftConfigFile.json
   |- \keys
   |  \- nodeA..E\psk_*.txt
   |- \networkFiles
   |  |- genesis.json
   |  \- \keys\{addresses}\key, key.pub
   |- \nodeA
   |  |- start_all.bat
   |  |- test.sh
   |  |- \stunnel\...
   |  \- \node_A_BOB@ERNET
   |     |- besu_start.bat
   |     |- static-nodes.json
   |     \- \data\...
   |- \nodeB
   |  \- ...
   |- \nodeC
   |  \- ...
   |- \nodeD
   |  \- ...
   \- \nodeE
      \- ...
```

---

## Usage

### Scripts:
- `gen.bat`: generates `genesis.json` and `networkFiles`(elliptic curve keys) from `ibftConfigFile.json`.

- `node{i}../besu_start.bat`: besu's start command to start besu node at target ip and port with allowed protocols.

- `start_all.bat`: bat script to start all necessary *modules* (besu node, stunnel proxy) at once.

- `test.sh`: shell script to measure p2p handshake latency using `ADMIN` peer discovery via `RPC`.

- `stunnel_path.sh`: replaces absolute paths in stunnel configs acc to `pwd -W` and refreshes `stunnel/bin` in `PATH`

### To Run

> if no genesis file or keys: `gen.bat` --> `start_all.bat`

This will start and run the besu node and all necessary modules.

### To Test Latency

> after `start_all.bat` when all nodes running properly --> `test.sh`

It is necessary to note that only the first handshake (be it to any peer) in a network gives true peer discovery metrics. After first measurements ADMIN peer discovery saves route to peer node. To retest metric accurately, restart the network and run `test.sh`.

---

## Network Configuration

### Classical Besu

Each peer p2p port is exposed via machine ip and listens on it. Consequently, `static-nodes.json` lists enode ip:port as <machine IP\>:<node p2p port\>.

### TLS-Wrapped Besu

Each peer p2p port is only exposed to localhost.

Stunnel (client style) proxy listens on a public IP and port and forwards descrypted data to local p2p port

Similarly, each enode mentions localhost:<port\>. Receiving (server style) Stunnel proxy binds on that localhost:port to encrypt received data and forward to known public IP and port of the respective node.

Stunnel config can be found inside `node{i}../stunnel/config`

### PSK Keys
Should be sourced from MAQAN QKD (ideally, periodically); stored in `node{i}../keys` folder with appropriate file name and psk identity.