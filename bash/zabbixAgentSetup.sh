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

# Configuration for Proxmox SMART and ZFS monitoring
SUDOERS_FILENAME="zabbix"
SUDOERS_FILEPATH="/etc/sudoers.d/${SUDOERS_FILENAME}"
SMARTCTL_PATH="/usr/sbin/smartctl"
SUDO_RULE="zabbix ALL=(ALL) NOPASSWD: ${SMARTCTL_PATH}"
REQUIRED_PERMISSIONS="0440"
ZFS_USERPARAMS_URL="https://raw.githubusercontent.com/bartmichu/zfs-zabbix-userparams/refs/heads/main/zfs-userparams.conf"
ZFS_USERPARAMS_DEST="/etc/zabbix/zabbix_agent2.d/zfs-userparams.conf"

# Detect if system is running Proxmox
IS_PROXMOX=false
if [ -f "/usr/bin/pveversion" ] || grep -q "proxmox" /proc/version 2>/dev/null; then
    IS_PROXMOX=true
    print_color "Proxmox VE detected. Will enable additional monitoring capabilities." "info"
fi

# Detect if ZFS is in use
HAS_ZFS=false
INSTALL_ZFS=false
if command -v zfs &> /dev/null && zfs list &> /dev/null; then
    HAS_ZFS=true
    print_color "ZFS filesystem detected. ZFS monitoring will be available." "info"
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
read -p "Enter Zabbix version (6, 7, or specific like 7.0.12, default is 7.0 LTS): " ZABBIX_VERSION_INPUT

# Determine Zabbix version based on input
if [ -z "$ZABBIX_VERSION_INPUT" ]; then
    # Default to LTS version if nothing provided
    ZABBIX_VERSION="7.0.12"  # Latest 7.0.x LTS version
    ZABBIX_MAJOR_VERSION="7.0"
elif [ "$ZABBIX_VERSION_INPUT" = "6" ]; then
    ZABBIX_VERSION="6.4.21"  # Latest 6.x version
    ZABBIX_MAJOR_VERSION="6.4"
elif [ "$ZABBIX_VERSION_INPUT" = "7" ]; then
    ZABBIX_VERSION="7.0.12"  # Latest 7.0.x LTS version
    ZABBIX_MAJOR_VERSION="7.0"
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
            print_color "Unsupported version format. Using LTS version 7.0.12." "warning"
            ZABBIX_VERSION="7.0.12"
            ZABBIX_MAJOR_VERSION="7.0"
            ;;
    esac
    ZABBIX_MAJOR_VERSION="$ZABBIX_VERSION_INPUT"
elif [[ "$ZABBIX_VERSION_INPUT" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    # Full version provided
    ZABBIX_VERSION="$ZABBIX_VERSION_INPUT"
    ZABBIX_MAJOR_VERSION=$(echo "$ZABBIX_VERSION" | cut -d'.' -f1,2)
else
    # Invalid format, use default
    print_color "Invalid version format. Using LTS version 7.0.12." "warning"
    ZABBIX_VERSION="7.0.12"
    ZABBIX_MAJOR_VERSION="7.0"
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

# Check for existing Zabbix agent installations
print_color "Checking for existing Zabbix agent installations..." "info"

# Check for zabbix-agent (old version)
if dpkg -l | grep -q "zabbix-agent "; then
    print_color "Found old Zabbix Agent (zabbix-agent) installation." "warning"
    
    read -p "Do you want to remove the old Zabbix Agent installation? (y/n): " remove_old_agent
    case $remove_old_agent in
        [Yy]* )
            print_color "Removing old Zabbix Agent (zabbix-agent)..." "info"
            
            # Stop the service if running
            if systemctl is-active --quiet zabbix-agent; then
                systemctl stop zabbix-agent
            fi

            # Disable the service
            systemctl disable zabbix-agent 2>/dev/null || true

            # Remove the package
            apt remove --purge -y zabbix-agent
            apt autoremove -y

            # Ensure removal of any leftover files
            rm -rf /etc/zabbix/zabbix_agentd.conf* 2>/dev/null

            print_color "Old Zabbix Agent removed successfully." "success"
            ;;
        * )
            print_color "Keeping old Zabbix Agent installation. This might cause conflicts." "warning"
            print_color "You may need to manually ensure both agents can run simultaneously." "warning"
            ;;
    esac
