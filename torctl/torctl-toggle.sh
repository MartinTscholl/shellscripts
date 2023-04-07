#!/bin/bash

# Check if warp-cli is being used and stop it if it is active
if warp-cli status | grep "Connected"; then
	warp-cli disconnect
fi

# Togglee torctl
torctl_status=$(sudo torctl status)
if echo "$torctl_status" | grep  "torctl is started" || echo "$torctl_status" | grep "tor service is: active"; then
	sudo torctl stop
	notify-send -u low -t 2750 "TOR disabled"
	notify-send -u low -t 2750 "WARP disabled"
else
	sudo torctl start
	notify-send -u low -t 2750 "TOR enabled"
fi
