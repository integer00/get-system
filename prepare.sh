#!/bin/bash

if [[ $# -eq 0 ]] ; then
	echo "USAGE: set partition to install."
	echo ""
	exit 0
fi

mount $1 /mnt
#pacstrap /mnt base base-devel git 
#genfstab -U /mnt > /mnt/etc/fstab
echo "done"

echo "prepare initial script"
cat > /mnt/prepare.sh <<EOF
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
cat > /mnt/pkg.sh <<EOF
pacman -S vim intel-ucode alsa-utils neofetch nmap smartmontools xorg-server xorg-xinit ttf-bitstream-vera ttf-freefont ttf-liberation ttf-linux-libertine grub --noconfirm
yaourt -S termite --noconfirm
EOF


chmod +x /mnt/prepare.sh
chmod +x /mnt/pkg.sh

chown integer:integer /mnt/temp.sh
chown integer:integer /mnt/pkg.sh

cat >> /mnt/etc/passwd <<EOF
integer:x:1000:1000::/home/integer:/bin/bash
EOF
cat >> /mnt/etc/group <<EOF
integer:x:1000:
EOF
cat >> /mnt/etc/shadow <<EOF
integer:$6$2hk72LazobUbRJtp$mnJaFhAiDe8FULOG3yh32hTQwc4MUK.WijhGO0O/gP1Yfzg0wDkbt7.8R7B5.a04ICO1DWY36GPYexaOX1IyL/:17861:0:99999:7:::
EOF
cat >> /mnt/etc/sudoers <<EOF
integer ALL=(ALL) ALL
EOF

mkdir /mnt/home/integer
chown -R integer:integer /mnt/home/integer

arch-chroot -u integer /mnt /prepare.sh
arch-chroot -u integer /mnt /pkg.sh
