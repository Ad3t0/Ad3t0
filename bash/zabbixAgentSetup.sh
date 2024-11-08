#!/bin/bash

# Function to display colored output
print_color() {
    case $2 in
        "info") COLOR="96m" ;; # Cyan
        "success") COLOR="92m" ;; # Green
        "warning") COLOR="93m" ;; # Yellow
        "error") COLOR="91m" ;; # Red
    esac
    echo -e "\033[${COLOR}$1\033[0m"
}

# Check if script is run as root
if [ "$EUID" -ne 0 ]; then
    print_color "Please run as root or with sudo" "error"
    exit 1
fi

# Prompt for configuration variables
print_color "\n=== Configuration Setup ===" "info"

# Prompt for Zabbix Host
while true; do
    read -p "Enter Zabbix Host IP: " input_host
    if [[ -n "$input_host" ]]; then
        ZABBIX_HOST=$input_host
        break
    else
        print_color "IP address cannot be empty. Please enter a valid IP address." "error"
    fi
done

# Prompt for Zabbix Port
default_port="10051"
while true; do
    read -p "Do you want to change the default port ($default_port)? (y/n): " change_port
    case $change_port in
        [Yy]* )
            read -p "Enter Zabbix Port: " input_port
            if [[ $input_port =~ ^[0-9]+$ ]] && [ $input_port -ge 1 ] && [ $input_port -le 65535 ]; then
                ZABBIX_PORT=$input_port
                break
            else
                print_color "Invalid port number. Please enter a number between 1 and 65535." "error"
            fi
            ;;
        [Nn]* )
            ZABBIX_PORT=$default_port
            break
            ;;
        * )
            print_color "Please answer yes (y) or no (n)" "warning"
            ;;
    esac
done

# Prompt for Host Prefix
read -p "Enter Host Prefix: " HOST_PREFIX
if [ -z "$HOST_PREFIX" ]; then
    echo "Error: Host prefix cannot be empty"
    exit 1
fi

# Display configured values
print_color "\nConfiguration Summary:" "info"
print_color "Zabbix Host: $ZABBIX_HOST" "success"
print_color "Zabbix Port: $ZABBIX_PORT" "success"
print_color "Host Prefix: $HOST_PREFIX" "success"

# Confirm to proceed
while true; do
    read -p "Do you want to proceed with the installation? (y/n): " proceed
    case $proceed in
        [Yy]* )
            break
            ;;
        [Nn]* )
            print_color "Installation cancelled." "warning"
            exit 0
            ;;
        * )
            print_color "Please answer yes (y) or no (n)" "warning"
            ;;
    esac
done

# Check for existing configuration and create backup
if [ -f /etc/zabbix/zabbix_agent2.conf ]; then
    print_color "Existing Zabbix agent configuration found. Creating backup..." "info"
    cp /etc/zabbix/zabbix_agent2.conf /etc/zabbix/zabbix_agent2.conf.bak.$(date +%Y%m%d_%H%M%S)
    print_color "Backup created" "success"
fi

print_color "Starting Zabbix Agent 2 installation..." "info"

# Update system
print_color "Updating system packages..." "info"
apt update

# Install prerequisites
print_color "Installing prerequisites..." "info"
apt install -y curl wget gnupg2 apt-transport-https ca-certificates

# Add Zabbix repository
print_color "Adding Zabbix repository..." "info"
wget https://repo.zabbix.com/zabbix/6.0/ubuntu/pool/main/z/zabbix-release/zabbix-release_6.0-4+ubuntu22.04_all.deb
dpkg -i zabbix-release_6.0-4+ubuntu22.04_all.deb
apt update

# Install Zabbix agent 2
print_color "Installing Zabbix agent 2..." "info"
apt install -y zabbix-agent2

# Create PSK directory and generate PSK
print_color "Setting up PSK encryption..." "info"
mkdir -p /etc/zabbix/psk
# Keep existing PSK if it exists
if [ ! -f /etc/zabbix/psk/zabbix.psk ]; then
    openssl rand -hex 32 > /etc/zabbix/psk/zabbix.psk
fi
chmod 750 /etc/zabbix/psk
chmod 640 /etc/zabbix/psk/zabbix.psk
chown -R zabbix:zabbix /etc/zabbix/psk

# Get system hostname and create prefixed versions
SYSTEM_HOSTNAME=$(hostname)
PREFIXED_HOSTNAME="${HOST_PREFIX}-${SYSTEM_HOSTNAME}"
PSK_IDENTITY="LINUX-${PREFIXED_HOSTNAME}"

