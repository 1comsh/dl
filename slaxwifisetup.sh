#!/bin/bash
# Unblock wifi
rfkill unblock all

# Find wifi device (with manual selection if needed)
wifi_device=$(ip a | grep -oE '^[0-9]+: [a-z]+[0-9]+:' | cut -d: -f2 | tr -d ' ')

if [ -z "$wifi_device" ]; then
  echo "Available Wi-Fi Interfaces:"
  ip a | grep -oE '^[0-9]+: [a-z]+[0-9]+:' | cut -d: -f2 | tr -d ' ' | nl -w1 -s'. '
  read -p "Enter the number of your Wi-Fi interface: " interface_num
  wifi_device=$(ip a | grep -oE '^[0-9]+: [a-z]+[0-9]+:' | cut -d: -f2 | tr -d ' ' | sed -n "${interface_num}p")
fi

# Unblock wifi
rfkill unblock wifi

# Scan for SSID
wpa_cli scan

# Show wifi SSID
wpa_cli scan_results

# Prompt user for SSID and password
read -p "Enter SSID: " ssid
read -sp "Enter Password: " password
echo

# Setup wifi connection
wpa_passphrase "$ssid" "$password" | tee /etc/wpa_supplicant/wpa_supplicant.conf > /dev/null
chmod 600 /etc/wpa_supplicant/wpa_supplicant.conf

# Start wpa_supplicant
killall -q wpa_supplicant
wpa_supplicant -B -i "$wifi_device" -c /etc/wpa_supplicant/wpa_supplicant.conf

# Check wifi status
wpa_cli status

# Run DHCP to get an IP
dhclient "$wifi_device"

# Test by ping Google
ping -c 2 1.1.1.1
