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

PKG_URL="http://www.kernel.org/pub/linux/utils/boot/syslinux/"
PKG_ZIP="syslinux-6.00.tar.xz"
PKG_SUM=""

PKG_TAR="syslinux-6.00.tar"
PKG_DIR="syslinux-6.00"

return 0

# *****************************************************************************
# Remove any left-over previous build things.  Then untar loader source.
# *****************************************************************************

echo "=> Removing old build products, if any."
rm --force --recursive "extlinux"
rm --force --recursive "isolinux.bin"
rm --force --recursive "syslinux-6.00/"

if [[ $# -gt 0 && -n "$1" ]]; then
	# "$1" may be unbound so hide it in this if statement.
	[[ x"$1" == x"clean" ]] && return 0 || true
fi

echo "=> Untarring ..."
tar --extract --file="${CROSSLINUX_LOADER_DIR}/syslinux-6.00.tar.xz"


# *****************************************************************************
# Build syslinux
# *****************************************************************************

cp "syslinux-6.00/bios/extlinux/extlinux" extlinux
cp "syslinux-6.00/bios/core/isolinux.bin" isolinux.bin

echo "=> New files:"
ls --color -lh extlinux isolinux.bin || true


# *****************************************************************************
# Cleanup
# *****************************************************************************

rm --force --recursive "syslinux-6.00/"


# *****************************************************************************
# Exit OK
# *****************************************************************************

return 0


# end of file
