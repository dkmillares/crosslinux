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

PKG_URL="http://ftp.gnu.org/gnu/ncurses/"
PKG_ZIP="ncurses-5.9.tar.gz"
PKG_SUM=""

PKG_TAR="ncurses-5.9.tar"
PKG_DIR="ncurses-5.9"


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

local ENABLE_WIDEC=""

PKG_STATUS="./configure error"

cd "${PKG_DIR}"

if [[ x"${CONFIG_BLD_NCURSES_WIDEC:-}" == x"y" ]]; then
	ENABLE_WIDEC="--enable-widec"
fi

mv -v misc/terminfo.src misc/terminfo.src-ORIG
cp -v ${CROSSLINUX_PKGCFG_DIR}/$1/terminfo.src misc/terminfo.src

PATH="${CONFIG_XBT_DIR}:${PATH}" \
AR="${CONFIG_XBT_NAME}-ar" \
AS="${CONFIG_XBT_NAME}-as --sysroot=${TARGET_SYSROOT_DIR}" \
CC="${CONFIG_XBT_NAME}-cc --sysroot=${TARGET_SYSROOT_DIR}" \
CXX="${CONFIG_XBT_NAME}-c++ --sysroot=${TARGET_SYSROOT_DIR}" \
LD="${CONFIG_XBT_NAME}-ld --sysroot=${TARGET_SYSROOT_DIR}" \
NM="${CONFIG_XBT_NAME}-nm" \
OBJCOPY="${CONFIG_XBT_NAME}-objcopy" \
RANLIB="${CONFIG_XBT_NAME}-ranlib" \
SIZE="${CONFIG_XBT_NAME}-size" \
STRIP="${CONFIG_XBT_NAME}-strip" \
CFLAGS="${CONFIG_CFLAGS}" \
./configure \
	--build=${MACHTYPE} \
	--host=${CONFIG_XBT_NAME} \
	--prefix=/usr \
	--libdir=/lib \
	--mandir=/usr/share/man \
	--enable-shared \
	--enable-overwrite \
	${ENABLE_WIDEC} \
	--disable-largefile \
	--disable-termcap \
	--with-build-cc=gcc \
	--with-install-prefix=${TARGET_SYSROOT_DIR} \
	--with-shared \
	--without-ada \
	--without-debug \
	--without-gpm \
	--without-normal || return 1

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
PATH="${CONFIG_XBT_DIR}:${PATH}" make \
	--jobs=${NJOBS} \
	CROSS_COMPILE=${CONFIG_XBT_NAME}- || return 1
cd ..

PKG_STATUS=""
return 0

}


# ******************************************************************************
# pkg_install
# ******************************************************************************

pkg_install() {

PKG_STATUS="install error"

cd "${PKG_DIR}"
PATH="${CONFIG_XBT_DIR}:${PATH}" make install || return 1
cd ..

if [[ -d "rootfs/" ]]; then
	${cl_find} "rootfs/" ! -type d -exec touch {} \;
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
