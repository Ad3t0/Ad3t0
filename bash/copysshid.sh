#!/bin/bash

# Prompt for the user and server name
read -p "Enter the username: " username
read -p "Enter the server name or IP address: " servername

# Prompt for the root password
read -s -p "Enter the root password: " rootpassword
echo

# Check if an SSH key already exists for the regular user
if [ -f ~/.ssh/id_rsa.pub ]; then
  echo "SSH key already exists for $USER. Skipping key generation."
else
  # Generate a new SSH key for the regular user
  echo "Generating a new SSH key for $USER..."
  ssh-keygen -t rsa
fi

# Check if an SSH key already exists for the root user
if [ -f /root/.ssh/id_rsa.pub ]; then
  echo "SSH key already exists for root. Skipping key generation."
else
  # Generate a new SSH key for the root user
  echo "Generating a new SSH key for root..."
  sudo ssh-keygen -t rsa -f /root/.ssh/id_rsa
fi

# Copy the public keys to the server
echo "Copying the public keys to the server..."
cat ~/.ssh/id_rsa.pub | ssh $username@$servername "mkdir -p ~/.ssh && chmod 700 ~/.ssh && cat >> ~/.ssh/authorized_keys"
echo "Public key for $USER copied to $servername."
echo "Copying root's public key to the server..."
echo "$rootpassword" | sudo -S cat /root/.ssh/id_rsa.pub | ssh $username@$servername "sudo mkdir -p /root/.ssh && sudo chmod 700 /root/.ssh && sudo tee -a /root/.ssh/authorized_keys"
echo "Public key for root copied to $servername."

# Enable public key authentication and root login on the server
echo "Enabling public key authentication and root login on the server..."
ssh $username@$servername "sudo sed -i 's/^#PermitRootLogin yes/PermitRootLogin yes/' /etc/ssh/sshd_config && sudo sed -i 's/^#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config && sudo sed -i 's/^PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config && sudo systemctl restart ssh"

echo "Done!"
