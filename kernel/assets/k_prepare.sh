#!/usr/bin/env bash

VERS="$1"
MAJ_VER="${1:0:1}"

if [[ $(echo "${VERS}" | awk -F "." '{print NF}') -lt 3 ]]; then
    MVERS=${VERS}.0
else
    MVERS=${VERS}
fi
[[ "$VERS" =~ ^[0-9]+\.[0-9]+\.?[0-9]*$ ]] || exoe "Not a valid kernel version"
cd "$BUILD_DIR" || exoe "$BUILD_DIR not found"
if [[ -f $BUILD_DIR/linux-${VERS}.tar.xz ]]; then
    echo -e "\n\033[1;37mlinux-${VERS}.tar.xz already exists. Skipping download.\033[0m\n"
else
    source $k_path/assets/k_download.sh "$VERS"
fi
echo -e "\033[1;37mUnpacking tarball\033[0m"
tar -xJf linux-"${VERS}".tar.xz
read -r -p $'\033[1;37mEnter kernel name (eg linux-'"${MVERS}"$'-\033[1;32mNAME\033[1;37m): \033[0m' NAME
echo -e "\n\033[1;37mKernel name set to \033[1;32mlinux-${MVERS}-$NAME\033[0m"
read -r -p $'\n\033[1;37mIs kernel name correct?\033[0m: ' REPLY
if [[ $REPLY =~ ^[Nn]$ ]]; then
    read -r -p $'\n\033[1;37mEnter kernel name (eg linux-'"${MVERS}"$'-\033[1;32mNAME\033[1;37m): \033[0m' NAME
    echo -e "\n\033[1;37mKernel name set to \033[1;32mlinux-${MVERS}-$NAME\033[0m"
fi
mv linux-"${VERS}" linux-"${MVERS}-$NAME"
cd linux-"${MVERS}-$NAME" || exoe "Missing kernel directory"
read -n 1 -p $'\n\033[1;37mPatch the kernel? \033[0m[Y/n]: ' REPLY
echo
case ${REPLY:-Y} in
    [Yy])
        if [[ -d $PATCH_DIR/patches ]]; then
            cp -rv "$PATCH_DIR"/patches "$BUILD_DIR"/linux-"${MVERS}-$NAME"/
            echo
        else
            source $k_path/assets/k_patch.sh || exoe "Failed to retrieve patches"
        fi
        echo -e "\n\033[1;37mPatching Kernel\033[0m"
        for i in patches/*; do
            echo -e "\033[1;37mApplying: \033[1;32m${i//patches\/}\033[0m"; patch -p1 < "$i"; echo
        done || exoe "Patching failed"
        ;;
    *)
        echo "skipping"
        ;;
esac
echo -e "\n\033[1;37mEditing Makefile\033[0m\n"
sed -i "s/^EXTRAVERSION =.*$/& -$NAME/g" Makefile
echo -e "\033[1;37mUnlocking -O3 optimization level\033[0m"
sed -i '/bool "Optimize more for performance (-O3)"/{n;d}' init/Kconfig
read -n 1 -p $'\n\033[1;37mCopy config from currently running kernel? \033[0m[Y/n]: ' REPLY
echo
case ${REPLY:-Y} in
    [Yy])
        echo -e "\n\033[1;37mGenerating kernel config\033[0m"
        zcat /proc/config.gz > ./.config || cp -v "$SRC_DIR"/linux-"$(uname -r)"/.config ./
        make oldconfig || exoe "Failed to generate config"
        read -n 1 -p $'\n\033[1;37mOpen kernel configuration menu? \033[0m[y/N]: ' REPLY
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            oldSum=$(md5sum .config)
            make "$KERNEL_MENU"
            newSum=$(md5sum .config)
            if [[ $oldSum != "$newSum" ]]; then
                [[ ! -d $HOME/.config/kernel/configs/"$(date +"%Y-%m-%d")" ]] && mkdir -p $HOME/.config/kernel/configs/"$(date +"%Y-%m-%d")"
                diff .config.old .config > $HOME/.config/kernel/configs/"$(date +"%Y-%m-%d")"/"${1}-$(date | awk '{print $4}')".diff
            fi
        fi
        ;;
    *)
        echo -e "\n\033[0;32m
        localmodconfig creates a config based on current config and loaded
        modules (lsmod). Disables any module option that is not needed for
        the loadedmodules. You can plug in everything that you'll be using
        on the machine and it will load all needed modules for all devices
        it detects. Or enable any needed modules for devices not currently
        connected in the configuration menu.\033[0m"
        read -n 1 -p $'\n\033[1;37mRun make localmodconfig before opening configuration menu?\033[0m[y/N]: ' REPLY
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            make localmodconfig
        fi
        echo -e "\033[1;37mOpening kernel configuration menu.\033[0m"
        make "$KERNEL_MENU"
        ;;
esac
echo -e "\033[1;37mCompiling ${1}\033[0m"
make -j$(($(nproc) - $(nproc) / 4)) || exoe "Compilation failed"
sudo -i $k_path/assets/k_install.sh "${MVERS}-${NAME}" "$BUILD_DIR"