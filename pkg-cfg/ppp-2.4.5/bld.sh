#!/bin/${cl_bash}


# This file is part of the crosslinux software.
# The license which this software falls under is GPLv2 as follows:
#
# Copyright (C) 2013-2013 Douglas Jerome <djerome@crosslinux.org>
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

PKG_URL="https://download.samba.org/pub/ppp/"
PKG_ZIP="ppp-2.4.5.tar.gz"
PKG_SUM=""

PKG_TAR="ppp-2.4.5.tar"
PKG_DIR="ppp-2.4.5"


# ******************************************************************************
# pkg_patch
# ******************************************************************************

pkg_patch() {

local patchDir="${CROSSLINUX_PKGCFG_DIR}/$1/patch"
local patchFile=""

PKG_STATUS="patch error"

cd "${PKG_DIR}" # ppp patches are applied above the dir.
for patchFile in "${patchDir}"/*; do
	[[ -r "${patchFile}" ]] && patch -p1 <"${patchFile}"
done
cd ..

PKG_STATUS=""
return 0

}


# ******************************************************************************
# pkg_configure
# ******************************************************************************

pkg_configure() {

PKG_STATUS="./configure error"

cd "${PKG_DIR}"
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
./configure \
	--build=${MACHTYPE} \
	--host=${CONFIG_XTOOL_NAME} \
	--prefix=/usr || return 0
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
	AR="${CONFIG_XTOOL_NAME}-ar" \
	CC="${CONFIG_XTOOL_NAME}-cc --sysroot=${TARGET_SYSROOT_DIR}" \
	COPTS="${CONFIG_CFLAGS}" \
	CROSS_COMPILE=${CONFIG_XTOOL_NAME}- || return 0
source "${CROSSLINUX_SCRIPT_DIR}/_xbt_env_clr"
cd ..

PKG_STATUS=""
return 0

}


# ******************************************************************************
# pkg_install
# ******************************************************************************

pkg_install() {

local instCmd="install --owner=0"

PKG_STATUS="install error"

cd "${PKG_DIR}"
source "${CROSSLINUX_SCRIPT_DIR}/_xbt_env_set"
${instCmd} --mode=755  --group=0  chat/chat "${TARGET_SYSROOT_DIR}/usr/sbin"
${instCmd} --mode=4550 --group=40 pppd/pppd "${TARGET_SYSROOT_DIR}/usr/sbin"
source "${CROSSLINUX_SCRIPT_DIR}/_xbt_env_clr"
cd ..

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
