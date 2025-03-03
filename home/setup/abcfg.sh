#!/bin/bash

sudo apt update -y

sudo apt install nala -y

sudo nala --install-completion bash

sudo nala update && sudo apt upgrade -y

sudo nala install armbian-config -y

sudo nala update

sudo nala clean

sudo armbian-config
