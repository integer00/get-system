#!/bin/bash
#todo:
#add if/else statements
#add add control flow check
#add case for chroot/on place installing
#add choose menu for config : 1) default 2) macbook 2014 3)macbook 2011 etc

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
#!/bin/bash
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
#!/bin/bash
sudo pacman -Sy openssh stubby intel-ucode dmenu feh vim alsa-utils neofetch nmap smartmontools xorg-server xorg-xinit ttf-ubuntu-font-family ttf-bitstream-vera ttf-freefont ttf-liberation ttf-linux-libertine grub 

yaourt -Sy google-chrome termite i3-gaps compton polybar 

sudo mkdir /boot/grub
sudo grub-mkconfig > /boot/grub/grub.cfg

systemctl enable stubby

EOF

cat >> /mnt/home/integer/.xinitrc <<EOF
xrandr -S 1920x1080
xrandr --dpi 140

exec i3
EOF

echo "copy configs"
cp -rv ./.config ./.fonts ./Pictures ./b43 /mnt/home/integer

chown -R integer:integer /mnt/home/integer

chmod +x /mnt/home/integer/prepare.sh
chmod +x /mnt/home/integer/pkg.sh

echo "install stuff"
arch-chroot -u integer /mnt /home/integer/prepare.sh
arch-chroot -u integer /mnt /home/integer/pkg.sh

echo "set config files"

cat > /mnt/etc/stubby/stubby.yml << EOF

resolution_type: GETDNS_RESOLUTION_STUB

dns_transport_list:
  - GETDNS_TRANSPORT_TLS

tls_authentication: GETDNS_AUTHENTICATION_REQUIRED

tls_query_padding_blocksize: 128

edns_client_subnet_private : 1

round_robin_upstreams: 1

idle_timeout: 10000

listen_addresses:
  - 127.0.0.1
  - 0::1

appdata_dir: "/var/cache/stubby"

upstream_recursive_servers:
  - address_data: 1.1.1.1
    tls_auth_name: "cloudflare-dns.com"
  - address_data: 1.0.0.1
    tls_auth_name: "cloudflare-dns.com"
  - address_data: 2606:4700:4700::1111
    tls_auth_name: "cloudflare-dns.com"
  - address_data: 2606:4700:4700::1001
    tls_auth_name: "cloudflare-dns.com"
EOF

cat > /mnt/etc/resolv.conf <<EOF
nameserver localhost
EOF

cat > /mnt/etc/vconsole.conf <<EOF
FONT=sun12x22
EOF

cat >> /etc/systemd/logind.conf <<EOF
HandlePowerKey=ignore
EOF


echo "done"

