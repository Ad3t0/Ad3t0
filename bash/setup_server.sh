#!/bin/bash

# Check if the script is run as root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root"
   exit 1
fi

# Prompt for new hostname
read -p "Enter the new hostname: " NEW_HOSTNAME

# Prompt for new IP address
read -p "Enter the new IP address: " NEW_IP

# Change the hostname
hostnamectl set-hostname "$NEW_HOSTNAME"

# Update hostname in /etc/hosts
sed -i "s/127.0.1.1.*/127.0.1.1 $NEW_HOSTNAME/" /etc/hosts

# Update the IP address in Netplan config
NETPLAN_FILE="/etc/netplan/00-installer-config.yaml"

# Backup the original file
cp "$NETPLAN_FILE" "${NETPLAN_FILE}.bak"

# Update only the IP address under the 'addresses:' section, not touching nameservers
sed -i '/ethernets:/,/nameservers:/{ /addresses:/,/nameservers:/{ /- /s/[0-9]\+\.[0-9]\+\.[0-9]\+\.[0-9]\+/'"$NEW_IP"'/; } }' "$NETPLAN_FILE"

echo "Network configuration updated in $NETPLAN_FILE"
echo "Changes will take effect after reboot."

# Update and upgrade packages without prompts
export DEBIAN_FRONTEND=noninteractive
apt update
apt upgrade -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold"

echo "System updated and upgraded."
echo "A reboot is required to apply all changes, including the new network configuration."
echo "After reboot, your system will be accessible at the new IP address: $NEW_IP"
read -p "Do you want to reboot now? (y/n): " REBOOT_CHOICE

if [[ $REBOOT_CHOICE =~ ^[Yy]$ ]]; then
    echo "Rebooting in 10 seconds. Press Ctrl+C to cancel."
    sleep 10
    reboot
else
    echo "Please remember to reboot your system to apply all changes."
fi