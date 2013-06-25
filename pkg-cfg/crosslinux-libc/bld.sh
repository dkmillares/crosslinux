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

PKG_URL="(cross-tools)"
PKG_ZIP="(none)"
PKG_SUM=""

PKG_TAR="(none)"
PKG_DIR="(none)"


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
PKG_STATUS=""
return 0
}


# ******************************************************************************
# pkg_make
# ******************************************************************************

pkg_make() {
PKG_STATUS=""
return 0
}


# ******************************************************************************
# pkg_install
# ******************************************************************************

pkg_install() {

local    srcdir="${CONFIG_XBT_SYSROOT_DIR}"
local    srcname=""
local    dstfile=""
local    dstpath=""
local -i pitchit=0

PKG_STATUS="install error"

CL_logcom "Copying cross-tool target components to sysroot."

# What a pain.  I want this:
# cp --no-dereference --recursive "${srcdir}"/* "${TARGET_SYSROOT_DIR}"
#
# But the source files may be read-only, and I do not want read-only files in
# the project sysroot.  Also, there may be some directory symlinks which I do
# not want.
#
# The following gyrations find all the non-directory files from the cross-tool
# chain sysroot, filters the directory symlinks, makes any needed directory
# path, copies the file to the project sysroot, then adds group and user write
# and execute permissions if the file is not a symlink.
#
${cl_find} "${srcdir}" ! -type d | while read srcname; do
	CL_logcom "~~~~~ ${srcname#${srcdir}/}"
	pitchit=0
	if [[ -L "${srcname}" ]]; then
		[[ -d "$(readlink -f ${srcname})" ]] && pitchit=1 || true
	fi
	if [[ ${pitchit} -eq 0 ]]; then
		dstfile="${TARGET_SYSROOT_DIR}/${srcname#${srcdir}/}"
		dstpath="${dstfile%/*}"
		if [[ ! -d "${dstpath}" ]]; then
			mkdir --mode=755 --parents --verbose "${dstpath}"
		fi
		cp --archive --verbose "${srcname}" "${dstpath}"
		[[ ! -L "${dstfile}" ]] && chmod gu+wx "${dstfile}" || true
	else
		CL_logcom "~~~~~ PITCH IT ^" # (directory symlink)
	fi
done

# Get the typical pkg-cfg rootfs/ files.
#
if [[ -d "rootfs/" ]]; then
	${cl_find} "rootfs/" ! -type d -exec touch {} \;
	cp --archive --force rootfs/* "${TARGET_SYSROOT_DIR}"
fi

local bf="etc/${CONFIG_BRAND_NAME}-build"
local tf="etc/${CONFIG_BRAND_NAME}-target"
CL_logcom "Recording build information in the target:"
CL_logcom "=> /${bf}"
CL_logcom "=> /${tf}"
rm --force "${TARGET_SYSROOT_DIR}/${bf}"
rm --force "${TARGET_SYSROOT_DIR}/${tf}"
echo "${MACHTYPE}"        >"${TARGET_SYSROOT_DIR}/${bf}"
echo "${CONFIG_XBT_NAME}" >"${TARGET_SYSROOT_DIR}/${tf}"

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
