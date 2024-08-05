#!/bin/bash

# Function to check command success and exit on failure
check_success() {
    if [ $? -ne 0 ]; then
        echo "Error occurred during: $1"
        exit 1
    fi
}

# Ensure the script is running with root privileges
if [ "$EUID" -ne 0 ]; then
    echo "Please run as root"
    exit 1
fi

# Update and install live-build
echo "Updating system and installing live-build..."
apt-get update && apt-get upgrade -y
check_success "System update and upgrade"

apt-get install -y live-build git wget curl
check_success "Installing live-build and dependencies"

# Configure live-build without Debian Installer
echo "Configuring live-build..."
lb config --distribution bookworm --debian-installer none
check_success "Configuring live-build"


chmod +x config/hooks/live/0100-copy-sources.hook.chroot

# Build the live system
echo "Building the live system..."
lb build
check_success "Building the live system"

# Move the created ISO to the specified directory
ISO_OUTPUT_DIR="/var/www/html/iso/"
mv live-image-*.hybrid.iso $ISO_OUTPUT_DIR
check_success "Moving ISO to $ISO_OUTPUT_DIR"

echo "Live-build OK. Please reboot your system if necessary."
