#!/usr/bin/env bash

#================================================================
# HEADER
#================================================================
#% SYNOPSIS
#+    kernel [-m] args ...
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

[[ "$1" =~ $(uname -r) ]] && exoe "${1} is the currently running kernel"
cp -rv "$SRC_DIR"/linux-"$1" "$BUILD_DIR"/
cd "$BUILD_DIR"/linux-"${1}" || exoe "${1} not found"
read -n 1 -p $'\033[1;37mCreate backup of kernel source? \033[0m[y/N]: ' REPLY
if [[ ${REPLY:-N} =~ ^[Yy]$ ]]; then
    sudo -i $k_path/assets/k_backup.sh "${1}"
fi
oldSum=$(md5sum .config)
make "$KERNEL_MENU"
newSum=$(md5sum .config)
if [[ $oldSum != "$newSum" ]]; then
    [[ ! -d "$HOME"/.config/kernel/configs/"$(date +"%Y-%m-%d")" ]] && mkdir -p "$HOME"/.config/kernel/configs/"$(date +"%Y-%m-%d")"
    diff .config.old .config > $HOME/.config/kernel/configs/"$(date +"%Y-%m-%d")"/"${1}-$(date | awk '{print $4}')".diff
    read -n 1 -p $'\n\033[1;37mRecompile and install? \033[0m[y/N]: ' REPLY
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        make clean
        make -j$(($(nproc) - $(nproc) / 4)) || exoe "Compilation failed"
        sudo -i $k_path/assets/k_install.sh "${1}"
    fi
else
    echo -e "\033[1;37mNo changes were made. Exiting\033[0m"
    exit
fi
