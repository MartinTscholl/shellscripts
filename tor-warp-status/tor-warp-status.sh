torctl_status=$(sudo torctl status)
if echo "$torctl_status" | grep  "torctl is started" || echo "$torctl_status" | grep "tor service is: active"; then
	notify-send -u low -t 750 "TOR enabled"
elif warp-cli status | grep "Connected"; then
	notify-send -u low -t 750 "WARP enabled"
else
	notify-send -u low -t 750 "Nothing enabled"
fi
