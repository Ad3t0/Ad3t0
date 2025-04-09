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

# Prompt for custom subnet mask (CIDR) if needed
read -p "Enter subnet mask in CIDR notation (press Enter to use current subnet): " CUSTOM_CIDR

# Change the hostname
hostnamectl set-hostname "$NEW_HOSTNAME"

# Update hostname in /etc/hosts
sed -i "s/127.0.1.1.*/127.0.1.1 $NEW_HOSTNAME/" /etc/hosts

# Create a new netplan config with higher precedence
# Get the existing network settings from any active netplan config
INTERFACE=$(ip -o -4 route show to default | awk '{print $5}')
GATEWAY=$(ip -o -4 route show to default | awk '{print $3}')
# Try to extract current nameservers from existing netplan files
NAMESERVER_FILE=$(find /etc/netplan -name "*.yaml" | grep -v "99-custom-config.yaml" | head -1)
if [ -n "$NAMESERVER_FILE" ]; then
    # Extract nameservers using sudo
    EXISTING_NAMESERVERS=$(sudo grep -A4 "nameservers:" "$NAMESERVER_FILE" | grep -o '[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}' | head -1)
    # If we couldn't extract any, fall back to a default
    if [ -z "$EXISTING_NAMESERVERS" ]; then
        EXISTING_NAMESERVERS="172.30.0.2"
    fi
else
    # Default if no netplan files found
    EXISTING_NAMESERVERS="172.30.0.2"
fi

# Extract current CIDR notation (subnet mask)
CURRENT_CIDR=$(ip -o -4 addr show dev $INTERFACE | awk '{print $4}' | cut -d/ -f2 | head -1)
if [ -z "$CURRENT_CIDR" ]; then
    # Default to /24 if we couldn't detect it
    CURRENT_CIDR="24"
fi

# Use custom CIDR if provided
if [ -n "$CUSTOM_CIDR" ]; then
    CURRENT_CIDR="$CUSTOM_CIDR"
fi

# Backup existing netplan files
mkdir -p /etc/netplan/backup
for file in /etc/netplan/*.yaml; do
    if [ -f "$file" ] && [ "$(basename "$file")" != "99-custom-config.yaml" ]; then
        cp "$file" "/etc/netplan/backup/$(basename "$file").bak"
        # Rename the original files to .disabled
        mv "$file" "${file}.disabled"
    fi
done

# Create new netplan file
NEW_NETPLAN_FILE="/etc/netplan/01-netcfg.yaml"

# Create the new netplan config
cat > "$NEW_NETPLAN_FILE" << EOF
network:
  version: 2
  ethernets:
    $INTERFACE:
      addresses:
        - $NEW_IP/$CURRENT_CIDR
      nameservers:
        addresses:
        - $EXISTING_NAMESERVERS
        search: []
      routes:
      - to: "default"
        via: "$GATEWAY"
EOF

# Set proper permissions on the netplan file (600 = read/write for owner only)
chmod 600 "$NEW_NETPLAN_FILE"

echo "Network configuration created in $NEW_NETPLAN_FILE"
echo "Network configuration will be applied on next reboot to prevent disconnection."
echo "DO NOT run 'netplan apply' manually or your SSH session may disconnect."

# Update and upgrade packages without prompts
export DEBIAN_FRONTEND=noninteractive
apt update
apt upgrade -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold"

echo "System updated and upgraded."
echo "Network configuration has been applied, but a reboot is recommended to ensure all changes take effect."
echo "After reboot, your system will be accessible at the new IP address: $NEW_IP/$CURRENT_CIDR"
read -p "Do you want to reboot now? (y/n): " REBOOT_CHOICE

if [[ $REBOOT_CHOICE =~ ^[Yy]$ ]]; then
    echo "Rebooting in 10 seconds. Press Ctrl+C to cancel."
    sleep 10
    reboot
else
    echo "Please remember to reboot your system to apply all changes."
fi