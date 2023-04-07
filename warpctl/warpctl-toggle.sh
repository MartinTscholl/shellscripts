#!/bin/bash

# Check if Tor is being used and stop it if it is active
torctl_status=$(sudo torctl status)
if echo "$torctl_status" | grep  "torctl is started" && echo "$torctl_status" | grep "tor service is: active"; then
	sudo torctl stop
elif echo "$torctl_status" | grep "torctl is started"; then
	sudo torctl stop
elif echo "$torctl_status" | grep "tor service is: active"; then
	sudo systemctl stop tor
fi

# 
if warp-cli status | grep "Connected"; then
	warp-cli disconnect
	notify-send -u low -t 750 "Disconnected warp-cli"
else
	warp-cli connect
	notify-send -u low -t 750 "Connected warp-cli"
fi
