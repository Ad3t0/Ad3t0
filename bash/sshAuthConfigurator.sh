#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Function to display messages
function echo_info {
    echo -e "\n[INFO] $1\n"
}

function echo_error {
    echo -e "\n[ERROR] $1\n" >&2
}

# Check if the script is run as root for sudo operations
if [ "$EUID" -ne 0 ]; then
    echo_error "Please run as root or use sudo."
    exit 1
fi

# Variables
SSH_DIR="$HOME/.ssh"
KEY_TYPE="ed25519"
KEY_FILE="$SSH_DIR/id_$KEY_TYPE"
SSHD_CONFIG="/etc/ssh/sshd_config"
BACKUP_SSHD_CONFIG="/etc/ssh/sshd_config.bak_$(date +%F_%T)"

# Create SSH directory if it doesn't exist
mkdir -p "$SSH_DIR"
chmod 700 "$SSH_DIR"
echo_info "Ensured SSH directory exists with correct permissions."

# Generate SSH key pair without passphrase if it doesn't already exist
if [ ! -f "$KEY_FILE" ]; then
    ssh-keygen -t "$KEY_TYPE" -f "$KEY_FILE" -N "" -C "$(whoami)@$(hostname)-$(date -I)"
    echo_info "Generated SSH key pair."
else
    echo_info "SSH key already exists. Skipping key generation."
fi

# Set correct permissions for SSH files
chmod 600 "$KEY_FILE"
chmod 644 "${KEY_FILE}.pub"
echo_info "Set permissions for SSH key files."

# Create authorized_keys file if it doesn't exist and set permissions
touch "$SSH_DIR/authorized_keys"
chmod 644 "$SSH_DIR/authorized_keys"
echo_info "Ensured authorized_keys exists with correct permissions."

# Add public key to authorized_keys if not already present
if ! grep -q -F "$(cat "${KEY_FILE}.pub")" "$SSH_DIR/authorized_keys"; then
    cat "${KEY_FILE}.pub" >> "$SSH_DIR/authorized_keys"
    echo_info "Added public key to authorized_keys."
else
    echo_info "Public key already exists in authorized_keys. Skipping."
fi

# Backup original sshd_config
cp "$SSHD_CONFIG" "$BACKUP_SSHD_CONFIG"
echo_info "Backed up original sshd_config to $BACKUP_SSHD_CONFIG."

# Configure SSH daemon for both key and password authentication
sed -i 's/^#\?PubkeyAuthentication .*/PubkeyAuthentication yes/' "$SSHD_CONFIG"
sed -i 's/^#\?PasswordAuthentication .*/PasswordAuthentication yes/' "$SSHD_CONFIG"
echo_info "Configured SSH daemon to allow both key and password authentication."

# Restart SSH service to apply changes
systemctl restart ssh
echo_info "SSH service restarted."

# Display the public key
echo -e "\nYour public SSH key (add this to other servers you want to connect to):\n"
cat "${KEY_FILE}.pub"

# **Security Note:** Displaying the private key can be a security risk.
# It's recommended to keep your private key secure and not display it openly.
# If you still want to display it, uncomment the lines below.

# echo -e "\nYour private SSH key (save this securely):\n"
# cat "$KEY_FILE"

echo -e "\nSSH key setup complete! Both password and key-based authentication are enabled."
echo "Ensure your private key is stored securely."