fi

# Check for zabbix-proxy (remove if found)
if dpkg -l | grep -q "zabbix-proxy"; then
    print_color "Found Zabbix Proxy installation. This might conflict with the agent installation." "warning"
    read -p "Do you want to remove Zabbix Proxy? (y/n): " remove_proxy
    case $remove_proxy in
        [Yy]* )
            # Stop the service if running
            if systemctl is-active --quiet zabbix-proxy; then
                systemctl stop zabbix-proxy
            fi
            # Disable the service
            systemctl disable zabbix-proxy 2>/dev/null || true
            # Remove the package
            apt remove --purge -y zabbix-proxy\*
            print_color "Zabbix Proxy removed successfully." "success"
            ;;
        * )
            print_color "Keeping Zabbix Proxy installation. This might cause conflicts." "warning"
            ;;
    esac
fi

# Check for existing zabbix-agent2
if dpkg -l | grep -q "zabbix-agent2"; then
    print_color "Found existing Zabbix Agent 2 installation." "info"
    
    # Get the version information
    CURRENT_VERSION=$(dpkg -l | grep zabbix-agent2 | awk '{print $3}')
    print_color "Installed version: $CURRENT_VERSION" "info"
    print_color "Target version: $ZABBIX_VERSION" "info"

    # Check for existing configuration and create backup
    if [ -f /etc/zabbix/zabbix_agent2.conf ]; then
        print_color "Creating backup of existing configuration..." "info"
        cp /etc/zabbix/zabbix_agent2.conf /etc/zabbix/zabbix_agent2.conf.bak.$(date +%Y%m%d_%H%M%S)
        print_color "Backup created at /etc/zabbix/zabbix_agent2.conf.bak.$(date +%Y%m%d_%H%M%S)" "success"
    fi

    # Explain to the user their options
    print_color "\nYou have the following options:" "info"
    print_color "1. Remove the existing Zabbix Agent 2 completely and install fresh" "info"
    print_color "2. Keep the existing installation and update its configuration only" "info"
    print_color "   (This is useful if you want to maintain the existing version)" "info"
    
    # Ask if user wants to remove the existing installation
    read -p "Do you want to remove the existing Zabbix Agent 2 installation? (y/n): " remove_existing
    case $remove_existing in
        [Yy]* )
            # Stop the service if running
            if systemctl is-active --quiet zabbix-agent2; then
                print_color "Stopping Zabbix Agent 2 service..." "info"
                systemctl stop zabbix-agent2
            fi
            
            print_color "Removing existing Zabbix Agent 2..." "info"
            apt remove --purge -y zabbix-agent2
            print_color "Existing Zabbix Agent 2 removed successfully." "success"
            ;;
        * )
            print_color "Keeping existing Zabbix Agent 2 installation." "info"
            print_color "Will update configuration only." "info"
            print_color "Note: This will not upgrade/downgrade the agent version." "warning"
            ;;
    esac
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

# Determine OS distribution and version
print_color "Detecting operating system..." "info"
OS_TYPE=""
OS_VERSION=""

# Check for /etc/os-release
if [ -f "/etc/os-release" ]; then
    . /etc/os-release
    OS_TYPE="$ID"
    OS_VERSION="$VERSION_ID"
fi

# If still not set, try other methods
if [ -z "$OS_TYPE" ]; then
    if [ -f "/etc/debian_version" ]; then
        OS_TYPE="debian"
        OS_VERSION=$(cat /etc/debian_version)
    elif [ -f "/etc/lsb-release" ]; then
        . /etc/lsb-release
        OS_TYPE="$DISTRIB_ID"
        OS_VERSION="$DISTRIB_RELEASE"
    fi
fi

# Convert OS_TYPE to lowercase
OS_TYPE=$(echo "$OS_TYPE" | tr '[:upper:]' '[:lower:]')

# Define repository path based on OS
REPO_URL="https://repo.zabbix.com/zabbix/${ZABBIX_MAJOR_VERSION}"
DEB_FILE_BASE="zabbix-release_${ZABBIX_MAJOR_VERSION}"

