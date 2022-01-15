#!/usr/bin/env bash

#================================================================
# HEADER
#================================================================
#% SYNOPSIS
#+    kernel [-h]
#%
#% DESCRIPTION
#% This script is called by the [-h] flag and displays a help
#% menu with a list of options.
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

cat <<EOF
Usage: kernel [-flag] [OPTIONAL_ARG]
Author: Jason McGuire
Custom kernel maintenance.

-d)   Downloads specified kernel version to $BUILD_DIR (Requires kernel version as argument.)

-i)   Download, compile and install the kernel version passed as an argument.

-b)   Create a .tar.gz archive of the kernel source directory. (Requires kernel version as argument.)

-m)   Modify kernel config and optionally recompile and install kernel (Requires kernel version as argument.)

-r)   Remove a kernel from system. (Requires kernel version as argument.)

-a)   Restore a kernel that was previously archived. (Requires kernel version as argument.)

-c)   View the kernel changelog for the version passed as an argument.

-p)   Dump a directory containing the patches listed in patchfile given (used for testing).

-u)   Update the current kernel to the latest stable on kernel.org.

-n)   Create a new kernel. Select from a menu of the newest kernels on kernel.org

-h)   Show this dialogue.
EOF
