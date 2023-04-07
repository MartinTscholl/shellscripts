#!/bin/bash

# Check if Tor is being used and stop it if it is active
torctl_status=$(sudo torctl status)
if echo "$torctl_status" | grep  "torctl is started" || echo "$torctl_status" | grep "tor service is: active"; then
	sudo torctl stop
fi

# Toggle warp-cli 
if warp-cli status | grep "Connected"; then
	warp-cli disconnect
	notify-send -u low -t 750 "WARP disabled"
	notify-send -u low -t 750 "Tor disabled"
else
	warp-cli connect
	notify-send -u low -t 750 "WARP enabled"
fi
