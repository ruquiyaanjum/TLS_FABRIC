@echo off
REM Run first time for genesis and key setup

besu operator generate-blockchain-config ^
 --config-file=ibftConfigFile.json ^
 --to=networkFiles ^
 --private-key-file-name=key