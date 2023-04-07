#!/bin/bash

# Get the name of the currently connected network
network=$(nmcli -t -f active,ssid dev wifi | grep '^yes' | cut -d ':' -f 2)

if [ -z "$network" ]; then
  echo "No network currently connected"
else
  echo "Disconnecting from $network..."
  nmcli con down "$network"
  echo "Reconnecting to $network..."
  nmcli con up "$network"
fi

