Armbian AMD64 Downloads : https://dl.armbian.com/uefi-x86/

=======================================================================================
Flash img :
 Find Target Drive : lsblk
 Use DD Command for X = target drive :

sudo xzcat file.img.xz | sudo dd of=/dev/sdX status=progress bs=2M conv=fsync

dd if=xxx.img of=/dev/sdX status=progress bs=1M conv=fsync

Decompress XZ : xz -dk xxx.img.xz

Decompress 7Zip : 7z x xxx.img.xz

=======================================================================================
# Install Grub bootloader :
# lsblk = /dev/sdX  >  mount = /mnt/sdX

#Grub-Install gonna Create "/efi/grub" Files > /efi/grub/grub.cfg
sudo grub-install --target=i386-pc /dev/sdX --boot-directory=/mnt/sdX2/efi --removable


#Grub-Install gonna Create "/efi/boot/bootx64.efi" File > /efi/boot/grub.cfg
sudo grub-install --target=x86_64-efi --efi-directory=/mnt/sdX2 --boot-directory=/mnt/sdX2/efi --removable

=======================================================================================
#Slax64 Setting :

passwd guest

usermod -l user guest

usermod -d /home/user -m user

apt update && apt install sudo nala -y

usermod -aG sudo user

=======================================================================================
#Gnome-Disks Mount Options :

user,noatime,nodiratime,group,nodev,exec,async,comment=x-gvfs-show,x-gvfs-show,x-udisks-auth
users,noatime,nodiratime,suid,dev,exec,async,comment=x-gvfs-show,x-gvfs-show,x-udisks-auth
