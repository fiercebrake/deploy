#!/bin/bash


declare -a arr_packages=('onedrive-abraunegg' 'google-chrome' 'microsoft-edge-stable-bin' 'blesh-git' 'ocs-url' 'aic94xx-firmware' \
                         'ast-firmware' 'wd719x-firmware' 'upd72020x-fw' 'laptop-mode-tools-git' 'schedtoold' 'zoom' 'ventoy-bin' \
                         'visual-studio-code-bin' 'proton-ge-custom-bin' 'teams-for-linux-bin' 'sound-theme-smooth' \
                         'networkmanager-ssh' 'bitwarden-bin' 'pikaur' 'yubico-authenticator-bin' 'bibata-cursor-theme-bin' \
                         'flat-remix' 'kora-icon-theme' 'httpfs2-2gbplus' 'ttf-ms-win10-auto' 'libwireplumber-4.0-compat' 'pwvucontrol' \
			 'heroic-games-launcher' 'crossover' 'deezer' 'brave-bin' 'microsoft-edge-dev-bin' 'linux-tkg' 'nvidia-all' 'wine-tkg-git')

declare -a arr_config=('ntl' 'nvd' 'wne')


if ! ping -c 1 -W 2 'aur.archlinux.org' > /dev/null 2>&1; then
  /usr/bin/echo "### THE DOMAIN IS DOWN OR UNREACHABLE ###"
  exit 1
fi

/usr/bin/sudo -u repo /usr/bin/mkdir /mnt/tkg/repo

function del_folder() {
  /usr/bin/sudo /usr/bin/rm -rf /mnt/tkg/$1
}


function get_folder() {
  if [[ $1 == 'linux-tkg' ]] || [[ $1 == 'nvidia-all' ]] || [[ $1 == 'wine-tkg-git' ]]; then
    domain='github.com/Frogging-Family'
  else
    domain='aur.archlinux.org'
  fi
  /usr/bin/sudo -u repo /usr/bin/git clone https://$domain/$1.git /mnt/tkg/$1
}


function get_package() {
  folder=$1

  case $1 in
    linux-tkg)
      /usr/bin/cp /mnt/tkg/customization-$1.cfg /mnt/tkg/$1/customization.cfg
      ;;
    nvidia-all)
      /usr/bin/cp /mnt/tkg/customization-$1.cfg /mnt/tkg/$1/customization.cfg
      ;;
    wine-tkg-git)
      folder=$1/$1
      /usr/bin/cp /mnt/tkg/customization-$1.cfg /mnt/tkg/$1/$1/customization.cfg
      ;;
  esac
  
  /usr/bin/sudo -u repo /usr/bin/makepkg --needed --noconfirm --syncdeps --cleanbuild --clean --skippgpcheck --force --dir /mnt/tkg/$folder
  if [ $? -ne 0 ]; then
    echo "Error: Failed to create $1." > ./error.log
    # exit 1
  fi

  if [[ $1 == 'httpfs2-2gbplus' ]] || [[ $1 == 'libwireplumber-4.0-compat' ]] || [[ $1 == 'linux-tkg' ]]; then
    /usr/bin/sudo /usr/bin/pacman --needed --noconfirm -U /mnt/tkg/$1/*.pkg.tar.zst
  fi

  /usr/bin/mv -f /mnt/tkg/$folder/*.pkg.tar.zst /mnt/tkg/repo
}


function post_repo() {
  /usr/bin/rm -rf /mnt/tkg/repo/themis*
  /usr/bin/repo-add -n -v /mnt/tkg/repo/themis.db.tar.gz /mnt/tkg/repo/*.pkg.tar.zst
}


for package in "${arr_packages[@]}";
do
  del_folder $package

  get_folder $package

  get_package $package
done

post_repo
