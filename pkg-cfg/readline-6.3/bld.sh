#!/bin/${cl_bash}


# This file is part of the crosslinux software.
# The license which this software falls under is GPLv2 as follows:
#
# Copyright (C) 2014-2014 Douglas Jerome <djerome@crosslinux.org>
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

PKG_URL="http://ftp.gnu.org/gnu/readline/"
PKG_ZIP="readline-6.3.tar.gz"
PKG_SUM=""

PKG_TAR="readline-6.3.tar"
PKG_DIR="readline-6.3"


# ******************************************************************************
# pkg_patch
# ******************************************************************************

pkg_patch() {

PKG_STATUS="patch error"

cd "${PKG_DIR}"
sed -e '/MV.*old/d'  -i Makefile.in
sed -e '/OLDSUFF/c:' -i support/shlib-install
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
bash_cv_wcwidth_broken='no' \
./configure \
	--build=${MACHTYPE} \
	--host=${CONFIG_XTOOL_NAME} \
	--prefix=/usr \
	--libdir=/lib || return 0
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
NJOBS=1 # I think a multi-job build is not stable.
PATH="${CONFIG_XTOOL_BIN_DIR}:${PATH}" make \
	--jobs=${NJOBS} \
	CROSS_COMPILE=${CONFIG_XTOOL_NAME}- \
	SHLIB_LIBS=-lncurses || return 0
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

cd "${PKG_DIR}"

source "${CROSSLINUX_SCRIPT_DIR}/_xbt_env_set"
PATH="${CONFIG_XTOOL_BIN_DIR}:${PATH}" make \
	CROSS_COMPILE=${CONFIG_XTOOL_NAME}- \
	DESTDIR=${TARGET_SYSROOT_DIR} \
	install || return 0
source "${CROSSLINUX_SCRIPT_DIR}/_xbt_env_clr"

# Put static libraries into /usr/lib and give them the correct permissions.
#
mv ${TARGET_SYSROOT_DIR}/lib/libhistory.a  ${TARGET_SYSROOT_DIR}/usr/lib/
mv ${TARGET_SYSROOT_DIR}/lib/libreadline.a ${TARGET_SYSROOT_DIR}/usr/lib/

# Give the shared libraries the correct permissions and make links to them
# in /usr/lib.
#
chmod 755 ${TARGET_SYSROOT_DIR}/lib/libhistory.so.6.3
chmod 755 ${TARGET_SYSROOT_DIR}/lib/libreadline.so.6.3
rm -f ${TARGET_SYSROOT_DIR}/usr/lib/libhistory.so
rm -f ${TARGET_SYSROOT_DIR}/usr/lib/libreadline.so
ln -fs ../../lib/libhistory.so.6  ${TARGET_SYSROOT_DIR}/usr/lib/libhistory.so
ln -fs ../../lib/libreadline.so.6 ${TARGET_SYSROOT_DIR}/usr/lib/libreadline.so

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
