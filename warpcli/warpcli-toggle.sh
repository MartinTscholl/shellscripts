#!/bin/bash

if warp-cli status | grep "Connected"
then
	warp-cli disconnect
	notify-send -u low -t 750 "Disconnected warp-cli"
else
	warp-cli connect
	notify-send -u low -t 750 "Connected warp-cli"
fi
