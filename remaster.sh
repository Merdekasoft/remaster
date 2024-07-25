#!/bin/bash

# Update and install live-build
sudo apt-get update
sudo apt-get install -y live-build

# Set up live-build project directory
mkdir -p live-build-project
cd live-build-project

# Configure live-build
lb config --distribution bookworm --debian-installer none

# Create the package list
mkdir -p config/package-lists
cat <<EOF > config/package-lists/my.list.chroot
i3
lightdm
xserver-xorg
xinit
git
mc
htop
slick-greeter
calamares
calamares-settings-debian
rxvt-unicode
alsa-utils
wget
feh
EOF

# Create and set up the custom script hook
mkdir -p config/hooks/live
cat <<EOF > config/hooks/live/99-custom-script.chroot
#!/bin/sh

# Download the firmware-misc-nonfree package
wget http://ftp.us.debian.org/debian/pool/non-free-firmware/f/firmware-nonfree/firmware-misc-nonfree_20230210-5_all.deb
dpkg -i firmware-misc-nonfree_20230210-5_all.deb
rm firmware-misc-nonfree_20230210-5_all.deb

EOF
chmod +x config/hooks/live/99-custom-script.chroot

# Build the live system
sudo lb build