if [[ "$OS_TYPE" == "ubuntu" ]]; then
    print_color "Detected Ubuntu $OS_VERSION" "info"
    REPO_PATH="${REPO_URL}/ubuntu/pool/main/z/zabbix-release"
    DEB_FILE="${DEB_FILE_BASE}-1+ubuntu${OS_VERSION}_all.deb"
    ALT_DEB_FILE="${DEB_FILE_BASE}-4+ubuntu${OS_VERSION}_all.deb"
elif [[ "$OS_TYPE" == "debian" ]] || [[ "$OS_TYPE" == "proxmox" ]]; then
    print_color "Detected Debian-based system (${OS_TYPE} ${OS_VERSION})" "info"
    REPO_PATH="${REPO_URL}/debian/pool/main/z/zabbix-release"
    DEB_FILE="${DEB_FILE_BASE}-1+debian${OS_VERSION}_all.deb"
    ALT_DEB_FILE="${DEB_FILE_BASE}-4+debian${OS_VERSION}_all.deb"
    # For Debian 11 (Bullseye)
    if [[ "$OS_VERSION" == "11" ]] || [[ "$OS_VERSION" == "bullseye"* ]]; then
        DEB_FILE="${DEB_FILE_BASE}-1+debian11_all.deb"
        ALT_DEB_FILE="${DEB_FILE_BASE}-4+debian11_all.deb"
    # For Debian 12 (Bookworm)
    elif [[ "$OS_VERSION" == "12" ]] || [[ "$OS_VERSION" == "bookworm"* ]]; then
        DEB_FILE="${DEB_FILE_BASE}-1+debian12_all.deb"
        ALT_DEB_FILE="${DEB_FILE_BASE}-4+debian12_all.deb"
    fi
else
    print_color "Unknown distribution: $OS_TYPE. Will attempt to use Debian repository." "warning"
    REPO_PATH="${REPO_URL}/debian/pool/main/z/zabbix-release"
    DEB_FILE="${DEB_FILE_BASE}-1+debian11_all.deb"  # Default to Debian 11
    ALT_DEB_FILE="${DEB_FILE_BASE}-4+debian11_all.deb"
fi

# Clean up any previous downloads
rm -f zabbix-release_*.deb 2>/dev/null

# Add the appropriate repository
print_color "Downloading Zabbix repository package from $REPO_PATH..." "info"
if ! wget -q "${REPO_PATH}/${DEB_FILE}"; then
    print_color "Failed to download repository package. Trying alternative URL format..." "warning"
    if ! wget -q "${REPO_PATH}/${ALT_DEB_FILE}"; then
        # Try with Debian 11 as fallback
        print_color "Failed with standard URLs. Trying Debian 11 repository as fallback..." "warning"
        FALLBACK_DEB="${DEB_FILE_BASE}-1+debian11_all.deb"
        if ! wget -q "https://repo.zabbix.com/zabbix/${ZABBIX_MAJOR_VERSION}/debian/pool/main/z/zabbix-release/${FALLBACK_DEB}"; then
            print_color "Failed to download repository package. Please check your internet connection and Zabbix version." "error"
            exit 1
        fi
    fi
fi

# Install the repository package
print_color "Installing Zabbix repository..." "info"
if ! dpkg -i zabbix-release_*.deb; then
    print_color "Failed to install Zabbix repository. Please check the package." "error"
    exit 1
fi

# Update package lists
apt update

# Remove any other zabbix packages that might cause conflicts
print_color "Checking for any other Zabbix packages..." "info"
ZABBIX_PACKAGES=$(dpkg -l | grep zabbix | grep -v "zabbix-agent2\|zabbix-release" | awk '{print $2}')
if [ -n "$ZABBIX_PACKAGES" ]; then
    print_color "Found other Zabbix packages that might conflict:" "warning"
    for pkg in $ZABBIX_PACKAGES; do
        print_color " - $pkg" "info"
    done
    
    read -p "Do you want to remove these potentially conflicting Zabbix packages? (y/n): " remove_conflicting
    case $remove_conflicting in
        [Yy]* )
            for pkg in $ZABBIX_PACKAGES; do
                print_color "Removing package: $pkg" "info"
                apt remove --purge -y "$pkg"
            done
            print_color "Conflicting packages removed." "success"
            ;;
        * )
            print_color "Keeping existing Zabbix packages. This might cause conflicts." "warning"
            print_color "Installation will proceed, but you might encounter issues." "warning"
            ;;
    esac
fi

