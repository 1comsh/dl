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

# Build partition path based on the user input
efinput="/dev/${disk##*/}$efinput"

# Verify that the selected EFI partition exists
if [ ! -e "$efinput" ]; then
    echo "Error: Partition $efinput does not exist."
    exit 1
fi

# Set Boot on Partition for UEFI-based systems (x86_64-efi)
sudo parted -s "$disk" set "${efinput##*/}" boot on
sudo parted -s "$disk" set "${efinput##*/}" esp on

# Function to check if a partition is already mounted
check_and_mount_efi() {
    local partition=$1
    local mount_point=$2

    if mount | grep -q "$partition"; then
        # If mounted, show where it's mounted
        current_mount=$(mount | grep "$partition" | awk '{print $3}')
        echo "The partition $partition is already mounted at $current_mount."
        
        # Ask the user if they want to keep this or change the mount point
        read -p "Do you want to continue using this mount point or change it? (keep/change): " user_choice
        if [ "$user_choice" == "change" ]; then
            # Prompt the user to specify a new mount point
            read -p "Enter the new mount path for $partition (e.g., sdb2): " new_mount_point
            mount_point="/mnt/$new_mount_point"
            echo "Mounting the partition $partition to $mount_point"
            sudo mount "$partition" "$mount_point"
        else
            echo "Using the existing mount point $current_mount."
        fi
    else
        # If not mounted, create the mount point and mount it
        echo "Partition $partition is not mounted."
        read -p "Enter the mount path for $partition (e.g., sdb2): " mount_point
        mount_point="/mnt/$mount_point"  # Ensure mount point starts with /mnt/
        sudo mkdir -p "$mount_point"
        echo "Mounting $partition to $mount_point"
        sudo mount "$partition" "$mount_point"
    fi
}

# Check and mount the EFI partition
check_and_mount_efi "$efinput" "$efinput"

# Install GRUB for UEFI-based systems (x86_64-efi)
echo "Installing GRUB for UEFI (x86_64-efi)..."
sudo grub-install --target=x86_64-efi --efi-directory=/mnt/${efinput##*/} --boot-directory=/mnt/${efinput##*/}/efi --removable

# Generate GRUB configuration files in /efi/boot/grub.cfg
echo "Generating GRUB configuration..."
sudo grub-mkconfig -o /mnt/${efinput##*/}/efi/boot/grub.cfg

# Check the installation status
echo "GRUB installation completed. Checking the disk layout..."
lsblk
