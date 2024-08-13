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

# Modify sources.list to include non-free and contrib repository
SOURCES_DIR="config/archives"
mkdir -p $SOURCES_DIR
cat <<EOF > $SOURCES_DIR/my-sources.list.chroot
deb http://deb.debian.org/debian/ bookworm main contrib non-free non-free-firmware
deb-src http://deb.debian.org/debian/ bookworm main contrib non-free non-free-firmware
deb http://deb.debian.org/debian-security/ bookworm-security main contrib non-free non-free-firmware
deb-src http://deb.debian.org/debian-security/ bookworm-security main contrib non-free non-free-firmware
deb http://deb.debian.org/debian/ bookworm-updates main contrib non-free non-free-firmware
deb-src http://deb.debian.org/debian/ bookworm-updates main contrib non-free non-free-firmware
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
rofi
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
sed -i 's/^greeter-hide-users=true/greeter-hide-users=false/' /usr/share/lightdm
