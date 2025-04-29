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

# Prompt for Host Prefix (now allows empty prefix)
read -p "Enter Host Prefix (leave empty to use hostname only): " HOST_PREFIX

# Prompt for Zabbix version
read -p "Enter Zabbix version (6, 7, or specific like 7.0.12, default is 7): " ZABBIX_VERSION_INPUT

# Determine Zabbix version based on input
if [ -z "$ZABBIX_VERSION_INPUT" ]; then
    # Default to latest major version if nothing provided
    ZABBIX_VERSION="7.2.6"  # Latest 7.x version
    ZABBIX_MAJOR_VERSION="7.2"
elif [ "$ZABBIX_VERSION_INPUT" = "6" ]; then
    ZABBIX_VERSION="6.4.21"  # Latest 6.x version
    ZABBIX_MAJOR_VERSION="6.4"
elif [ "$ZABBIX_VERSION_INPUT" = "7" ]; then
    ZABBIX_VERSION="7.2.6"  # Latest 7.x version
    ZABBIX_MAJOR_VERSION="7.2"
elif [[ "$ZABBIX_VERSION_INPUT" =~ ^[0-9]+\.[0-9]+$ ]]; then
    # Major.Minor version provided (e.g. "6.4" or "7.0")
    case "$ZABBIX_VERSION_INPUT" in
        "6.4")
            ZABBIX_VERSION="6.4.21"
            ;;
        "7.0")
            ZABBIX_VERSION="7.0.12"
            ;;
        "7.2")
            ZABBIX_VERSION="7.2.6"
            ;;
        *)
            print_color "Unsupported version format. Using latest version 7.2.6." "warning"
            ZABBIX_VERSION="7.2.6"
            ZABBIX_MAJOR_VERSION="7.2"
            ;;
    esac
    ZABBIX_MAJOR_VERSION="$ZABBIX_VERSION_INPUT"
elif [[ "$ZABBIX_VERSION_INPUT" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    # Full version provided
    ZABBIX_VERSION="$ZABBIX_VERSION_INPUT"
    ZABBIX_MAJOR_VERSION=$(echo "$ZABBIX_VERSION" | cut -d'.' -f1,2)
else
    # Invalid format, use default
    print_color "Invalid version format. Using latest version 7.2.6." "warning"
    ZABBIX_VERSION="7.2.6"
    ZABBIX_MAJOR_VERSION="7.2"
fi

print_color "Selected Zabbix version: $ZABBIX_VERSION" "success"

# Set fixed Zabbix port
ZABBIX_PORT="10051"

# Display configured values
print_color "\nConfiguration Summary:" "info"
print_color "Zabbix Host: $ZABBIX_HOST" "success"
print_color "Zabbix Port: $ZABBIX_PORT" "success"
if [ -n "$HOST_PREFIX" ]; then
    print_color "Host Prefix: $HOST_PREFIX" "success"
else
    print_color "Host Prefix: None (using hostname only)" "success"
fi
print_color "Zabbix Version: $ZABBIX_VERSION" "success"

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

# Add Zabbix repository based on version
print_color "Adding Zabbix repository for version $ZABBIX_MAJOR_VERSION..." "info"

# Determine Ubuntu version
UBUNTU_VERSION=$(lsb_release -rs)
if [[ "$UBUNTU_VERSION" == "22.04" ]]; then
    UBUNTU_CODENAME="jammy"
elif [[ "$UBUNTU_VERSION" == "20.04" ]]; then
    UBUNTU_CODENAME="focal"
elif [[ "$UBUNTU_VERSION" == "18.04" ]]; then
    UBUNTU_CODENAME="bionic"
else
    UBUNTU_CODENAME="jammy" # Default to 22.04
    print_color "Warning: Unsupported Ubuntu version. Defaulting to Ubuntu 22.04 repository." "warning"
fi

# Add the appropriate repository
wget "https://repo.zabbix.com/zabbix/${ZABBIX_MAJOR_VERSION}/ubuntu/pool/main/z/zabbix-release/zabbix-release_${ZABBIX_MAJOR_VERSION}-1+ubuntu${UBUNTU_VERSION}_all.deb"
dpkg -i "zabbix-release_${ZABBIX_MAJOR_VERSION}-1+ubuntu${UBUNTU_VERSION}_all.deb"
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
if [ -n "$HOST_PREFIX" ]; then
    PREFIXED_HOSTNAME="${HOST_PREFIX}-${SYSTEM_HOSTNAME}"
else
    PREFIXED_HOSTNAME="${SYSTEM_HOSTNAME}"
fi
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
print_color "Zabbix Version: ${ZABBIX_VERSION}" "success"
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