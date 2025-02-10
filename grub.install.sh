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

# List partitions of the selected disk using parted
echo "Available partitions on $disk:"
sudo parted -s $disk print

# Ask the user to select a partition for the EFI (e.g., /dev/sda2)
read -p "Enter the partition number for the EFI partition (e.g., 2 for $disk): " efinput

# Ask the user to select a partition for the Linux system (e.g., /dev/sda3)
read -p "Enter the partition number for the Linux system partition (e.g., 3 for $disk): " linput

# Build partition paths based on the user input
efinput="/dev/${disk##*/}$efinput"
linput="/dev/${disk##*/}$linput"

# Verify that the selected partitions exist
if [ ! -e "$efinput" ]; then
    echo "Error: Partition $efinput does not exist."
    exit 1
fi

if [ ! -e "$linput" ]; then
    echo "Error: Partition $linput does not exist."
    exit 1
fi

# Create mount points dynamically based on user input
echo "Mounting partitions..."

# Create mount point directories based on the partition numbers input by the user
sudo mkdir -p /mnt/${disk##*/}${efinput##*/}  # e.g., /mnt/sda2 (EFI partition)
sudo mkdir -p /mnt/${disk##*/}${linput##*/}  # e.g., /mnt/sda3 (EXT4 partition for Linux)

# Mount the EFI partition to the appropriate mount point
echo "Mounting the EFI partition to /mnt/${disk##*/}${efinput##*/}"
sudo mount "$efinput" /mnt/${disk##*/}${efinput##*/}

# Mount the EXT4 partition for Linux to the appropriate mount point
echo "Mounting the EXT4 partition for Linux to /mnt/${disk##*/}${linput##*/}"
sudo mount "$linput" /mnt/${disk##*/}${linput##*/}

# Install GRUB for BIOS-based systems (i386-pc)
echo "Installing GRUB for BIOS (i386-pc)..."
sudo grub-install --target=i386-pc "$disk" --boot-directory=/mnt/${disk##*/}${efinput##*/}/efi --removable

# Install GRUB for UEFI-based systems (x86_64-efi)
echo "Installing GRUB for UEFI (x86_64-efi)..."
sudo grub-install --target=x86_64-efi --efi-directory=/mnt/${disk##*/}${efinput##*/} --boot-directory=/mnt/${disk##*/}${efinput##*/}/efi --removable

# Generate GRUB configuration files in /efi/boot/grub.cfg
echo "Generating GRUB configuration..."
sudo grub-mkconfig -o /mnt/${disk##*/}${efinput##*/}/efi/boot/grub.cfg

# Check the installation status
echo "GRUB installation completed. Checking the disk layout..."
lsblk