# Verify repository was properly added and fix if needed
if [ ! -f /etc/apt/sources.list.d/zabbix.list ]; then
    print_color "Zabbix repository not properly added. Creating manually..." "warning"
    
    # Create repository file based on OS and version
    if [[ "$OS_TYPE" == "debian" ]] || [[ "$OS_TYPE" == "proxmox" ]]; then
        # For Debian-based systems
        if [[ "$OS_VERSION" == "11" ]] || [[ "$OS_VERSION" == "bullseye"* ]]; then
            # Debian 11 (Bullseye)
            cat > /etc/apt/sources.list.d/zabbix.list << EOF
deb https://repo.zabbix.com/zabbix/${ZABBIX_MAJOR_VERSION}/debian bullseye main
deb-src https://repo.zabbix.com/zabbix/${ZABBIX_MAJOR_VERSION}/debian bullseye main
EOF
        elif [[ "$OS_VERSION" == "12" ]] || [[ "$OS_VERSION" == "bookworm"* ]]; then
            # Debian 12 (Bookworm)
            cat > /etc/apt/sources.list.d/zabbix.list << EOF
deb https://repo.zabbix.com/zabbix/${ZABBIX_MAJOR_VERSION}/debian bookworm main
deb-src https://repo.zabbix.com/zabbix/${ZABBIX_MAJOR_VERSION}/debian bookworm main
EOF
        else
            # Generic Debian fallback
            cat > /etc/apt/sources.list.d/zabbix.list << EOF
deb https://repo.zabbix.com/zabbix/${ZABBIX_MAJOR_VERSION}/debian bullseye main
deb-src https://repo.zabbix.com/zabbix/${ZABBIX_MAJOR_VERSION}/debian bullseye main
EOF
        fi
    else
        # For Ubuntu
        cat > /etc/apt/sources.list.d/zabbix.list << EOF
deb https://repo.zabbix.com/zabbix/${ZABBIX_MAJOR_VERSION}/ubuntu $(lsb_release -cs) main
deb-src https://repo.zabbix.com/zabbix/${ZABBIX_MAJOR_VERSION}/ubuntu $(lsb_release -cs) main
EOF
    fi
    
    # Import the GPG key
    print_color "Importing Zabbix GPG key..." "info"
    wget -q -O - https://repo.zabbix.com/zabbix-official-repo.key | apt-key add -
fi

# Update apt lists
print_color "Updating package lists with new repository..." "info"
apt update

# Install Zabbix agent 2
print_color "Installing Zabbix agent 2..." "info"

# Check available packages to debug
print_color "Checking available Zabbix packages..." "info"
apt-cache search zabbix | grep agent

