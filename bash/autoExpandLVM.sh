#!/bin/bash

# Automatic Disk and LVM Expansion Script for Ubuntu
# Use with caution! Always backup your data before running.

set -e

# Check if running as root
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root"
  exit 1
fi

# Define variables (modify these as needed)
DISK="/dev/sda"
PARTITION="${DISK}3"
VG="ubuntu-vg"
LV="ubuntu-lv"

# Function to check if a command was successful
check_success() {
    if [ $? -ne 0 ]; then
        echo "Error: $1"
        exit 1
    fi
}

echo "Starting automatic disk and LVM expansion..."

# Step 1: Fix GPT and resize partition
echo "Fixing GPT and resizing partition..."
parted $DISK print free | tee /tmp/parted_output.txt
if grep -q "fix the GPT to use all of the space" /tmp/parted_output.txt; then
    parted $DISK ---pretend-input-tty <<EOF
Fix
quit
EOF
    check_success "Failed to fix GPT"
fi

parted $DISK resizepart 3 100%
check_success "Failed to resize partition"

# Step 2: Update kernel partition table
echo "Updating kernel partition table..."
partprobe $DISK
check_success "Failed to update kernel partition table"

# Step 3: Resize physical volume
echo "Resizing physical volume..."
pvresize $PARTITION
check_success "Failed to resize physical volume"

# Step 4: Extend logical volume
echo "Extending logical volume..."
lvextend -l +100%FREE /dev/$VG/$LV
check_success "Failed to extend logical volume"

# Step 5: Resize filesystem
echo "Resizing filesystem..."
if [ -n "$(blkid -o value -s TYPE /dev/$VG/$LV | grep ext4)" ]; then
    resize2fs /dev/$VG/$LV
else
    xfs_growfs /dev/$VG/$LV
fi
check_success "Failed to resize filesystem"

echo "Disk expansion completed successfully!"

# Display final system state
echo "Final system state:"
df -h
lsblk
lvdisplay

echo "Script execution completed."