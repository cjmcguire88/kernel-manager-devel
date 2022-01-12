#!/usr/bin/env bash

M_TIME=$(stat "$SRC_DIR"/linux-"$(uname -r)"/arch/x86_64/boot/bzImage | grep Modify: | awk -F " " '{print $2}')
KERNELS=$(ls "$KERNEL_DIR"/vmlinuz-linux*)
BACKUPS=$(ls "$SRC_DIR"/backups/*.tar.gz)
UKI=$(ls "$KERNEL_DIR"/*.efi)

echo -e "\033[1;37mKernel version: \033[1;32mlinux-$(uname -r)\033[0m"
echo -e "\033[1;37mKernel source directory:\033[0m $SRC_DIR/linux-$(uname -r)/"
echo -e "\033[1;37mCompiled on: \033[0m$M_TIME\n"
echo -e "\033[1;37mPatches applied:\033[0m\n$(ls "$SRC_DIR"/linux-"$(uname -r)"/patches/)\n"
echo -e "\033[1;37mInstalled kernels \033[0m($KERNEL_DIR)\033[1;37m:\033[0m"
printf '%s\n' "${KERNELS//$KERNEL_DIR\/vmlinuz-}"
if [[ -n $(ls "$KERNEL_DIR"/*.efi) ]]; then
    echo -e "\n\033[1;37mUnified Kernel Images \033[0m($KERNEL_DIR)\033[1;37m:\033[0m"
    printf '%s\n' "${UKI//$KERNEL_DIR\/}"
fi
if [[ -n $(ls "$SRC_DIR"/backups/) ]]; then
    echo -e "\n\033[1;37mKernel backups \033[0m($SRC_DIR/backups)\033[1;37m:\033[0m"
    printf '%s\n' "${BACKUPS//$SRC_DIR\/backups\/}"
fi
echo
echo "Run with -h to see options."