# Special handling for Debian/Proxmox systems
if [[ "$OS_TYPE" == "debian" ]] || [[ "$OS_TYPE" == "proxmox" ]]; then
    print_color "Using Debian-specific installation method..." "info"
    
    # Install required dependencies first
    apt install -y libpcre3 zlib1g

    # Try to install with apt
    if apt install -y zabbix-agent2; then
        print_color "Zabbix Agent 2 installed successfully." "success"
    else
        # If standard install fails, try forcing the architecture
        print_color "Standard apt install failed. Trying specific installation method for Debian..." "warning"
        
        # Temporary directory for downloads
        TEMP_DIR=$(mktemp -d)
        cd $TEMP_DIR

        # Determine architecture
        ARCH=$(dpkg --print-architecture)
        print_color "System architecture: $ARCH" "info"
        
        # Try to download the package directly - first attempt
        DEB_URL="https://repo.zabbix.com/zabbix/${ZABBIX_MAJOR_VERSION}/debian/pool/main/z/zabbix/zabbix-agent2_${ZABBIX_VERSION}-1+debian11_${ARCH}.deb"
        print_color "Downloading package from: $DEB_URL" "info"
        
        if wget -q "$DEB_URL"; then
            print_color "Package downloaded. Installing..." "info"
            if dpkg -i zabbix-agent2_*.deb; then
                apt --fix-broken install -y
                print_color "Zabbix Agent 2 installed successfully via direct download." "success"
            else
                print_color "Failed to install downloaded package. Trying alternative method..." "warning"
                apt-get update && apt-get install -y --no-install-recommends zabbix-agent2
                if [ $? -ne 0 ]; then
                    print_color "First installation method failed. Trying additional methods..." "warning"
                    # Continue to next method
                fi
            fi
        else
            print_color "Failed to download package. Trying alternative URL format..." "warning"
            
            # Second attempt - try with different version format
            ALT_DEB_URL="https://repo.zabbix.com/zabbix/${ZABBIX_MAJOR_VERSION}/debian/pool/main/z/zabbix/zabbix-agent2_${ZABBIX_MAJOR_VERSION}.0-1+debian11_${ARCH}.deb"
            print_color "Downloading package from: $ALT_DEB_URL" "info"
            
            if wget -q "$ALT_DEB_URL"; then
                print_color "Package downloaded. Installing..." "info"
                if dpkg -i zabbix-agent2_*.deb; then
                    apt --fix-broken install -y
                    print_color "Zabbix Agent 2 installed successfully via direct download (alternative URL)." "success"
                else
                    print_color "Failed to install downloaded package. Continuing to next method..." "warning"
                    # Continue to next method
                fi
            else
                print_color "Failed to download from alternative URL. Continuing to next method..." "warning"
                # Continue to next method
            fi
        fi
        
        # Try with older version as fallback (may remove this part if unnecessary)
        if ! dpkg -l | grep -q "zabbix-agent2"; then
            FALLBACK_VERSION="6.0.19"
            FALLBACK_URL="https://repo.zabbix.com/zabbix/6.0/debian/pool/main/z/zabbix/zabbix-agent2_${FALLBACK_VERSION}-1+debian11_${ARCH}.deb"
            print_color "Trying fallback version ${FALLBACK_VERSION}..." "warning"
            
            if wget -q "$FALLBACK_URL"; then
                print_color "Fallback package downloaded. Installing..." "info"
                if dpkg -i zabbix-agent2_*.deb; then
                    apt --fix-broken install -y
                    print_color "Fallback Zabbix Agent 2 ${FALLBACK_VERSION} installed successfully." "success"
                else
                    print_color "Failed to install fallback package. Continuing to next method..." "warning"
                fi
            else
                print_color "Failed to download fallback package. Continuing to next method..." "warning"
            fi
        fi
        
        # Final attempt - try apt-get
        if ! dpkg -l | grep -q "zabbix-agent2"; then
            print_color "Trying standard repository installation as final attempt..." "info"
            apt-get update && apt-get install -y --no-install-recommends zabbix-agent2
            if [ $? -ne 0 ]; then
                print_color "All installation methods failed. Please check repository configuration." "error"
                print_color "You may need to manually download and install zabbix-agent2." "error"
                cd - > /dev/null
                rm -rf $TEMP_DIR
                exit 1
            fi
        fi
        
        # Clean up
        cd - > /dev/null
        rm -rf $TEMP_DIR
    fi
else
    # For Ubuntu systems, use the standard method
    # Try installing directly first
    if apt install -y zabbix-agent2; then
        print_color "Zabbix Agent 2 installed successfully." "success"
    else
        # If direct install fails, try apt-get as a fallback
        print_color "Standard apt install failed. Trying alternative installation method..." "warning"
        apt-get update && apt-get install -y zabbix-agent2
        
        if [ $? -ne 0 ]; then
            print_color "Failed to install zabbix-agent2. Please check repository configuration." "error"
            exit 1
        else
            print_color "Zabbix Agent 2 installed successfully with alternative method." "success"
        fi
    fi
fi

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

# Clean up installation files
print_color "Cleaning up installation files..." "info"
rm -f zabbix-release_*.deb 2>/dev/null

# Final cleanup of any temporary files
apt clean
apt autoremove -y

# Show backup info if relevant
if [ -f /etc/zabbix/zabbix_agent2.conf.bak.* ]; then
    print_color "\nNote: Your previous configuration was backed up with timestamp" "warning"
fi

if [ "$DOCKER_INSTALLED" = true ]; then
    print_color "\nDocker monitoring has been configured!" "success"
fi

