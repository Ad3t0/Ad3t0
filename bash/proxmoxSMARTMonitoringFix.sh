#!/usr/bin/env bash

# Script to configure sudo for Zabbix smartctl monitoring
# Based on steps for Proxmox 8.3 / Zabbix 7.0.6

# --- Configuration ---
SUDOERS_FILENAME="zabbix"
SUDOERS_FILEPATH="/etc/sudoers.d/${SUDOERS_FILENAME}"
SMARTCTL_PATH="/usr/sbin/smartctl" # The command Zabbix needs to run
SUDO_RULE="zabbix ALL=(ALL) NOPASSWD: ${SMARTCTL_PATH}"
REQUIRED_PERMISSIONS="0440"
# --- End Configuration ---

# Exit immediately if a command exits with a non-zero status.
set -e

# --- Functions ---
log() {
    echo "[INFO] $1"
}

error() {
    echo "[ERROR] $1" >&2
    exit 1
}

# --- Sanity Checks ---
# Check if running as root
if [[ "$(id -u)" -ne 0 ]]; then
   error "This script must be run as root or using sudo."
fi

# Check if smartctl exists (optional but helpful)
if [[ ! -x "${SMARTCTL_PATH}" ]]; then
    log "Warning: ${SMARTCTL_PATH} not found or not executable. The sudo rule might point to a non-existent command."
    # Decide if you want to stop or continue. Continuing allows setup even if smartmontools is installed later.
    # error "${SMARTCTL_PATH} not found or not executable. Aborting."
fi

# --- Main Script Logic ---

log "Step 1: Ensuring sudo package is installed..."
# Use apt-get for compatibility, common on Proxmox (Debian-based)
if command -v apt-get &> /dev/null; then
    # Run update quietly unless there's an error
    apt-get update > /dev/null || log "Warning: apt-get update failed, proceeding anyway..."
    apt-get install -y sudo
    log "Sudo is installed."
else
    log "Warning: apt-get not found. Assuming 'sudo' is already installed or managed differently."
fi

log "Step 2 & 3: Creating sudoers file '${SUDOERS_FILEPATH}' with the rule..."
# Use echo to write the rule. This will overwrite the file if it exists.
echo "${SUDO_RULE}" > "${SUDOERS_FILEPATH}"
log "Rule '${SUDO_RULE}' written to ${SUDOERS_FILEPATH}."

log "Step 4: Setting permissions (${REQUIRED_PERMISSIONS}) for '${SUDOERS_FILEPATH}'..."
# Set permissions to 0440 (read-only for root user and root group)
chmod "${REQUIRED_PERMISSIONS}" "${SUDOERS_FILEPATH}"
log "Permissions set to ${REQUIRED_PERMISSIONS}."

log "Step 5: Validating sudoers configuration using 'visudo -c'..."
if visudo -c; then
    log "Sudo configuration check successful."
else
    # visudo already printed the specific error to stderr
    error "visudo check failed! The sudo configuration might be broken. Please fix manually. The problematic file might be '${SUDOERS_FILEPATH}'."
    # Avoid exiting with set -e if visudo fails, give a custom message
    exit 1
fi

log "-----------------------------------------------------"
log "Setup complete!"
log "User 'zabbix' should now be able to run '${SMARTCTL_PATH}' via sudo without a password."
log "Configuration file: ${SUDOERS_FILEPATH}"
log "Rule added: ${SUDO_RULE}"
log "Permissions: ${REQUIRED_PERMISSIONS}"
log "-----------------------------------------------------"

exit 0