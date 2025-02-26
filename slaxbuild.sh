#!/bin/bash
echo "deb https://mirror.sg.gs/debian/ bookworm main" | tee -a /etc/apt/sources.list
echo "deb https://mirror.twds.com.tw/debian/ bookworm main" | tee -a /etc/apt/sources.list

#passwd guest
#usermod -l user guest
#usermod -d /home/user -m user

# Unblock wifi
rfkill unblock all

#Test by ping Google
ping -c 2 1.1.1.1

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

nala install bash-completion elpa-bash-completion gcc git network-manager -y

nala clean

ping -c 2 1.1.1.1
