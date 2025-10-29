#!/bin/bash


declare -a arr_comms=("git clone https://github.com/fiercebrake/tkg.git /mnt/tkg" \
                      "chown -R repo:repo /mnt/tkg/")


function get_image() {
git clone https://gitlab.archlinux.org/archlinux/archlinux-docker.git

sed -i 's|podman # or docker|docker # or podman|g' ./archlinux-docker/Makefile

sed -i 's|CMD\ \["/usr/bin/bash"\]||g' ./archlinux-docker/Dockerfile.template

cat << EOF >> ./archlinux-docker/Dockerfile.template
RUN pacman -Syu --noconfirm --needed bash ansible-core ansible-lint ansible python python-pip python-pipx python-passlib vim vim-vital \
                                     vim-tagbar vim-tabular vim-syntastic vim-supertab vim-spell-es vim-spell-en vim-nerdtree \
                                     vim-nerdcommenter vim-indent-object vim-gitgutter vim-devicons vim-ansible mlocate \
                                     bash-completion pkgfile rsync git wget reflector less libsecret gzip tar zlib xz openssh \
                                     openssl screen sudo bind inetutils whois p7zip sed fuse nginx curl ccid zenity wireplumber \
                                     udisks2 udftools fontforge gst-plugins-good samba opencl-headers libxpresent lib32-giflib \
                                     lib32-gnutls lib32-libxinerama lib32-libxcomposite lib32-libxmu lib32-v4l-utils lib32-libxslt \
                                     lib32-libpulse lib32-gtk3 lib32-gst-plugins-good lib32-sdl2 lib32-libcups lib32-ocl-icd \
                                     lib32-jack mingw-w64-gcc

RUN /bin/sh -c "sed -i 's|#en_US\.UTF-8 UTF-8|en_US\.UTF-8 UTF-8|g' /etc/locale.gen"

RUN /bin/sh -c "ln -sf /usr/share/zoneinfo/America/El_Salvador /etc/localtime"

RUN /bin/sh -c "/usr/bin/locale-gen"

RUN /bin/sh -c "echo -e 'repo  ALL=(ALL:ALL) ALL\nrepo ALL=(ALL) NOPASSWD: ALL' > /etc/sudoers.d/repo"

RUN /bin/sh -c "useradd --system -s /usr/bin/nologin repo && usermod -aG wheel repo"

RUN /bin/sh -c "mkdir /home/repo && chown repo:repo /home/repo"

RUN /bin/sh -c "sed -i 's|/home/repo/repo|g' /etc/nginx/nginx.conf"

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
    for command in "${arr_comms[@]}";
    do
      sudo docker exec arch $command
    done
    docker restart arch
}


get_image

run_image

post_conf

# sudo docker exec arch bash -c "chmod +x /mnt/tkg/linuxtkg.sh"
# sudo docker exec arch bash -c "cd /mnt/tkg/ && sudo -u repo ./linuxtkg.sh"