# Setup Proxmox-specific monitoring if detected
if [ "$IS_PROXMOX" = true ]; then
    print_color "\n=== Setting up Proxmox-specific monitoring ===" "info"
    
    # SMART monitoring setup
    print_color "Setting up SMART monitoring for Zabbix on Proxmox..." "info"
    
    # Ensure sudo package is installed
    if ! command -v sudo &> /dev/null; then
        print_color "Installing sudo package..." "info"
        apt-get update > /dev/null || print_color "Warning: apt-get update failed, proceeding anyway..." "warning"
        apt-get install -y sudo
    fi
    
    # Create sudoers file for SMART monitoring
    print_color "Creating sudoers file '${SUDOERS_FILEPATH}' with SMART monitoring rule..." "info"
    echo "${SUDO_RULE}" > "${SUDOERS_FILEPATH}"
    
    # Set permissions
    print_color "Setting permissions (${REQUIRED_PERMISSIONS}) for '${SUDOERS_FILEPATH}'..." "info"
    chmod "${REQUIRED_PERMISSIONS}" "${SUDOERS_FILEPATH}"
    
    # Validate sudoers configuration
    print_color "Validating sudoers configuration..." "info"
    if ! visudo -c; then
        print_color "Visudo check failed! The sudo configuration might be broken. Please fix manually." "error"
        print_color "The problematic file might be '${SUDOERS_FILEPATH}'." "error"
    else
        print_color "SMART monitoring sudo configuration check successful." "success"
        print_color "User 'zabbix' should now be able to run '${SMARTCTL_PATH}' via sudo without a password." "success"
    fi
fi

# ZFS monitoring setup if ZFS is detected or if we're on Proxmox
if [ "$HAS_ZFS" = true ] || [ "$IS_PROXMOX" = true ]; then
    print_color "\n=== ZFS Monitoring Setup ===" "info"
    
    # If ZFS is actually detected, auto-install. If on Proxmox but ZFS not detected, prompt user
    if [ "$HAS_ZFS" = true ]; then
        # Auto-approve if ZFS is detected
        print_color "ZFS detected. Setting up ZFS monitoring automatically." "info"
        INSTALL_ZFS=true
    elif [ "$IS_PROXMOX" = true ]; then
        # Prompt if on Proxmox but ZFS not automatically detected
        read -p "Would you like to install ZFS monitoring for Zabbix? (y/n): " install_zfs_choice
        if [[ "${install_zfs_choice}" =~ ^[Yy]$ ]]; then
            INSTALL_ZFS=true
        fi
    fi
    
    if [ "$INSTALL_ZFS" = true ]; then
        print_color "Setting up ZFS monitoring for Zabbix..." "info"
        
        # Ensure zabbix_agent2.d directory exists
        zabbix_conf_dir=$(dirname "${ZFS_USERPARAMS_DEST}")
        if [[ ! -d "${zabbix_conf_dir}" ]]; then
            print_color "Creating Zabbix agent2 configuration directory: ${zabbix_conf_dir}" "info"
            mkdir -p "${zabbix_conf_dir}"
        fi
        
        # Install curl if not present
        if ! command -v curl &> /dev/null; then
            print_color "Installing curl..." "info"
            apt-get update && apt-get install -y curl
        fi
        
        # Download the ZFS monitoring configuration
        print_color "Downloading ZFS monitoring configuration from ${ZFS_USERPARAMS_URL}" "info"
        if ! curl -s -o "${ZFS_USERPARAMS_DEST}" "${ZFS_USERPARAMS_URL}"; then
            print_color "Failed to download ZFS monitoring configuration. Please check your internet connection." "error"
        else
            print_color "ZFS monitoring configuration downloaded to ${ZFS_USERPARAMS_DEST}" "success"
            
            # Restart Zabbix agent2
            print_color "Restarting Zabbix agent2 service to apply ZFS monitoring configuration..." "info"
            if systemctl is-active --quiet zabbix-agent2; then
                if systemctl restart zabbix-agent2; then
                    print_color "Zabbix agent2 service restarted successfully." "success"
                else
                    print_color "Failed to restart Zabbix agent2 service." "error"
                fi
            else
                print_color "Warning: Zabbix agent2 service is not active. Please start it manually after configuration." "warning"
            fi
            
            print_color "ZFS monitoring setup complete!" "success"
        fi
    fi
fi

# Final success message
print_color "\nZabbix Agent 2 version ${ZABBIX_VERSION} has been successfully installed!" "success"
if [ "$IS_PROXMOX" = true ]; then
    print_color "Proxmox-specific monitoring has been configured." "success"
fi
if [ "$HAS_ZFS" = true ] && [ "$INSTALL_ZFS" = true ]; then
    print_color "ZFS monitoring has been configured." "success"
fi