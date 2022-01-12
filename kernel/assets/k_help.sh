#!/usr/bin/env bash

echo -e "Usage: kernel [-flag] [OPTIONAL_ARG]"
echo -e "Author: Jason McGuire"
echo -e "Custom kernel maintenance.\n"
echo -e "-d   Downloads specified kernel version to $SRC_DIR (Requires kernel version as argument.)"
echo -e "-i   Download, compile and install the kernel version passed as an argument."
echo -e "-b   Create a .tar.gz archive of the kernel source directory. (Requires kernel version as argument.)"
echo -e "-m   Modify kernel config and optionally recompile and install kernel (Requires kernel version as argument.)"
echo -e "-r   Remove a kernel from system. (Requires kernel version as argument.)"
echo -e "-a   Restore a kernel that was previously archived. (Requires kernel version as argument.)"
echo -e "-c   View the kernel changelog for the version passed as an argument."
echo -e "-p   Dump a directory containing the patches listed in patchfile given (used for testing)."
echo -e "-u   Update the current kernel to the latest stable on kernel.org."
echo -e "-n   Create a new kernel. Choose between stable and LTS."
echo -e "-h   Show this dialogue."
