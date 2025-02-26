#!/bin/bash
echo "deb https://mirror.sg.gs/debian/ bookworm main" | sudo tee -a /etc/apt/sources.list
echo "deb https://mirror.twds.com.tw/debian/ bookworm main" | sudo tee -a /etc/apt/sources.list

sudo apt update -y

sudo apt install nala -y

sudo nala --install-completion bash

sudo nala update && sudo apt upgrade -y

sudo nala clean

xargs -a 1compkgs sudo nala install -y

sudo nala update

sudo nala clean

xargs -a xfce sudo nala install

sudo nala update

sudo nala clean

sudo nala install sddm -y

sudo nala update

sudo nala clean
