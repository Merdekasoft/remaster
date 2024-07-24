# Install live-build
sudo apt-get update
sudo apt-get install live-build

# Create a new project directory and navigate into it
mkdir live-build-project
cd live-build-project

# Configure the live-build project for Debian bookworm without a Debian installer
lb config --distribution bookworm --debian-installer none

# Create a directory for package lists
mkdir -p config/package-lists

# Add desired packages to the package list
cat <<EOL > config/package-lists/my.list.chroot
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
firmware-misc-nonfree
alsa-utils
EOL

# Create a directory for archives
mkdir -p config/archives

# Create a custom sources.list file
cat <<EOL > config/archives/my-sources.list.binary
deb http://deb.debian.org/debian/ bookworm main contrib non-free
deb-src http://deb.debian.org/debian/ bookworm main contrib non-free

deb http://security.debian.org/debian-security bookworm-security main contrib non-free
deb-src http://security.debian.org/debian-security bookworm-security main contrib non-free

deb http://deb.debian.org/debian/ bookworm-updates main contrib non-free
deb-src http://deb.debian.org/debian/ bookworm-updates main contrib non-free
EOL

# Create a preferences file (optional)
mkdir -p config/archives/my-preferences
cat <<EOL > config/archives/my-preferences/00-default.pref
Package: *
Pin: release o=Debian,a=stable
Pin-Priority: 500
EOL

# Create a directory for hooks
mkdir -p config/hooks/live

# Create a custom script hook (currently empty)
touch config/hooks/live/99-custom-script.chroot
chmod +x config/hooks/live/99-custom-script.chroot

# Build the live system
sudo lb build
