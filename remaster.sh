#!/bin/bash

# Log file for script execution
LOGFILE="live-build-setup.log"

# Update and install live-build
echo "Updating system and installing live-build..." | tee -a $LOGFILE
sudo apt-get update && sudo apt-get upgrade -y
sudo apt-get install -y live-build | tee -a $LOGFILE

# Set up live-build project directory
PROJECT_DIR="live-build-project"
if [ ! -d "$PROJECT_DIR" ]; then
    mkdir -p $PROJECT_DIR
fi
cd $PROJECT_DIR

# Configure live-build with Debian Installer
echo "Configuring live-build..." | tee -a $LOGFILE
lb config --distribution bookworm --debian-installer live | tee -a $LOGFILE

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
fonts-font-awesome
picom
numix-gtk-theme
numix-icon-theme
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

# Update GRUB configuration
update-grub

# Modify LightDM configuration to show user list
sed -i 's/^#greeter-hide-users=true/greeter-hide-users=false/' /usr/share/lightdm/lightdm.conf.d/01_debian.conf

# Clean up
rm -rf /tmp/remaster
EOF
chmod +x $HOOKS_DIR/99-custom-script.chroot

# Hostname script hook
cat <<EOF > $HOOKS_DIR/01-set-hostname.chroot
#!/bin/sh

# Set the hostname
echo "bee" > /etc/hostname

# Update /etc/hosts file
cat <<EOL >> /etc/hosts
127.0.0.1   bee
EOL
EOF
chmod +x $HOOKS_DIR/01-set-hostname.chroot

# Build the live system
echo "Building the live system..." | tee -a $LOGFILE
sudo lb build | tee -a $LOGFILE

echo "Live-build process completed." | tee -a $LOGFILE
