@echo off

start stunnel tls_proxy/config/nodeD.conf

timeout /t 5 >nul

start "besu-nodeD" node_D_ALICE3\besu_start.bat
