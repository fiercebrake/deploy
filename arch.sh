#!/bin/bash

sudo docker create --name arch --rm --tty --interactive --privileged -e PS1="ADC(\#)[\d \T:\w]\\$ " -p 0.0.0.0:80:80 -v /var/www/arch/data:/mnt archlinux:multilib-devel
sudo docker start arch

sudo docker exec arch pacman-key --init && pacman-key --populate
sudo docker exec arch pacman -Syu --needed --noconfirm git curl wget vim nginx sudo screen cronie openssh linux linux-headers
sudo docker exec arch ln -s /usr/bin/vim /usr/bin/vi
sudo docker exec arch bash -c "echo -e 'repo  ALL=(ALL:ALL) ALL\nrepo ALL=(ALL) NOPASSWD: ALL
' > /etc/sudoers.d/repo" 
sudo docker exec arch bash -c "useradd --system -s /usr/bin/nologin repo && usermod -aG wheel repo"
sudo docker exec arch bash -c "mkdir /home/repo && chown repo:repo /home/repo"
sudo docker exec arch sed -i 's|/usr/share/nginx/html|/mnt/tkg/repo|g' /etc/nginx/nginx.conf
sudo docker exec arch bash -c "git clone https://github.com/fiercebrake/tkg.git /mnt/tkg"
sudo docker exec arch bash -c "chown -R repo:repo /mnt/tkg/"
sudo docker exec arch bash -c "/usr/bin/nginx &"
sudo docker exec arch bash -c "chmod +x /mnt/tkg/linuxtkg.sh"
# sudo docker exec arch bash -c "cd /mnt/tkg/ && sudo -u repo ./linuxtkg.sh"
