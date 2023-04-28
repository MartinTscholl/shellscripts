#!/bin/bash

on_disconnect() {
  notify-send -u low -t 750 "Power disconnected"
  xbacklight -set 70
}

on_connect() {
  notify-send -u low -t 750 "Power connected"
  xbacklight -set 100
}

prev_value=$(cat /sys/class/power_supply/ADP0/online)

while true; do
  curr_value=$(cat /sys/class/power_supply/ADP0/online)

  # Check if the value has changed
  if [ "$curr_value" != "$prev_value" ]; then
    if [ "$curr_value" -eq 0 ]; then
      on_disconnect
    else
      on_connect
    fi

    prev_value=$curr_value
  fi

  sleep 5
done
