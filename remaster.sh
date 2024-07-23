# Update sistem dan install live-build
sudo apt-get update
sudo apt-get install live-build

# Buat direktori kerja dan masuk ke dalamnya
mkdir live-build-project
cd live-build-project

# Konfigurasi live-build untuk Debian Bookworm dengan installer live
lb config --distribution bookworm --debian-installer live

# Buat direktori untuk daftar paket dan tambahkan paket yang diinginkan
mkdir -p config/package-lists
echo "i3" > config/package-lists/my.list.chroot
echo "lightdm" >> config/package-lists/my.list.chroot
echo "xserver-xorg" >> config/package-lists/my.list.chroot
echo "xinit" >> config/package-lists/my.list.chroot

# Buat direktori untuk hook script dan tambahkan script kustom
mkdir -p config/hooks/live
cat << 'EOF' > config/hooks/live/99-custom-script.chroot
#!/bin/bash
set -e

# Update package lists
apt-get update

# Install additional packages
apt-get install -y git

# Custom commands
echo "Custom script running in chroot environment"
EOF

# Buat script menjadi executable
chmod +x config/hooks/live/99-custom-script.chroot

# Bersihkan dan bangun ulang proyek live-build
sudo lb clean
sudo lb build
