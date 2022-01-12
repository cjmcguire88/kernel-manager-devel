#!/usr/bin/env bash

echo -e "\n\033[1;37mRetrieving patches\033[0m"
mkdir patches
cd patches || exoe "patches directory missing"
case $DOWNLOADER in
    1)
        wget -i "$PATCH_DIR"/patchfile || exoe "No patchfile or patches directory"
        ls
        ;;
    2)
        aria2c -i "$PATCH_DIR"/patchfile || exoe "No patchfile or patches directory"
        ;;
    3)
        xargs -n 1 curl -O < "$PATCH_DIR"/patchfile
        ls
        ;;
esac
read -n 1 -p $'\033[1;37mAre these the correct patches \033[0m[Y/n]: ' REPLY
echo
[[ $REPLY =~ ^[Nn]$ ]] && exit
echo -e "\n\033[1;37mpatches -> \033[0m$(pwd)"
cd ../
