#!/bin/bash

# Function to check command success and exit on failure
check_success() {
    if [ $? -ne 0 ]; then
        echo "Error occurred during: $1"
        exit 1
    fi
}

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

# Create the package list
PKG_LIST_DIR="config/package-lists"
mkdir -p $PKG_LIST_DIR
cat <<EOF > $PKG_LIST_DIR/my.list.chroot
i3
sudo
python3-pip
python3-full
fonts-font-awesome
picom
materia-gtk-theme 
numix-gtk-theme
papirus-icon-theme
lightdm
xserver-xorg
lxappearance
xinit
synaptic
rxvt-unicode
man
featherpad
evince
file-roller
lxpolkit
ntp
git
inkscape
lximage-qt
simple-scan
flatpak
vim
vlc
firefox-esr
curl
libfuse2
pcmanfm
fonts-firacode
fonts-noto-color-emoji
htop
i3status
slick-greeter
flameshot
alsa-utils
wget
feh
plymouth 
plymouth-themes
breeze-cursor-theme
laptop-mode-tools
network-manager
network-manager-gnome
grub-pc
firmware-misc-nonfree
calamares
calamares-settings-debian
EOF
check_success "Creating package list"

# Create and set up the custom script hook
HOOKS_DIR="config/hooks/live"
mkdir -p $HOOKS_DIR

# Custom script hook
cat <<EOF > $HOOKS_DIR/99-custom-script.chroot
#!/bin/sh

# Clone the repository
git clone https://github.com/Merdekasoft/remaster.git /tmp/remaster

# Copy etc/skel to /etc/skel
cp -r /tmp/remaster/etc/skel /etc/

# Copy usr/share/backgrounds to /usr/share/backgrounds
cp -r /tmp/remaster/usr/share/backgrounds /usr/share/

# Ensure GRUB_DISABLE_OS_PROBER=false is in GRUB config
if grep -q '^#GRUB_DISABLE_OS_PROBER=false' /etc/default/grub; then
    sed -i 's/#GRUB_DISABLE_OS_PROBER=false/GRUB_DISABLE_OS_PROBER=false/' /etc/default/grub
else
    echo 'GRUB_DISABLE_OS_PROBER=false' >> /etc/default/grub
fi

# Modify LightDM configuration to show user list
sed -i 's/^greeter-hide-users=true/greeter-hide-users=false/' /usr/share/lightdm/lightdm.conf.d/01_debian.conf

# Enable Plymouth services
systemctl enable plymouth-start.service
systemctl enable plymouth-quit.service
systemctl enable plymouth-quit-wait.service

# Update GRUB configuration to include Plymouth
sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT="quiet"/GRUB_CMDLINE_LINUX_DEFAULT="quiet splash"/' /etc/default/grub

# Update GRUB configuration
update-grub

# Install Poly Dark theme
wget -P /tmp https://github.com/Merdekasoft/poly-dark/raw/master/install.sh
bash /tmp/install.sh --lang English

# Install Calamares
apt-get update
apt-get install -y calamares calamares-settings-debian

# Download and install Ulauncher
wget -P /tmp https://github.com/Ulauncher/Ulauncher/releases/download/5.15.7/ulauncher_5.15.7_all.deb
apt install -y /tmp/ulauncher_5.15.7_all.deb


# Reload systemd and enable Ulauncher service
systemctl daemon-reload
systemctl enable ulauncher.service
systemctl start ulauncher.service

# Clean up
rm -rf /tmp/remaster
rm /tmp/install.sh
rm /tmp/ulauncher_5.15.7_all.deb
EOF
chmod +x $HOOKS_DIR/99-custom-script.chroot
check_success "Setting up custom script hook"

# Hostname script hook
cat <<EOF > $HOOKS_DIR/01-set-hostname.chroot
#!/bin/sh

# Set the hostname
echo "BEE" > /etc/hostname

# Update /etc/hosts file
cat <<EOL >> /etc/hosts
127.0.0.1   BEE
EOL
EOF
chmod +x $HOOKS_DIR/01-set-hostname.chroot
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
