@echo off

start stunnel tls_proxy/config/nodeE.conf

timeout /t 5 >nul

start "besu-nodeE" node_E_ALICE2\besu_start.bat