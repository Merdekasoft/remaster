#!/bin/bash

# Update and install live-build
echo "Updating system and installing live-build..."
sudo apt-get update && sudo apt-get upgrade -y
sudo apt-get install -y live-build 

# Set up live-build project directory
PROJECT_DIR="live-build-project"
if [ ! -d "$PROJECT_DIR" ]; then
    mkdir -p $PROJECT_DIR
fi
cd $PROJECT_DIR

# Configure live-build with Debian Installer
echo "Configuring live-build..."
lb config --distribution bookworm --debian-installer live

# Modify sources.list to include non-free repository
SOURCES_DIR="config/archives"
if [ ! -d "$SOURCES_DIR" ]; then
    mkdir -p $SOURCES_DIR
fi
cat <<EOF > $SOURCES_DIR/my-sources.list.chroot
deb http://deb.debian.org/debian/ bookworm main contrib non-free non-free-firmware
deb-src http://deb.debian.org/debian/ bookworm main contrib non-free non-free-firmware
EOF

# Create the package list
PKG_LIST_DIR="config/package-lists"
if [ ! -d "$PKG_LIST_DIR" ]; then
    mkdir -p $PKG_LIST_DIR
fi
cat <<EOF > $PKG_LIST_DIR/my.list.chroot
i3
sudo
ssh
python3-pip
python3-full
fonts-font-awesome
picom
numix-gtk-theme
papirus-icon-theme
lightdm
xserver-xorg
xinit
git
thunar
fonts-firacode
fonts-noto-color-emoji
htop
slick-greeter
rxvt-unicode
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
EOF

# Create and set up the custom script hook
HOOKS_DIR="config/hooks/live"
if [ ! -d "$HOOKS_DIR" ]; then
    mkdir -p $HOOKS_DIR
fi

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

# Clean up
rm -rf /tmp/remaster
EOF
chmod +x $HOOKS_DIR/99-custom-script.chroot

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

# Add firmware packages to Debian Installer
INSTALLER_PKGS_DIR="config/package-lists/installer"
if [ ! -d "$INSTALLER_PKGS_DIR" ]; then
    mkdir -p $INSTALLER_PKGS_DIR
fi
cat <<EOF > $INSTALLER_PKGS_DIR/firmware.list.binary
firmware-misc-nonfree
EOF

# Build the live system
echo "Building the live system..."
sudo lb build

echo "Live-build OK. Plymouth has been installed and configured. Please reboot your system."
