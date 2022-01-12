#!/usr/bin/env bash

exoe() {
    echo -e "\033[1;31m${1}\033[0m" >&2
    exit 1
}

k_path="$(dirname $(realpath $0 ))"
# This is the "main portal" to the above functions.
main() {
    source $HOME/.config/kernel/kernel.conf
    while getopts ':d:i:b:m:r:a:c:punh' flag; do
        case "${flag}" in
            d)
                source $k_path/assets/k_download.sh "${OPTARG}"; exit
                ;;
            i)
                source $k_path/assets/k_prepare.sh "${OPTARG}"; exit
                ;;
            b)
                sudo -i $k_path/assets/k_backup.sh "${OPTARG}"; exit
                ;;
            m)
                sudo -i $k_path/assets/k_modify.sh "${OPTARG}"; exit
                ;;
            r)
                sudo -i $k_path/assets/k_remove.sh "${OPTARG}"; exit
                ;;
            a)
                sudo -i $k_path/assets/k_restore.sh "${OPTARG}"; exit
                ;;
            c)
                source $k_path/assets/k_cl.sh "${OPTARG}"; exit
                ;;
            p)
                source $k_path/assets/k_patch.sh; exit
                ;;
            u)
                source $k_path/assets/k_update.sh; exit
                ;;
            n)
                source $k_path/assets/k_new.sh; exit
                ;;
            h)
                source $k_path/assets/k_help.sh; exit
                ;;
            :)
                exoe "Requires argument:\033[0m see -h"
                ;;
            *)
                exoe "Invalid Usage:\033[0m see -h"
                ;;
        esac
    done
    source $k_path/assets/k_info.sh
}
# Since this script requires root privileges for most of its
# operations, this function ensures that it has root privileges
# Then it checks if the config file exists before proceeding to
# main.
#if [ "$EUID" -ne 0 ]; then
#    exoe "Must be run as root"
if [[ ! -f $HOME/.config/kernel/kernel.conf ]]; then
    exoe "Can't find configuration file."
else
    main "$@"
fi
