#!/bin/bash

# Set the default Bluetooth device ID
default_device_id="74:45:CE:89:9D:42"

# If the script was run with an argument, connect to that device or disconnect if already connected
if [ $# -eq 1 ]; then
    device_id=$1
    if bluetoothctl info | grep -o "$device_id"; then
        echo -e "disconnect $device_id\nquit" | bluetoothctl
    else
	if echo -e \"power on\nagent on\nconnect $device_id\" | bluetoothctl | grep -o "Changing power on succeeded"; then
	    notify-send -u low -t 2000 "Device $device_id is not available"
	fi
    fi
    exit 0
fi

# If the default device is already connected, disconnect from it and exit
if bluetoothctl info | grep -o "$default_device_id"; then
    echo -e "disconnect $default_device_id\nquit" | bluetoothctl
    exit 0
fi

# Connect to the default device
if echo -e "power on\nagent on\nconnect $default_device_id" | bluetoothctl | grep -o "Changing power on succeeded"; then
    notify-send -u low -t 2000 "Device $default_device_id is not available"
fi
