@echo off

start stunnel tls_proxy/config/nodeC.conf

timeout /t 5 >nul

start "besu-nodeC" node_C_BOB@NIC\besu_start.bat
