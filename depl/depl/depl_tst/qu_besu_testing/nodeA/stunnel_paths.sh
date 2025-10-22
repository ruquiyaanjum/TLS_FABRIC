#!/usr/bin/env bash

BASE_DIR="$(cd "$(dirname "$0")" && pwd -W)"
echo "BASE_DIR is set to: $BASE_DIR"
echo

STUNNEL_DIR="$BASE_DIR/stunnel"
STUNNEL_BIN="$STUNNEL_DIR/bin"
echo "STUNNEL_BIN is set to: $STUNNEL_BIN"
echo

CONFIG_DIR="$STUNNEL_DIR/config/tls_proxy/config"

# Update config files
if [ -d "$CONFIG_DIR" ]; then
  for conf_file in "$CONFIG_DIR"/node*.conf; do
    if [ -f "$conf_file" ]; then
      echo "Updating paths in: $conf_file"
      echo
      echo "Replacing 'C:/Users/89/Desktop/trial/dApp_demo/besu_network' with '$BASE_DIR'"
      echo
      sed -i "s#C:/Users/89/Desktop/trial/dApp_demo/besu_network#$BASE_DIR#g" "$conf_file"
    fi
  done
else
  echo "Config directory not found: $CONFIG_DIR"
  echo
fi


# Update PATH
echo "Updating PATH to include: $STUNNEL_BIN"
echo

STUNNEL_BIN=$(echo "$STUNNEL_BIN" | sed 's#/#\\#g')

CURRENT_PATH=$(powershell.exe -NoProfile -Command '[System.Environment]::GetEnvironmentVariable("Path", "User")' | tr -d '\r')

NEW_PATH=$(echo "$CURRENT_PATH" | awk -v RS=';' -v ORS=';' '!/stunnel[\\\/]bin/ {print}')
NEW_PATH=$(echo "$NEW_PATH" | sed 's/;*$//')

NEW_PATH="$NEW_PATH;$STUNNEL_BIN;"
echo "Added fresh $STUNNEL_BIN to PATH."
echo
echo "Final PATH to be set:"
echo "$NEW_PATH"
echo

powershell.exe -NoProfile -Command "[System.Environment]::SetEnvironmentVariable('Path', '$NEW_PATH', 'User')"

echo "PATH updated successfully!"
echo

read -n 1 -s -r -p "Press any key to exit..."
echo
