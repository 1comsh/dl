#!/bin/bash
cp nala-bookworm.list /etc/apt/sources.list.d

#passwd guest
#usermod -l user guest
#usermod -d /home/user -m user

# Unblock wifi
rfkill unblock all

# Find wifi device
ip a

# Prompt user for wifi device
read -p "Enter wifi device name (e.g., wlan0): " wifi_device

# Unblock wifi
rfkill unblock wifi

# Scan for SSID and Show wifi SSID
wpa_cli scan
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
ping -c 2 google.co.th

apt update -y && apt install nala ntp perl sudo -y

nala --install-completion bash

nala clean

deluser --remove-home guest
ls /home

# Prompt for New User and Password
read -p "Enter New User : " inputuser
adduser "$inputuser"
usermod -aG sudo,audio,video,dip,netdev,plugdev "$inputuser"
id -Gn "$inputuser"
echo

nala update && apt upgrade -y

nala clean

#xargs -a abbuild nala install -y

nala clean

nala install network-manager -y

nala clean

#Scan for wifi :
nmcli d wifi list

# Prompt for New User and Password
read -p "Enter SSID : " nmssid
read -p "Enter Password : " wifipass
nmcli d wifi connect "$nmssid" password "$wifipass"

ping -c 2 google.co.th
