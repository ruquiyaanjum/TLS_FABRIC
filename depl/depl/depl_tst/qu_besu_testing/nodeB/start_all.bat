@echo off

start stunnel tls_proxy/config/nodeB.conf

timeout /t 5 >nul

start "besu-nodeB" node_B_ALICE1\besu_start.bat
