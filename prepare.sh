#!/bin/bash
#todo:
#add if/else statements
#add add control flow check
if [[ $# -eq 0 ]] ; then
	echo "USAGE: set partition to install."
	echo ""
	exit 0
fi
useradd integer

mount $1 /mnt
pacstrap /mnt base base-devel git 
genfstab -U /mnt > /mnt/etc/fstab
echo "done installing system"

mkdir /mnt/home/integer

echo "adding user"
cat >> /mnt/etc/passwd <<EOF
integer:x:1000:1000::/home/integer:/bin/bash
EOF
cat >> /mnt/etc/group <<EOF
integer:x:1000:
EOF
cat >> /mnt/etc/shadow <<EOF
integer:\$6\$2hk72LazobUbRJtp\$mnJaFhAiDe8FULOG3yh32hTQwc4MUK.WijhGO0O/gP1Yfzg0wDkbt7.8R7B5.a04ICO1DWY36GPYexaOX1IyL/:17861:0:99999:7:::
EOF
cat >> /mnt/etc/sudoers <<EOF
integer ALL=(ALL) ALL
EOF

echo "prepare initial script"

cat > /mnt/home/integer/prepare.sh <<EOF
cd /tmp
git clone https://aur.archlinux.org/package-query.git
cd package-query
makepkg -si
cd /tmp
git clone https://aur.archlinux.org/yaourt.git
cd yaourt
makepkg -si
EOF

echo "prepare packets"
cat > /mnt/home/integer/pkg.sh <<EOF
sudo pacman -Sy intel-ucode dmenu feh vim alsa-utils neofetch nmap smartmontools xorg-server xorg-xinit ttf-ubuntu-font-family ttf-bitstream-vera ttf-freefont ttf-liberation ttf-linux-libertine grub 

yaourt -Sy google-chrome termite i3-gaps compton polybar 

sudo mkdir /boot/grub
sudo grub-mkconfig /boot/grub/grub.cfg
EOF

chown -R integer:integer /mnt/home/integer

chmod +x /mnt/home/integer/prepare.sh
chmod +x /mnt/home/integer/pkg.sh


cat >> /mnt/home/integer/.xinitrc <<EOF
exec i3
EOF

echo "copy configs"
cp -rv ./.config ./.fonts ./Pictures ./b43 /mnt/home/integer

echo "install stuff"
arch-chroot -u integer /mnt /home/integer/prepare.sh
arch-chroot -u integer /mnt /home/integer/pkg.sh
