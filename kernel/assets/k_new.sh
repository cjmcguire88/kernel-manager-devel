#!/usr/bin/env bash

#================================================================
# HEADER
#================================================================
#% SYNOPSIS
#+    kernel [-n]
#%
#% DESCRIPTION
#% This script is called by the [-n] flag. It retrieves the
#% finger_banner from kernel.org and parses it for the newest
#% kernel versions. It will list them in a menu and once a choice
#% is made it will pass the version chosen to K_prepare for
#% for compilation.
#%
#% OPTIONS
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

case $DOWNLOADER in
    1)
        wget -P "$RUN_DIR" "$PROTO"://www.kernel.org/finger_banner > /dev/null 2>&1
        ;;
    2)
        aria2c -q -x 3 -m 3 -d "$RUN_DIR" "$PROTO"://www.kernel.org/finger_banner > /dev/null 2>&1
        ;;
    3)
        curl -o "$RUN_DIR"/finger_banner "$PROTO"://www.kernel.org/finger_banner > /dev/null 2>&1
        ;;
esac
KERNEL=($(awk '{print $3}' "$RUN_DIR"/finger_banner))
VERSION=($(awk '{print $NF}' "$RUN_DIR"/finger_banner))
rm "$RUN_DIR"/finger_banner*
PS3=$'\033[1;32mSelect kernel version: \033[0m'
echo -e "\n\033[1;37mNewest versions from \033[1;34mwww.kernel.org\033[0m\n"
select KERN in $(for i in $(seq 0 "$((${#KERNEL[@]}-1))"); do echo "${KERNEL[i]}--${VERSION[i]}"; done); do
    KERNV=$(awk -F '--' '{print $2}' <<< "$KERN")
    source "$k_path"/assets/k_prepare.sh "$KERNV" && exit 0
done
