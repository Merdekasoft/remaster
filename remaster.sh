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

# Set up live-build project directory
PROJECT_DIR="live-build-project"
mkdir -p $PROJECT_DIR
cd $PROJECT_DIR

# Configure live-build without Debian Installer
echo "Configuring live-build..."
lb config --distribution bookworm --debian-installer none
check_success "Configuring live-build"

# Modify sources.list to include non-free repository
SOURCES_DIR="config/archives"
mkdir -p $SOURCES_DIR
cat <<EOF > $SOURCES_DIR/my-sources.list.chroot
deb http://deb.debian.org/debian/ bookworm main contrib non-free non-free-firmware
deb-src http://deb.debian.org/debian/ bookworm main contrib non-free non-free-firmware
EOF
check_success "Modifying sources.list"
EOF
check_success "Setting up hostname script hook"

# Build the live system
echo "Building the live system..."
lb build
check_success "Building the live system"

echo "Live-build OK. Plymouth has been installed and configured. Please reboot your system."

# Move the created ISO to the specified directory
ISO_OUTPUT_DIR="/var/www/html/iso/"
mv live-image-*.hybrid.iso $ISO_OUTPUT_DIR
check_success "Moving ISO to $ISO_OUTPUT_DIR"
