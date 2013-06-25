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

if [[ -f "${CROSSLINUX_PKGCFG_DIR}/$1/terminfo.src" ]]; then
	mv --verbose misc/terminfo.src misc/terminfo.src-ORIG
	cp --verbose ${CROSSLINUX_PKGCFG_DIR}/$1/terminfo.src misc/terminfo.src
fi

if [[ x"${CONFIG_BLD_NCURSES_WIDEC:-}" == x"y" ]]; then
	ENABLE_WIDEC="--enable-widec"
fi

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

# ****************************************************** #
#                                                        #
# This is the install results; it is not what I want.    #
#                                                        #
# sysroot/lib/libcurses.so -> libncurses.so.5.9*         #
# sysroot/lib/libform[w].so -> libform.so.5*             #
# sysroot/lib/libform[w].so.5 -> libform.so.5.9*         #
# sysroot/lib/libform[w].so.5.9*                         #
# sysroot/lib/libmenu[w].so -> libmenu.so.5*             #
# sysroot/lib/libmenu[w].so.5 -> libmenu.so.5.9*         #
# sysroot/lib/libmenu[w].so.5.9*                         #
# sysroot/lib/libncurses++[w].a                          #
# sysroot/lib/libncurses[w].so -> libncurses.so.5*       #
# sysroot/lib/libncurses[w].so.5 -> libncurses.so.5.9*   #
# sysroot/lib/libncurses[w].so.5.9*                      #
# sysroot/lib/libpanel[w].so -> libpanel.so.5*           #
# sysroot/lib/libpanel[w].so.5 -> libpanel.so.5.9*       #
# sysroot/lib/libpanel[w].so.5.9*                        #
#                                                        #
# sysroot/usr/bin/captoinfo -> tic*                      #
# sysroot/usr/bin/clear*                                 #
# sysroot/usr/bin/infocmp*                               #
# sysroot/usr/bin/infotocap -> tic*                      #
# sysroot/usr/bin/ncurses5-config*                       #
# sysroot/usr/bin/reset -> tset*                         #
# sysroot/usr/bin/tabs*                                  #
# sysroot/usr/bin/tic*                                   #
# sysroot/usr/bin/toe*                                   #
# sysroot/usr/bin/tput*                                  #
# sysroot/usr/bin/tset*                                  #
#                                                        #
# sysroot/usr/lib/terminfo -> ../share/terminfo/         #
#                                                        #
# ****************************************************** #

# Move any .a files from /lib to /usr/lib; there seems to be only one .a file:
# libncurses++[w].a
#
_sysroot="${TARGET_SYSROOT_DIR}"
for _file in ${_sysroot}/lib/libncurses++*.a; do
	if [[ -f "${_file}" ]]; then mv ${_file} ${_sysroot}/usr/lib/; fi
done; unset _file
unset _sysroot

_w=${CONFIG_BLD_NCURSES_WIDEC:+w} # Either "" or "w"
_usrlib="${TARGET_SYSROOT_DIR}/usr/lib"

# Many applications expect the linker to find non-wide character ncurses
# libraries; in /usr/lib make them link with /lib libraries by way of linker
# scripts.
#
for _lib in form menu ncurses panel ; do
	rm --force --verbose          ${_usrlib}/lib${_lib}.so
	echo "INPUT(-l${_lib}${_w})" >${_usrlib}/lib${_lib}.so
done; unset _lib

# Do something in /usr/lib about builds that look for -lcurses, -lcursesw and
# -ltinfo.
#
if [[ -n "${_w}" ]]; then
	rm --force --verbose      ${_usrlib}/libcursesw.so
	echo "INPUT(-lncursesw)" >${_usrlib}/libcursesw.so
fi
rm --force --verbose          ${_usrlib}/libcurses.so
echo "INPUT(-lncurses${_w})" >${_usrlib}/libcurses.so
ln --force --symbolic libncurses.so ${_usrlib}/libtinfo.so.5
ln --force --symbolic libtinfo.so.5 ${_usrlib}/libtinfo.so

unset _w
unset _usrlib

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
