#!/bin/bash

# Function to "1. Create a new disk (Partition and Install GRUB)"
create_new_disk() {
    local disk=$1
    local efinput=$2
    local custom_mount=$3

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
sudo parted -s "$disk" mkpart primary 2MiB 5MiB
sudo parted -s "$disk" set 1 bios_grub on

# Create the EFI partition (800 MB) in FAT32
sudo parted -s "$disk" mkpart primary fat32 5MiB 40MiB
sudo parted -s "$disk" set 2 boot on
sudo parted -s "$disk" set 2 esp on

# Create the EXT4 partition (using remaining space for Linux)
sudo parted -s "$disk" mkpart primary ext4 40MiB 100%

# Format the partitions
echo "Formatting partitions..."

# Format the EFI partition (800MB) as FAT32
sudo mkfs.vfat -F32 "${disk}2"

# Format the remaining partition (ext4) for Linux
sudo mkfs.ext4 "${disk}3"

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
            read -p "Enter the new mount path for $partition (e.g., /media/sdb2): " new_mount_point
            mount_point="$new_mount_point"
            echo "Mounting the partition $partition to $mount_point"
            sudo mount "$partition" "$mount_point"
        else
            echo "Using the existing mount point $current_mount."
        fi
    else
        # If not mounted, create the mount point and mount it
        echo "Partition $partition is not mounted."
        read -p "Enter the mount path for $partition (e.g., /media/sdb2 or custom path): " mount_point
        # Create the mount point if it doesn't exist
        sudo mkdir -p "$mount_point"
        echo "Mounting $partition to $mount_point"
        sudo mount "$partition" "$mount_point"
    fi
}

# Ask user for the custom mount path
read -p "Enter the desired mount point for EFI partition (e.g., /media or a custom path): " custom_mount
if [ -z "$custom_mount" ]; then
    custom_mount="/media"  # default mount point
    echo "Using default mount point: /media"
fi

# Check and mount the EFI partition
check_and_mount_efi "$efinput" "$custom_mount/$efinput"

# Install GRUB for BIOS-based systems (i386-pc)
echo "Installing GRUB for BIOS (i386-pc)..."
sudo grub-install --target=i386-pc "$disk" --boot-directory="$custom_mount/${efinput##*/}/efi" --removable

# Install GRUB for UEFI-based systems (x86_64-efi)
echo "Installing GRUB for UEFI (x86_64-efi)..."
sudo grub-install --target=x86_64-efi --efi-directory="$custom_mount/${efinput##*/}" --boot-directory="$custom_mount/${efinput##*/}/efi" --removable

# Check the installation status
echo "GRUB installation completed. Checking the disk layout..."
lsblk

}

# Function to "2. Install GRUB only (on an existing disk)"
install_grub_only() {

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
            read -p "Enter the new mount path for $partition (e.g., /media/sdb2): " new_mount_point
            mount_point="$new_mount_point"
            echo "Mounting the partition $partition to $mount_point"
            sudo mount "$partition" "$mount_point"
        else
            echo "Using the existing mount point $current_mount."
        fi
    else
        # If not mounted, create the mount point and mount it
        echo "Partition $partition is not mounted."
        read -p "Enter the mount path for $partition (e.g., /media/sdb2 or custom path): " mount_point
        # Create the mount point if it doesn't exist
        sudo mkdir -p "$mount_point"
        echo "Mounting $partition to $mount_point"
        sudo mount "$partition" "$mount_point"
    fi
}

# Ask user for the custom mount path
read -p "Enter the desired mount point for EFI partition (e.g., /media or a custom path): " custom_mount
if [ -z "$custom_mount" ]; then
    custom_mount="/media"  # default mount point
    echo "Using default mount point: /media"
fi

# Check and mount the EFI partition
check_and_mount_efi "$efinput" "$custom_mount/$efinput"

# Install GRUB for BIOS-based systems (i386-pc)
echo "Installing GRUB for BIOS (i386-pc)..."
sudo grub-install --target=i386-pc "$disk" --boot-directory="$custom_mount/${efinput##*/}/efi" --removable

# Install GRUB for UEFI-based systems (x86_64-efi)
echo "Installing GRUB for UEFI (x86_64-efi)..."
sudo grub-install --target=x86_64-efi --efi-directory="$custom_mount/${efinput##*/}" --boot-directory="$custom_mount/${efinput##*/}/efi" --removable

# Check the installation status
echo "GRUB installation completed. Checking the disk layout..."
lsblk


}

# Function to show disk details
show_disk_details() {
    echo "Showing disk details..."
    lsblk
}

# Main menu to choose action
while true; do
    echo "Choose an option:"
    echo "1. Create a new disk (Partition and Install GRUB)"
    echo "2. Install GRUB only (on an existing disk)"
    echo "3. Show disk details"
    echo "4. Exit"
    read -p "Enter your choice (1, 2, 3, or 4): " choice

    case $choice in
        1)
            create_new_disk
            ;;
        2)
            install_grub_only
            ;;
        3)
            show_disk_details
            ;;
        4)
            echo "Exiting..."
            exit 0
            ;;
        *)
            echo "Invalid choice. Please enter 1, 2, 3, or 4."
            ;;
    esac
done

