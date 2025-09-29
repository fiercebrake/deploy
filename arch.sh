#!/bin/bash

function get_image() {
git clone https://gitlab.archlinux.org/archlinux/archlinux-docker.git

sed -i 's|podman # or docker|docker # or podman|g' ./archlinux-docker/Makefile

sed -i 's|CMD\ \["/usr/bin/bash"\]||g' ./archlinux-docker/Dockerfile.template

cat << EOF >> ./archlinux-docker/Dockerfile.template
RUN pacman -Syu --noconfirm --needed ansible-core ansible-lint ansible python python-pip python-pipx python-passlib \
                                     vim vim-vital vim-tagbar vim-tabular vim-syntastic vim-supertab vim-spell-es \
                                     vim-spell-en vim-nerdtree vim-nerdcommenter vim-indent-object vim-gitgutter \
                                     vim-devicons vim-ansible mlocate bash-completion pkgfile rsync git wget \
                                     reflector less libsecret gzip tar zlib xz openssh openssl sudo bind inetutils \
                                     whois nginx curl nginx screen ccid zenity wireplumber udisks2 p7zip udftools sed
ENTRYPOINT ["/usr/bin/nginx", "-g", "daemon off;"]        
EOF

cd ./archlinux-docker/ && sudo make image-multilib-devel

cd ../ && sudo rm -rf ./archlinux-docker/
}


function run_image() {
    sudo docker run -d --name arch \
                    --net dockers --ip 192.168.75.13 \
                    -v /var/www/arch/data:/mnt \
                    archlinux/archlinux:multilib-devel
}


function post_conf() {
    sudo docker exec arch mv /usr/bin/vi /usr/bin/vi-bak
    sudo docker exec arch ln -s /usr/bin/vim /usr/bin/vi
    sudo docker exec arch bash -c "echo -e 'repo  ALL=(ALL:ALL) ALL\nrepo ALL=(ALL) NOPASSWD: ALL
    ' > /etc/sudoers.d/repo" 
    sudo docker exec arch bash -c "useradd --system -s /usr/bin/nologin repo && usermod -aG wheel repo"
    sudo docker exec arch bash -c "mkdir /home/repo && chown repo:repo /home/repo"
    sudo docker exec arch sed -i 's|/usr/share/nginx/html|/mnt/tkg/repo|g' /etc/nginx/nginx.conf
    sudo docker exec arch bash -c "git clone https://github.com/fiercebrake/tkg.git /mnt/tkg"
    sudo docker exec arch bash -c "chown -R repo:repo /mnt/tkg/"
    sudo docker restart arch
}


get_image

run_image

post_conf

# sudo docker exec arch bash -c "chmod +x /mnt/tkg/linuxtkg.sh"
# sudo docker exec arch bash -c "cd /mnt/tkg/ && sudo -u repo ./linuxtkg.sh"
