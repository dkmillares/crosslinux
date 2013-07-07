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

PKG_URL="http://ftp.gnu.org/gnu/bash/"
PKG_ZIP="bash-4.2.tar.gz"
PKG_SUM=""

PKG_TAR="bash-4.2.tar"
PKG_DIR="bash-4.2"


# ******************************************************************************
# pkg_patch
# ******************************************************************************

pkg_patch() {

local patchDir="${CROSSLINUX_PKGCFG_DIR}/$1/patch"
local patchFile=""

PKG_STATUS="patch error"

cd "${PKG_DIR}"
for patchFile in "${patchDir}"/*; do
	[[ -r "${patchFile}" ]] && patch -p0 <"${patchFile}"
done
cd ..

PKG_STATUS=""
return 0

}


# ******************************************************************************
# pkg_configure
# ******************************************************************************

pkg_configure() {

local TERMCAP_LIB="gnutermcap"

PKG_STATUS="./configure error"

cd "${PKG_DIR}"

if [[ x"${CONFIG_NCURSES_HAS_LIBS:-}" == x"y" ]]; then
	TERMCAP_LIB="libcurses"
fi

# ac_cv_func_setvbuf_reversed=no
# ac_cv_have_decl_sys_siglist=yes
# ac_cv_rl_prefix=path
# ac_cv_rl_version=6.2
# bash_cv_decl_under_sys_siglist=yes
# bash_cv_func_ctype_nonascii=yes
# bash_cv_func_sigsetjmp=present
# bash_cv_getcwd_malloc=yes
# bash_cv_job_control_missing=present
# bash_cv_printf_a_format=yes
# bash_cv_sys_named_pipes=present
# bash_cv_termcap_lib=libcurses
# bash_cv_ulimit_maxfds=yes
# bash_cv_unusable_rtsigs=no

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
bash_cv_job_control_missing=present \
bash_cv_printf_a_format=yes \
bash_cv_termcap_lib=${TERMCAP_LIB} \
./configure \
	--build=${MACHTYPE} \
	--host=${CONFIG_XTOOL_NAME} \
	--prefix=/usr \
	--enable-job-control \
	--disable-nls \
	--without-bash-malloc || return 0
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

PKG_STATUS="install error"

cd "${PKG_DIR}"
install --mode=755 --owner=0 --group=0 bash "${TARGET_SYSROOT_DIR}/bin"
rm --force "${TARGET_SYSROOT_DIR}/bin/sh"
ln --force --symbolic bash "${TARGET_SYSROOT_DIR}/bin/sh"
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
