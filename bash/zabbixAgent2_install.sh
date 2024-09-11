#!/bin/bash

# Update package list
sudo apt update

# Download Zabbix release package
wget https://repo.zabbix.com/zabbix/6.0/ubuntu/pool/main/z/zabbix-release/zabbix-release_6.0-4+ubuntu22.04_all.deb

# Install Zabbix release package
sudo dpkg -i zabbix-release_6.0-4+ubuntu22.04_all.deb

# Update package list again
sudo apt update

# Install Zabbix Agent 2
sudo apt install zabbix-agent2 -y

# Modify Zabbix Agent 2 configuration
sudo sed -i 's/Server=127.0.0.1/Server=0.0.0.0\/0/' /etc/zabbix/zabbix_agent2.conf

# Enable Zabbix Agent 2 service
sudo systemctl enable zabbix-agent2

# Restart Zabbix Agent 2 service
sudo systemctl restart zabbix-agent2

echo "Zabbix Agent 2 installation and configuration completed."
