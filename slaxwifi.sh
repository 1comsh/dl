#!/bin/bash
echo "deb https://mirror.sg.gs/debian/ bookworm main" | sudo tee -a /etc/apt/sources.list
echo "deb https://mirror.twds.com.tw/debian/ bookworm main" | sudo tee -a /etc/apt/sources.list

# Find wifi device
rfkill unblock all
ip a

# Prompt user for wifi device
read -p "Enter wifi device name (e.g., wlan0): " wifi_device

# Unblock wifi
rfkill unblock wifi

# Scan for SSID
wpa_cli scan

# Show wifi SSID
wpa_cli scan_results

# Prompt user for SSID and password
read -p "Enter SSID: " ssid
read -p "Enter Password: " password
echo

# Setup wifi connection
wpa_passphrase "$ssid" "$password" | tee /etc/wpa_supplicant/wpa_supplicant.conf

# Start wpa_supplicant
wpa_supplicant -B -i "$wifi_device" -c /etc/wpa_supplicant/wpa_supplicant.conf

# Check wifi status
wpa_cli status 

# Run DHCP to get an IP
dhclient "$wifi_device"

#Test by ping Google
ping -c 2 1.1.1.1
