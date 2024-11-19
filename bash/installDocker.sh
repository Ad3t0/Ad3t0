#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Function to print error messages
error() {
    echo "Error: $1" >&2
    exit 1
}

# Check if script is run as root
if [ "$EUID" -ne 0 ]; then
    error "This script must be run as root. Please use sudo."
fi

echo "Starting Docker Engine installation..."

# Update package index
apt-get update || error "Failed to update package index"

# Install required packages
apt-get install -y ca-certificates curl || error "Failed to install required packages"

# Set up Docker's GPG key
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc || error "Failed to download Docker's GPG key"
chmod a+r /etc/apt/keyrings/docker.asc

# Add Docker repository to Apt sources
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  tee /etc/apt/sources.list.d/docker.list > /dev/null

# Update package index again
apt-get update || error "Failed to update package index after adding Docker repository"

# Install Docker packages
apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin || error "Failed to install Docker packages"

echo "Docker Engine installation completed successfully!"

# Create docker group and add current user
groupadd -f docker
usermod -aG docker $SUDO_USER


