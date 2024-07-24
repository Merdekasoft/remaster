
sudo apt-get update
sudo apt-get install live-build
mkdir live-build-project
cd live-build-project
lb config --distribution bookworm --debian-installer none
mkdir -p config/package-lists
echo "i3" > config/package-lists/my.list.chroot
echo "lightdm" >> config/package-lists/my.list.chroot
echo "xserver-xorg" >> config/package-lists/my.list.chroot
echo "xinit" >> config/package-lists/my.list.chroot
echo "git" >> config/package-lists/my.list.chroot
echo "mc" >> config/package-lists/my.list.chroot
echo "htop" >> config/package-lists/my.list.chroot
echo "slick-greeter" >> config/package-lists/my.list.chroot
echo "calamares" >> config/package-lists/my.list.chroot
echo "calamares-settings-debian" >> config/package-lists/my.list.chroot
echo "rxvt-unicode" >> config/package-lists/my.list.chroot
echo "rxvt-unicode-256color" >> config/package-lists/my.list.chroot
echo "rxvt-unicode-terminfo" >> config/package-lists/my.list.chroot

mkdir -p config/hooks/live
touch config/hooks/live/99-custom-script.chroot
chmod +x config/hooks/live/99-custom-script.chroot

sudo lb build
