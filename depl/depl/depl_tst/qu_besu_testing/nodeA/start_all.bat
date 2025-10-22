@echo off

start stunnel tls_proxy/config/nodeA.conf

timeout /t 5 >nul

start "besu-nodeA" node_A_BOB@ERNET\besu_start.bat
