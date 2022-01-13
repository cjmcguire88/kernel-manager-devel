#!/usr/bin/env bash

#================================================================
# HEADER
#================================================================
#% SYNOPSIS
#+    kernel [-d] args ...
#%
#% DESCRIPTION
#% This script is called by the [-d] flag and other functions in
#% order to download the kernel version passed to it. It is a
#% modified version of the script provided by kernel.org. It will
#% get the Linux kernel tarball and cryptographically verify it,
#% retrieving the PGP keys using the Web Key Directory (WKD)
#% protocol if they are not already in the keyring.
#%
#% OPTIONS
#% Recieves kernel version as a parameter $1.
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

echo -e "\n\033[1;37mDownloading linux-${VERS}\033[0m"
VER=${1}
MAJOR="$(echo ${VER} | cut -d. -f1)"
if [[ ${MAJOR} -lt 3 ]]; then
    exoe "This script only supports kernel v3.x.x and above"
fi

if [[ ! -d ${BUILD_DIR} ]]; then
    exoe "${BUILD_DIR} does not exist"
fi

TARGET="${BUILD_DIR}/linux-${VER}.tar.xz"
# Do we already have this file?
if [[ -f ${TARGET} ]]; then
    echo "File ${BUILD_DIR}/linux-${VER}.tar.xz already exists."
    exit 0
fi

if [[ ! -x ${GPGBIN} ]]; then
    exoe "Could not find gpg in ${GPGBIN}"
fi
if [[ ! -x ${GPGVBIN} ]]; then
    exoe "Could not find gpgv in ${GPGVBIN}"
fi

TMPDIR=$(mktemp -d ${BUILD_DIR}/linux-tarball-verify.XXXXXXXXX.untrusted)
echo "Using TMPDIR=${TMPDIR}"
if [[ -z ${USEKEYRING} ]]; then
    if [[ -z ${GNUPGHOME} ]]; then
        GNUPGHOME="${TMPDIR}/gnupg"
    elif [[ ! -d ${GNUPGHOME} ]]; then
        echo "GNUPGHOME directory ${GNUPGHOME} does not exist"
        echo -n "Create it? [Y/n]"
        read YN
        if [[ ${YN} == 'n' ]]; then
            rm -rf ${TMPDIR}
            exoe "Exiting" 1
        fi
    fi
    mkdir -p -m 0700 ${GNUPGHOME}
    echo "Making sure we have all the necessary keys"
    ${GPGBIN} --batch --quiet \
        --homedir ${GNUPGHOME} \
        --auto-key-locate wkd \
        --locate-keys ${DEVKEYS} ${SHAKEYS}
    if [[ $? != "0" ]]; then
        rm -rf ${TMPDIR}
        exoe "Something went wrong fetching keys"
    fi
    USEKEYRING=${TMPDIR}/keyring.gpg
    ${GPGBIN} --batch --export ${DEVKEYS} ${SHAKEYS} > ${USEKEYRING}
fi
SHAKEYRING=${TMPDIR}/shakeyring.gpg
${GPGBIN} --batch \
    --no-default-keyring --keyring ${USEKEYRING} \
    --export ${SHAKEYS} > ${SHAKEYRING}
DEVKEYRING=${TMPDIR}/devkeyring.gpg
${GPGBIN} --batch \
    --no-default-keyring --keyring ${USEKEYRING} \
    --export ${DEVKEYS} > ${DEVKEYRING}

TXZ="$PROTO://cdn.kernel.org/pub/linux/kernel/v${MAJOR}.x/linux-${VER}.tar.xz"
SIG="$PROTO://cdn.kernel.org/pub/linux/kernel/v${MAJOR}.x/linux-${VER}.tar.sign"
SHA="$PROTO://www.kernel.org/pub/linux/kernel/v${MAJOR}.x/sha256sums.asc"

SHAFILE=${TMPDIR}/sha256sums.asc
echo "Downloading the checksums file for linux-${VER}"
case $DOWNLOADER in
    1)
        wget -q ${SHA} -P ${TMPDIR} || { rm -rf ${TMPDIR}; exoe "Failed to download the checksums file"; }
        ;;
    2)
        aria2c -q -x 3 -m 3 -d ${TMPDIR} ${SHA} || { rm -rf ${TMPDIR}; exoe "Failed to download the checksums file"; }
        ;;
    3)
        curl -sL -o ${SHAFILE} ${SHA} || { rm -rf ${TMPDIR}; exoe "Failed to download the checksums file"; }
        ;;
esac
echo "Verifying the checksums file"
COUNT=$(${GPGVBIN} --keyring=${SHAKEYRING} --status-fd=1 ${SHAFILE} \
        | grep -c -E '^\[GNUPG:\] (GOODSIG|VALIDSIG)')
if [[ ${COUNT} -lt 2 ]]; then
    rm -rf ${TMPDIR}
    exoe "FAILED to verify the sha256sums.asc file."
fi
SHACHECK=${TMPDIR}/sha256sums.txt
grep "linux-${VER}.tar.xz" ${SHAFILE} > ${SHACHECK}

echo
echo "Downloading the signature file for linux-${VER}"
SIGFILE=${TMPDIR}/linux-${VER}.tar.asc
case $DOWNLOADER in
    1)
        wget -q ${SIG} -O ${SIGFILE} || { rm -rf ${TMPDIR}; exoe "Failed to download the signature file"; }
        ;;
    2)
        aria2c -q -x 3 -m 3 -d ${TMPDIR} -o linux-${VER}.tar.asc ${SIG} || { rm -rf ${TMPDIR}; exoe "Failed to download the signature file"; }
        ;;
    3)
        curl -sL -o ${SIGFILE} ${SIG} || { rm -rf ${TMPDIR}; exoe "Failed to download the signature file"; }
        ;;
esac
echo "Downloading the XZ tarball for linux-${VER}"
TXZFILE=${TMPDIR}/linux-${VER}.tar.xz
case $DOWNLOADER in
    1)
        wget ${TXZ} -P ${TMPDIR} || { rm -rf ${TMPDIR}; exoe "Failed to download the tarball"; }
        ;;
    2)
        aria2c -x 3 -m 3 -d ${TMPDIR} ${TXZ} || { rm -rf ${TMPDIR}; exoe "Failed to download the tarball"; }
        ;;
    3)
        curl -sL -o ${TXZFILE} ${TXZ} || { rm -rf ${TMPDIR}; exoe "Failed to download the tarball"; }
        ;;
esac
pushd ${TMPDIR} >/dev/null
echo "Verifying checksum on linux-${VER}.tar.xz"
if ! ${SHA256SUMBIN} -c ${SHACHECK}; then
    popd >/dev/null
    rm -rf ${TMPDIR}
    exoe "FAILED to verify the downloaded tarball checksum"
fi
popd >/dev/null

echo
echo "Verifying developer signature on the tarball"
COUNT=$(${XZBIN} -cd ${TXZFILE} \
        | ${GPGVBIN} --keyring=${DEVKEYRING} --status-fd=1 ${SIGFILE} - \
        | grep -c -E '^\[GNUPG:\] (GOODSIG|VALIDSIG)')
if [[ ${COUNT} -lt 2 ]]; then
    rm -rf ${TMPDIR}
    exoe "FAILED to verify the tarball!"
fi
mv -f ${TXZFILE} ${TARGET}
rm -rf ${TMPDIR}
echo
echo "Successfully downloaded and verified ${TARGET}"
