#!/usr/bin/env bash

#================================================================
# HEADER
#================================================================
#% SYNOPSIS
#+    kernel [-a] args ...
#%
#% DESCRIPTION
#%
#% OPTIONS
#% Recieves kernel version-name as a parameter $1.
#%
#================================================================
#- IMPLEMENTATION
#-    version         custom-kernel-manager 1.0
#-    author          Jason McGuire
#-    copyright       None
#-    license         MIT
#-
#================================================================
# END_OF_HEADER
#================================================================

exoe() {
    echo -e "\033[1;31m${1}\033[0m" >&2
    exit 1
}

source /home/$SUDO_USER/.config/kernel/kernel.conf
k_path="$(dirname $(realpath $0 ))"

[[ ! -f $SRC_DIR/backups/${1}.tar.gz ]] && exoe "No backup file for ${1}"
echo -e "\033[1;37mRestoring \033[0;32mlinux-${1}\033[0m"
tar -xzf "$SRC_DIR"/backups/"${1}".tar.gz -C "$BUILD_DIR"/
sudo -i $k_path/k_install.sh "${1}" "$BUILD_DIR"