# Check for Docker
DOCKER_INSTALLED=false
if command -v docker &> /dev/null; then
    DOCKER_INSTALLED=true
    print_color "Docker detected, will configure Docker monitoring..." "info"
fi

# Configure Zabbix agent
print_color "Configuring Zabbix agent for hybrid monitoring..." "info"
cat > /etc/zabbix/zabbix_agent2.conf << EOF
LogFile=/var/log/zabbix/zabbix_agent2.log
LogFileSize=0
PidFile=/run/zabbix/zabbix_agent2.pid

# Hybrid configuration for both passive and active monitoring
Server=${ZABBIX_HOST}
ServerActive=${ZABBIX_HOST}:${ZABBIX_PORT}

Hostname=${PREFIXED_HOSTNAME}

# TLS PSK Configuration for both directions
TLSConnect=psk
TLSAccept=psk
TLSPSKIdentity=${PSK_IDENTITY}
TLSPSKFile=/etc/zabbix/psk/zabbix.psk

# Basic configuration
ControlSocket=/tmp/agent.sock
Include=/etc/zabbix/zabbix_agent2.d/*.conf

# Buffer configuration
BufferSend=5
BufferSize=100
EOF

# Configure Docker monitoring if Docker is installed
if [ "$DOCKER_INSTALLED" = true ]; then
    print_color "Configuring Docker monitoring..." "info"
    cat > /etc/zabbix/zabbix_agent2.d/docker.conf << EOF
Plugins.Docker.Endpoint=unix:///var/run/docker.sock
EOF

    # Add Zabbix user to Docker group
    print_color "Adding Zabbix user to Docker group..." "info"
    usermod -aG docker zabbix

    # Set Docker socket permissions
    chmod 666 /var/run/docker.sock
fi

# Set proper permissions
print_color "Setting permissions..." "info"
chown zabbix:zabbix /etc/zabbix/zabbix_agent2.conf
chmod 644 /etc/zabbix/zabbix_agent2.conf

# Start and enable Zabbix agent
print_color "Starting Zabbix agent service..." "info"
systemctl enable zabbix-agent2
systemctl restart zabbix-agent2

# Check service status
if systemctl is-active --quiet zabbix-agent2; then
    print_color "Zabbix agent service is running successfully." "success"
else
    print_color "Warning: Zabbix agent service is not running. Please check the logs." "warning"
fi

# Display configuration information
print_color "\n=== Configuration Information ===" "info"
print_color "System Hostname: ${SYSTEM_HOSTNAME}" "success"
print_color "Zabbix Hostname: ${PREFIXED_HOSTNAME}" "success"
print_color "PSK Identity: ${PSK_IDENTITY}" "success"
print_color "PSK Key: $(cat /etc/zabbix/psk/zabbix.psk)" "success"
print_color "\nMonitoring Mode: Hybrid (Both Active and Passive supported)" "success"
print_color "Agent IP Address: $(hostname -I | awk '{print $1}')" "success"

# Display service status and logs
print_color "\n=== Service Status ===" "info"
systemctl status zabbix-agent2

print_color "\n=== Recent Logs ===" "info"
tail -n 10 /var/log/zabbix/zabbix_agent2.log

print_color "\nInstallation complete!" "success"
print_color "Don't forget to:" "info"
print_color "1. Add this host in Zabbix frontend with:" "info"
print_color "   - Host name: ${PREFIXED_HOSTNAME}" "info"
print_color "   - IP Address: $(hostname -I | awk '{print $1}')" "info"
print_color "   - Port: 10050" "info"
print_color "   - PSK identity and key shown above" "info"
print_color "   - Can use both active and passive templates" "info"
print_color "2. Configure your firewall to:" "info"
print_color "   - Allow incoming connections from ${ZABBIX_HOST} on port 10050 (for passive checks)" "info"
print_color "   - Allow outgoing connections to ${ZABBIX_HOST} on port ${ZABBIX_PORT} (for active checks)" "info"
print_color "3. Test connections:" "info"
print_color "   Passive check:" "info"
print_color "   zabbix_get -s $(hostname -I | awk '{print $1}') -p 10050 -k agent.ping --tls-connect psk --tls-psk-identity \"${PSK_IDENTITY}\" --tls-psk-file /etc/zabbix/psk/zabbix.psk" "info"
print_color "   Active check (from agent):" "info"
print_color "   zabbix_agent2 -t agent.ping" "info"

if [ -f /etc/zabbix/zabbix_agent2.conf.bak.* ]; then
    print_color "\nNote: Your previous configuration was backed up with timestamp" "warning"
fi

if [ "$DOCKER_INSTALLED" = true ]; then
    print_color "\nDocker monitoring has been configured!" "success"
fi
