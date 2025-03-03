#!/bin/bash

sudo apt update -y

sudo apt install nala -y

sudo nala --install-completion bash

sudo nala update && sudo apt upgrade -y

sudo nala clean

xargs -a 1compkgs sudo nala install

sudo nala update

sudo nala clean

sudo nala install sddm -y

sudo nala update

sudo nala clean
