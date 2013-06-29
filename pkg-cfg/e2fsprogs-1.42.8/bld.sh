#!/bin/${cl_bash}


# This file is part of the crosslinux software.
# The license which this software falls under is GPLv2 as follows:
#
# Copyright (C) 2013-2013 Douglas Jerome <douglas@crosslinux.org>
#
# This program is free software; you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by the Free
# Software Foundation; either version 2 of the License, or (at your option)
# any later version.
#
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
# FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
# more details.
#
# You should have received a copy of the GNU General Public License along with
# this program; if not, write to the Free Software Foundation, Inc., 59 Temple
# Place, Suite 330, Boston, MA  02111-1307  USA


# ******************************************************************************
# Definitions
# ******************************************************************************

PKG_URL="http://sourceforge.net/projects/e2fsprogs/files/e2fsprogs/v1.42.8/"
PKG_ZIP="e2fsprogs-1.42.8.tar.gz"
PKG_SUM=""

PKG_TAR="e2fsprogs-1.42.8.tar"
PKG_DIR="e2fsprogs-1.42.8"


# ******************************************************************************
# pkg_patch
# ******************************************************************************

pkg_patch() {
PKG_STATUS=""
return 0
}


# ******************************************************************************
# pkg_configure
# ******************************************************************************

pkg_configure() {

local CONFIG_BLKID="--disable-libblkid"
local CROSSLINUX_LDFLAGS="-lblkid"

PKG_STATUS="./configure error"

cd "${PKG_DIR}"

if [[ x"${CONFIG_E2FSPROGS_HAS_BLKID:-}" == x"y" ]]; then
	CONFIG_BLKID="--enable-libblkid"
	CROSSLINUX_LDFLAGS=""
fi

# I don't remember why: "--disable-defrag" was needed for building for the
# WRTU54G-TM with uClibc.

source "${CROSSLINUX_SCRIPT_DIR}/_xbt_env_set"
PATH="${CONFIG_XTOOL_BIN_DIR}:${PATH}" \
AR="${CONFIG_XTOOL_NAME}-ar" \
AS="${CONFIG_XTOOL_NAME}-as --sysroot=${TARGET_SYSROOT_DIR}" \
CC="${CONFIG_XTOOL_NAME}-cc --sysroot=${TARGET_SYSROOT_DIR}" \
CXX="${CONFIG_XTOOL_NAME}-c++ --sysroot=${TARGET_SYSROOT_DIR}" \
LD="${CONFIG_XTOOL_NAME}-ld --sysroot=${TARGET_SYSROOT_DIR}" \
NM="${CONFIG_XTOOL_NAME}-nm" \
OBJCOPY="${CONFIG_XTOOL_NAME}-objcopy" \
RANLIB="${CONFIG_XTOOL_NAME}-ranlib" \
SIZE="${CONFIG_XTOOL_NAME}-size" \
STRIP="${CONFIG_XTOOL_NAME}-strip" \
CFLAGS="${CONFIG_CFLAGS}" \
LDFLAGS="${CROSSLINUX_LDFLAGS}" \
./configure \
	--build=${MACHTYPE} \
	--host=${CONFIG_XTOOL_NAME} \
	--prefix=/usr \
	--with-root-prefix="" \
	${CONFIG_BLKID} \
	--enable-defrag \
	--enable-fsck \
	--enable-libuuid \
	--enable-option-checking \
	--enable-rpath \
	--enable-tls \
	--enable-verbose-makecmds \
	--disable-blkid-debug \
	--disable-bsd-shlibs \
	--disable-checker \
	--disable-compression \
	--disable-debugfs \
	--disable-e2initrd-helper \
	--disable-elf-shlibs \
	--disable-imager \
	--disable-jbd-debug \
	--disable-maintainer-mode \
	--disable-nls \
	--disable-profile \
	--disable-resizer \
	--disable-testio-debug \
	--disable-uuidd || return 1
source "${CROSSLINUX_SCRIPT_DIR}/_xbt_env_clr"

cd ..

PKG_STATUS=""
return 0
}


# ******************************************************************************
# pkg_make
# ******************************************************************************

pkg_make() {

PKG_STATUS="make error"

cd "${PKG_DIR}"
source "${CROSSLINUX_SCRIPT_DIR}/_xbt_env_set"
PATH="${CONFIG_XTOOL_BIN_DIR}:${PATH}" make \
	--jobs=${NJOBS} \
	CROSS_COMPILE=${CONFIG_XTOOL_NAME}- || return 1
source "${CROSSLINUX_SCRIPT_DIR}/_xbt_env_clr"
cd ..

PKG_STATUS=""
return 0
}


# ******************************************************************************
# pkg_install
# ******************************************************************************

pkg_install() {

PKG_STATUS="install error"

# This will overwrite /sbin/findfs if it was installed from util-linux.  The
# reason this is not a problem is because the util-linux pkg-bin/ binary
# tarball has already been made.  But the wrongs findfs will be in sysroot; try
# to do something about it.

if [[ x"${CONFIG_E2FSPROGS_HAS_FINDFS}" == x"n" ]]; then
	mv "${TARGET_SYSROOT_DIR}/sbin/findfs" /tmp
fi

cd "${PKG_DIR}"
source "${CROSSLINUX_SCRIPT_DIR}/_xbt_env_set"
PATH="${CONFIG_XTOOL_BIN_DIR}:${PATH}" make \
	DESTDIR=${TARGET_SYSROOT_DIR} \
	install || return 1
PATH="${CONFIG_XTOOL_BIN_DIR}:${PATH}" make \
	DESTDIR=${TARGET_SYSROOT_DIR} \
	install-libs || return 1
source "${CROSSLINUX_SCRIPT_DIR}/_xbt_env_clr"
cd ..

if [[ x"${CONFIG_E2FSPROGS_HAS_FINDFS}" == x"n" ]]; then
	mv /tmp/findfs "${TARGET_SYSROOT_DIR}/sbin/"
fi

if [[ -d "rootfs/" ]]; then
	find "rootfs/" ! -type d -exec touch {} \;
	cp --archive --force rootfs/* "${TARGET_SYSROOT_DIR}"
fi

PKG_STATUS=""
return 0

}


# ******************************************************************************
# pkg_clean
# ******************************************************************************

pkg_clean() {
PKG_STATUS=""
return 0
}


# end of file
