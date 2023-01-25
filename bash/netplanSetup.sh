#!/bin/bash

# Get the default adapter
DEFAULT_ADAPTER=$(ip route | grep default | awk '{print $5}')

# Ask for the IP address
IPADDR=$(whiptail --title "IP Address" --inputbox "Enter the IP address:" 10 60 3>&1 1>&2 2>&3)

# Ask for the netmask
NETMASK=$(whiptail --title "Netmask" --inputbox "Enter the netmask:" 10 60 3>&1 1>&2 2>&3)

# Ask for the gateway
GATEWAY=$(whiptail --title "Default Gateway" --inputbox "Enter the default gateway:" 10 60 3>&1 1>&2 2>&3)

# Ask for the DNS servers
DNS1=$(whiptail --title "DNS Server 1" --inputbox "Enter the primary DNS server:" 10 60 3>&1 1>&2 2>&3)
DNS2=$(whiptail --title "DNS Server 2" --inputbox "Enter the secondary DNS server:" 10 60 3>&1 1>&2 2>&3)

# Ask for the Search domain
SEARCH_DOMAIN=$(whiptail --title "Search Domain" --inputbox "Enter the search domain:" 10 60 3>&1 1>&2 2>&3)

#Ask for the hostname
HOSTNAME=$(whiptail --title "Hostname" --inputbox "Enter the hostname:" 10 60 3>&1 1>&2 2>&3)

# Create the netplan config file
sudo bash -c "echo 'network:
  version: 2
  renderer: networkd
  ethernets:
    $DEFAULT_ADAPTER:
      dhcp4: no
      addresses: [$IPADDR/$NETMASK]
      gateway4: $GATEWAY
      nameservers:
        addresses: [$DNS1,$DNS2]
        search: [$SEARCH_DOMAIN]' > /etc/netplan/01-netcfg.yaml"

# set hostname
sudo hostnamectl set-hostname $HOSTNAME

# Ask if the user wants to apply the config
if (whiptail --title "Apply config" --yesno "Do you want to apply the config now?" 10 60) then
    sudo netplan apply
else
    echo "The config will not be applied. You can apply it later by running 'sudo netplan apply'"
fi
