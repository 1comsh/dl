#!/bin/bash

# List all available disks and partitions
echo "Available disks and partitions:"
lsblk

# Ask the user to choose the disk (e.g., sda, sdb, etc.)
read -p "Enter the disk to partition and install (e.g., sda): " disk

# Add /dev/ prefix to the disk input
disk="/dev/$disk"

# Verify that the chosen disk exists
if [ ! -e "$disk" ]; then
    echo "Error: Disk $disk does not exist."
    exit 1
fi

# Start partitioning the disk with parted
echo "Creating partitions on $disk..."

# Create a new GPT partition table
sudo parted -s "$disk" mklabel gpt

# Create the BIOS partition (4 MB) for bios_grub
sudo parted -s "$disk" mkpart primary 1MiB 5MiB
sudo parted -s "$disk" set 1 bios_grub on

# Create the EFI partition (800 MB) in FAT32
sudo parted -s "$disk" mkpart primary fat32 5MiB 805MiB
sudo parted -s "$disk" set 2 boot on
sudo parted -s "$disk" set 2 esp on

# Create the EXT4 partition (using remaining space for Slax)
sudo parted -s "$disk" mkpart primary ext4 805MiB 100%

# Format the partitions
echo "Formatting partitions..."

# Format the EFI partition (800MB) as FAT32
sudo mkfs.vfat -F32 "${disk}2"

# Format the remaining partition (ext4) for Linux
sudo mkfs.ext4 "${disk}3"

# Create the mount point directories based on partition names
sudo mkdir -p /mnt/${disk##*/}2  # e.g., /mnt/sda2
sudo mkdir -p /mnt/${disk##*/}3  # e.g., /mnt/sda3

echo "Mount the EFI partition to /mnt/${disk##*/}2"
sudo mount "${disk}2" /mnt/${disk##*/}2

echo "Mount the EXT4 partition for Linux to /mnt/${disk##*/}3"
sudo mount "${disk}3" /mnt/${disk##*/}3

# Install GRUB for BIOS-based systems (i386-pc)
echo "Installing GRUB for BIOS (i386-pc)..."
sudo grub-install --target=i386-pc "$disk" --boot-directory=/mnt/${disk##*/}2/efi --removable

# Install GRUB for UEFI-based systems (x86_64-efi)
echo "Installing GRUB for UEFI (x86_64-efi)..."
sudo grub-install --target=x86_64-efi --efi-directory=/mnt/${disk##*/}2 --boot-directory=/mnt/${disk##*/}2/efi --removable

# Check the installation status
echo "GRUB installation completed. Checking the disk layout..."
lsblk

echo "Partition setup and GRUB installation complete!"
