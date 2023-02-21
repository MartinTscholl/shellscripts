#!/bin/bash

# Set the default Bluetooth device ID and name
default_device_id="74:45:CE:89:9D:42"
default_device_name=""

# Function to get the device name from the id
function get_device_name() {
    id=$1
    name=$(bluetoothctl devices | awk '{print substr($0, index($0, $3))}' | grep $id | awk '{$1=""; print $0}')
    echo $name
}

# If the script was run with an argument, connect to that device or disconnect if already connected
if [ $# -eq 1 ]; then
    device_id=$1
    device_name=$(get_device_name $device_id)
    if bluetoothctl info | grep "$device_id"; then
        echo -e "disconnect $device_id\nquit" | bluetoothctl
    else
        if echo -e "power on\nagent on\nconnect $device_id" | bluetoothctl | grep "Device $device_id not available"; then
		default_device_name=$(get_device_name $default_device_id)
		notify-send -u low -t 2000 "Device $device_name is not available"
	fi
    fi
    exit 0
fi

# If the default device is already connected, disconnect from it and exit
if bluetoothctl info | grep "$default_device_id"; then
    echo -e "disconnect $default_device_id\nquit" | bluetoothctl
    exit 0
fi

# Connect to the default device
if echo -e "power on\nagent on\nconnect $default_device_id" | bluetoothctl | grep "Device $default_device_id not available"; then
    default_device_name=$(get_device_name $default_device_id)
    notify-send -u low -t 2000 "Device $default_device_name is not available"
fi

