#!/bin/bash

# Update and install live-build
sudo apt-get update
sudo apt-get install -y live-build

# Set up live-build project directory
mkdir -p live-build-project
cd live-build-project

# Configure live-build with Debian Installer
lb config --distribution bookworm --debian-installer live

# Modify sources.list to include non-free repository
mkdir -p config/archives
cat <<EOF > config/archives/my-sources.list.chroot
deb http://deb.debian.org/debian/ bookworm main contrib non-free non-free-firmware
deb-src http://deb.debian.org/debian/ bookworm main contrib non-free non-free-firmware
EOF

# Create the package list
mkdir -p config/package-lists
cat <<EOF > config/package-lists/my.list.chroot
i3
sudo
fonts-font-awesome
picom
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
mkdir -p config/hooks/live
cat <<EOF > config/hooks/live/99-custom-script.chroot
#!/bin/sh

# Clone the repository
git clone https://github.com/Merdekasoft/remaster.git /tmp/remaster

# Copy etc/skel to /etc/skel
cp -r /tmp/remaster/etc/skel /etc/

# Copy usr/share/backgrounds to /usr/share/backgrounds
cp -r /tmp/remaster/usr/share/backgrounds /usr/share/

# Add GRUB_DISABLE_OS_PROBER=false to GRUB config
echo 'GRUB_DISABLE_OS_PROBER=false' >> /etc/default/grub

# Update GRUB configuration
update-grub

# Clean up
rm -rf /tmp/remaster
EOF
chmod +x config/hooks/live/99-custom-script.chroot

# Build the live system
sudo lb build
