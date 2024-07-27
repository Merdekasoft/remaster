#!/bin/bash

# Update and install live-build
sudo apt-get update
sudo apt-get install -y live-build

# Set up live-build project directory
mkdir -p live-build-project
cd live-build-project

# Configure live-build with Debian Installer
lb config --distribution bookworm --debian-installer live

# Create the package list
mkdir -p config/package-lists
cat <<EOF > config/package-lists/my.list.chroot
i3
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
EOF

# Create and set up the custom script hook
mkdir -p config/hooks/live
cat <<EOF > config/hooks/live/99-custom-script.chroot
#!/bin/sh

# Download the firmware-misc-nonfree package
wget http://ftp.us.debian.org/debian/pool/non-free-firmware/f/firmware-nonfree/firmware-misc-nonfree_20230210-5_all.deb
dpkg -i firmware-misc-nonfree_20230210-5_all.deb
rm firmware-misc-nonfree_20230210-5_all.deb

# Clone the repository
git clone https://github.com/Merdekasoft/remaster.git /tmp/remaster

# Copy etc/skel to /etc/skel
cp -r /tmp/remaster/etc/skel /etc/

# Copy usr/share/backgrounds to /usr/share/backgrounds
cp -r /tmp/remaster/usr/share/backgrounds /usr/share/

# Clean up
rm -rf /tmp/remaster
EOF
chmod +x config/hooks/live/99-custom-script.chroot

# Build the live system
sudo lb build
