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
hostnamectl set-hostname $NEW_HOSTNAME

# Update hostname in /etc/hosts
sed -i "s/127.0.1.1.*/127.0.1.1 $NEW_HOSTNAME/" /etc/hosts

# Update the IP address in Netplan config
sed -i '/addresses:/!b;n;s/[0-9]\+\.[0-9]\+\.[0-9]\+\.[0-9]\+/'"$NEW_IP"'/' /etc/netplan/00-installer-config.yaml

# Apply Netplan configuration
netplan apply

# Update and upgrade packages
apt update && apt upgrade -y

# Reboot the system
echo "Rebooting the system in 5 seconds..."
sleep 5
reboot
