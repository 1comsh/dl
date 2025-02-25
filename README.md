Armbian AMD64 Downloads : https://dl.armbian.com/uefi-x86/

Mirror : https://mirror.twds.com.tw/armbian-dl/uefi-x86/archive/?C=S&O=D

==================================================================

Flash img :
- Find Target Drive : lsblk
- Use DD Command for X = target drive :

sudo xzcat file.img.xz | sudo dd of=/dev/sdX status=progress bs=2M conv=fsync

dd if=xxx.img of=/dev/sdX status=progress bs=1M conv=fsync

Decompress XZ : xz -dk xxx.img.xz

Decompress 7Zip : 7z x xxx.img.xz

==================================================================

# Install Grub bootloader :
# lsblk = /dev/sdX  >  mount = /mnt/sdX

#Grub-Install gonna Create "/efi/grub" Files > /efi/grub/grub.cfg :

sudo grub-install --target=i386-pc /dev/sdX --boot-directory=/mnt/sdX2/efi --removable


#Grub-Install gonna Create "/efi/boot/bootx64.efi" File > /efi/boot/grub.cfg :

sudo grub-install --target=x86_64-efi --efi-directory=/mnt/sdX2 --boot-directory=/mnt/sdX2/efi --removable

==================================================================

#Slax64 Setting :

#passwd guest

#usermod -l user guest

#usermod -d /home/user -m user

#apt update && apt install sudo nala -y

#usermod -aG sudo user

ip a

ping -c 2 www.google.co.th

apt update -y && apt install nala ntp perl sudo -y

nala --install-completion bash

nala clean

deluser --remove-home guest

ls /home

#Prompt for New User and Password

read -p "Enter New User : " inputuser

adduser "$inputuser"

usermod -aG sudo,audio,video,dip,netdev,plugdev,power "$inputuser"

id -Gn "$inputuser"

echo

==================================================================

#Gnome-Disks Mount Options :

users,noatime,nodiratime,group,nodev,exec,async,comment=x-gvfs-show,x-gvfs-show,x-udisks-auth
user,users,noatime,nodiratime,suid,dev,exec,async,comment=x-gvfs-show,x-gvfs-show,x-udisks-auth

==================================================================

#Ubuntu remove :

grub-customizer

libfontembed1

libpulsedsp
