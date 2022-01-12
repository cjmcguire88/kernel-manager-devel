#!/usr/bin/env bash

exoe() {
    echo -e "\033[1;31m${1}\033[0m" >&2
    exit 1
}

source /home/$SUDO_USER/.config/kernel/kernel.conf
k_path="$(dirname $(realpath $0 ))"

[[ "$1" =~ ^[0-9]+?\.{1}[0-9]+?\.{1}[0-9]+?-??[0-9a-zA-Z\-]*?$ ]] || exoe "Not a valid kernel version"
[[ "$1" =~ $(uname -r) ]] && exoe "${1} is the currently running kernel"
if [[ -d /usr/src/linux-${1} ]] && [[ ! -f $SRC_DIR/backups/${1}.tar.gz ]]; then
    read -n 1 -p $'\033[1;37mCreate backup of kernel source? \033[0m[y/N]: ' REPLY
    case ${REPLY:-N} in
        [yY])
            source $k_path/k_backup.sh "${1}"
            ;;
        *)
            echo -e "\nSkipping backup. (\033[1;31mKernel files will not be recoverable after deletion!\033[0m)"
            ;;
    esac
fi
echo -e "\n\033[1;33mThe following files and directories will be permanently deleted:\033[0m"
for file in "$KERNEL_DIR"/*"${1}"*; do
    [[ -e $file ]] || continue
    echo -e "$KERNEL_DIR/\033[0;31m$(echo "$file" | cut -d "/" -f3-)\033[0m"
    rmf+=( "$file" )
done
for file in "$SRC_DIR"/*"${1}"*; do
    [[ -e $file ]] || continue
    echo -e "$SRC_DIR/\033[0;31m$(echo "$file" | cut -d "/" -f4-)\033[0m"
    rmf+=( "$file" )
done
for file in /usr/lib/modules/*${1}*; do
    [[ -e $file ]] || continue
    echo -e "/usr/lib/modules/\033[0;31m$(echo "$file" | cut -d "/" -f5-)\033[0m"
    rmf+=( "$file" )
done
for file in /etc/mkinitcpio.d/*"${1}"*; do
    [[ -e $file ]] || continue
    echo -e "/etc/mkinitcpio.d/\033[0;31m$(echo "$file" | cut -d "/" -f4-)\033[0m"
    rmf+=( "$file" )
done
if [ ${#rmf[@]} -eq 0 ]; then
   exoe "No files to remove"
fi
[[ ! -f $SRC_DIR/backups/${1}.tar.gz ]] && echo -e "\n\033[0;31mNo backup exists!\033[0m"
read -n 1 -p $'\n\033[0;33mAre you sure?\033[0m [y/N]: ' REPLY
if [[ $REPLY =~ ^[Yy]$ ]]; then
    # Check for and remove any files containing specified kernel version in these directories
    for file in "${rmf[@]}"; do
        rm -rf "$file"
    done
    echo -e "\n\033[1;37mAll \033[0mlinux-${1}\033[1;37m kernel files removed from system.\033[0m"
    echo -e "\nBe sure to update the bootloader.\nGrub: \033[0;32msudo grub-mkconfig -o $KERNEL_DIR/grub/grub.cfg\033[0m\nSystemd-boot: Edit necessary config files."
else
    echo -e "\nNo files were deleted"
fi
