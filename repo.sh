#!/bin/bash


declare -a arr_packages=('onedrive-abraunegg' 'google-chrome' 'microsoft-edge-stable-bin' 'blesh-git' 'ocs-url' 'aic94xx-firmware' 'ast-firmware' \
	                 'wd719x-firmware' 'upd72020x-fw' 'laptop-mode-tools-git' 'schedtoold' 'zoom' 'ventoy-bin' 'visual-studio-code-bin' \
			 'proton-ge-custom-bin' 'teams-for-linux-bin' 'sound-theme-smooth' 'bitwarden-bin' 'pikaur' 'yubico-authenticator-bin' \
			 'bibata-cursor-theme-bin' 'flat-remix' 'kora-icon-theme' 'httpfs2-2gbplus' 'ttf-ms-win10-auto' 'libwireplumber-4.0-compat' \
			 'heroic-games-launcher' 'crossover' 'deezer'  'wps-office' 'omnissa-horizon-client' 'omnissa-horizon-file-association' \
			 'omnissa-horizon-html5mmr' 'omnissa-horizon-integrated-printing' 'omnissa-horizon-scanner-client' 'omnissa-horizon-serialport-client' \
			 'omnissa-horizon-usb' 'linux-tkg' 'linux-tkg-alk' 'nvidia-all' 'wine-tkg-git')

declare -a arr_config=('ntl' 'nvd' 'wne')

repo_dir='/home/repo/bash'



if ! ping -c 1 -W 2 'aur.archlinux.org' > /dev/null 2>&1; then
  /usr/bin/echo "### THE DOMAIN IS DOWN OR UNREACHABLE ###"
  exit 1
fi

/usr/bin/reflector --country 'United States' --latest 100 --sort rate --protocol https,ftp --age 24 --save /etc/pacman.d/mirrorlist

sudo pacman -Syu --noconfirm

/usr/bin/sudo -u repo /usr/bin/mkdir $repo_dir/repo/

function del_folder() {
  /usr/bin/sudo /usr/bin/rm -rf $repo_dir/$1
}


function get_folder() {
  if [[ $1 == 'linux-tkg' ]] || [[ $1 == 'nvidia-all' ]] || [[ $1 == 'wine-tkg-git' ]]; then
    domain='github.com/Frogging-Family'
  else
    domain='aur.archlinux.org'
  fi
  /usr/bin/sudo -u repo /usr/bin/git clone https://$domain/$1.git $repo_dir/$1
  if [[ $1 == 'linux-tkg-alk' ]]; then
    /usr/bin/sudo -u repo /usr/bin/git clone https://$domain/$1.git $repo_dir/linux-tkg-alk
  fi
}


function get_package() {
  folder=$1

  case $1 in
    linux-tkg)
      /usr/bin/cp $repo_dir/repo-$1.cfg $repo_dir/$1/customization.cfg
      ;;
    linux-tkg-alk)
      /usr/bin/cp $repo_dir/repo-$1.cfg $repo_dir/$1/customization.cfg
      ;;
    nvidia-all)
      /usr/bin/cp $repo_dir/repo-$1.cfg $repo_dir/$1/customization.cfg
      ;;
    wine-tkg-git)
      folder=$1/$1
      /usr/bin/cp $repo_dir/repo-$1.cfg $repo_dir/$1/$1/customization.cfg
      ;;
  esac
  
  /usr/bin/sudo -u repo /usr/bin/makepkg --needed --noconfirm --syncdeps --cleanbuild --clean --skippgpcheck --force --dir $repo_dir/$folder
  if [ $? -ne 0 ]; then
    echo "Error: Failed to create $1." > ./error.log
    # exit 1
  fi

  if [[ $1 == 'httpfs2-2gbplus' ]] || [[ $1 == 'libwireplumber-4.0-compat' ]] || [[ $1 == 'linux-tkg' ]]; then
    /usr/bin/sudo /usr/bin/pacman --needed --noconfirm -U $repo_dir/$1/*.pkg.tar.zst
  fi
}


function post_repo() {
  /usr/bin/mv -f $repo_dir/*/*.pkg.tar.zst $repo_dir/repo/
  /usr/bin/mv -f $repo_dir/*/*/*.pkg.tar.zst $repo_dir/repo/
  /usr/bin/rm -rf $repo_dir/repo/themis*
  sudo -u repo /usr/bin/repo-add -n -v $repo_dir/repo/themis.db.tar.gz $repo_dir/repo/*.pkg.tar.zst
}


for package in "${arr_packages[@]}";
do
  del_folder $package

  get_folder $package

  get_package $package
done

post_repo
