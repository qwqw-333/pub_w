#!/bin/bash

# Checking the current connection status
if ! /usr/sbin/iwgetid -r; then
    echo "$(date): Wi-Fi didn't connect, trying to reconnect..."

    # Attempting to reconnect to the network
    sudo ifconfig wlan0 down
    sleep 5
    sudo ifconfig wlan0 up
    sleep 10
    sudo dhclient wlan0

    # Checking the connection after reconnection
    if /usr/sbin/iwgetid -r; then
        echo "$(date): Successfully reconnected to Wi-Fi"
    else
        echo "$(date): Can't reconnect to Wi-Fi"
    fi
else
    echo "$(date): Wi-Fi connect"
fi