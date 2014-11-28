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

PKG_URL="ftp://ftp.alsa-project.org/pub/lib/"
PKG_ZIP="alsa-lib-1.0.28.tar.bz2"
PKG_SUM=""

PKG_TAR="alsa-lib-1.0.28.tar"
PKG_DIR="alsa-lib-1.0.28"


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

PKG_STATUS="./configure error"

cd "${PKG_DIR}"

source "${CROSSLINUX_SCRIPT_DIR}/_xbt_env_set"
PATH="${CONFIG_XTOOL_BIN_DIR}:${PATH}" \
HOSTCC=gcc \
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
	--target=${CONFIG_XTOOL_NAME} \
	--disable-python || return 0
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

#cd "${PKG_DIR}"
#source "${CROSSLINUX_SCRIPT_DIR}/_xbt_env_set"
#PATH="${CONFIG_XTOOL_BIN_DIR}:${PATH}" make \
#	CROSS_COMPILE=${CONFIG_XTOOL_NAME}- \
#	DESTDIR=${TARGET_SYSROOT_DIR} \
#	install || return 0
#source "${CROSSLINUX_SCRIPT_DIR}/_xbt_env_clr"
#cd ..

cd "${PKG_DIR}/include"
source "${CROSSLINUX_SCRIPT_DIR}/_xbt_env_set"
PATH="${CONFIG_XTOOL_BIN_DIR}:${PATH}" make \
	CROSS_COMPILE=${CONFIG_XTOOL_NAME}- \
	DESTDIR=${TARGET_SYSROOT_DIR} \
	install || return 0
source "${CROSSLINUX_SCRIPT_DIR}/_xbt_env_clr"
cd ../..

cd "${PKG_DIR}"
_inst="install --owner=root --group=root"
_dest="${TARGET_SYSROOT_DIR}"
_modlibdir="modules/mixer/simple/.libs"
_carddir="/usr/share/alsa/cards"
_pcmdir="/usr/share/alsa/pcm"
${_inst} -m 755 -d				\
	${_dest}/usr/lib/alsa-lib/smixer	\
	${_dest}/usr/share/alsa/alsa.conf.d	\
	${_dest}${_carddir}			\
	${_dest}${_carddir}/SI7018		\
	${_dest}${_pcmdir}
${_inst} -m 755 aserver/aserver               ${_dest}/usr/bin
${_inst} -m 755 ${_modlibdir}/smixer-sbase.so ${_dest}/usr/lib/alsa-lib/smixer
${_inst} -m 755 ${_modlibdir}/smixer-ac97.so  ${_dest}/usr/lib/alsa-lib/smixer
${_inst} -m 755 ${_modlibdir}/smixer-hda.so   ${_dest}/usr/lib/alsa-lib/smixer
${_inst} -m 755 src/.libs/libasound.so        ${_dest}/usr/lib
${_inst} -m 755 src/.libs/libasound.so.2      ${_dest}/usr/lib
${_inst} -m 755 src/.libs/libasound.so.2.0.0  ${_dest}/usr/lib
${_inst} -m 644 src/conf/alsa.conf          ${_dest}/usr/share/alsa
${_inst} -m 644 src/conf/alsa.conf.d/README ${_dest}/usr/share/alsa/alsa.conf.d
${_inst} -m 644 src/conf/cards/AACI.conf                ${_dest}${_carddir}
${_inst} -m 644 src/conf/cards/ATIIXP-MODEM.conf        ${_dest}${_carddir}
${_inst} -m 644 src/conf/cards/ATIIXP-SPDMA.conf        ${_dest}${_carddir}
${_inst} -m 644 src/conf/cards/ATIIXP.conf              ${_dest}${_carddir}
${_inst} -m 644 src/conf/cards/AU8810.conf              ${_dest}${_carddir}
${_inst} -m 644 src/conf/cards/AU8820.conf              ${_dest}${_carddir}
${_inst} -m 644 src/conf/cards/AU8830.conf              ${_dest}${_carddir}
${_inst} -m 644 src/conf/cards/Audigy.conf              ${_dest}${_carddir}
${_inst} -m 644 src/conf/cards/Audigy2.conf             ${_dest}${_carddir}
${_inst} -m 644 src/conf/cards/Aureon51.conf            ${_dest}${_carddir}
${_inst} -m 644 src/conf/cards/Aureon71.conf            ${_dest}${_carddir}
${_inst} -m 644 src/conf/cards/CA0106.conf              ${_dest}${_carddir}
${_inst} -m 644 src/conf/cards/CMI8338-SWIEC.conf       ${_dest}${_carddir}
${_inst} -m 644 src/conf/cards/CMI8338.conf             ${_dest}${_carddir}
${_inst} -m 644 src/conf/cards/CMI8738-MC6.conf         ${_dest}${_carddir}
${_inst} -m 644 src/conf/cards/CMI8738-MC8.conf         ${_dest}${_carddir}
${_inst} -m 644 src/conf/cards/CMI8788.conf             ${_dest}${_carddir}
${_inst} -m 644 src/conf/cards/CS46xx.conf              ${_dest}${_carddir}
${_inst} -m 644 src/conf/cards/EMU10K1.conf             ${_dest}${_carddir}
${_inst} -m 644 src/conf/cards/EMU10K1X.conf            ${_dest}${_carddir}
${_inst} -m 644 src/conf/cards/ENS1370.conf             ${_dest}${_carddir}
${_inst} -m 644 src/conf/cards/ENS1371.conf             ${_dest}${_carddir}
${_inst} -m 644 src/conf/cards/ES1968.conf              ${_dest}${_carddir}
${_inst} -m 644 src/conf/cards/FM801.conf               ${_dest}${_carddir}
${_inst} -m 644 src/conf/cards/FWSpeakers.conf          ${_dest}${_carddir}
${_inst} -m 644 src/conf/cards/FireWave.conf            ${_dest}${_carddir}
${_inst} -m 644 src/conf/cards/GUS.conf                 ${_dest}${_carddir}
${_inst} -m 644 src/conf/cards/HDA-Intel.conf           ${_dest}${_carddir}
${_inst} -m 644 src/conf/cards/ICE1712.conf             ${_dest}${_carddir}
${_inst} -m 644 src/conf/cards/ICE1724.conf             ${_dest}${_carddir}
${_inst} -m 644 src/conf/cards/ICH-MODEM.conf           ${_dest}${_carddir}
${_inst} -m 644 src/conf/cards/ICH.conf                 ${_dest}${_carddir}
${_inst} -m 644 src/conf/cards/ICH4.conf                ${_dest}${_carddir}
${_inst} -m 644 src/conf/cards/Maestro3.conf            ${_dest}${_carddir}
${_inst} -m 644 src/conf/cards/NFORCE.conf              ${_dest}${_carddir}
${_inst} -m 644 src/conf/cards/PC-Speaker.conf          ${_dest}${_carddir}
${_inst} -m 644 src/conf/cards/PMac.conf                ${_dest}${_carddir}
${_inst} -m 644 src/conf/cards/PMacToonie.conf          ${_dest}${_carddir}
${_inst} -m 644 src/conf/cards/PS3.conf                 ${_dest}${_carddir}
${_inst} -m 644 src/conf/cards/RME9636.conf             ${_dest}${_carddir}
${_inst} -m 644 src/conf/cards/RME9652.conf             ${_dest}${_carddir}
${_inst} -m 644 src/conf/cards/SB-XFi.conf              ${_dest}${_carddir}
${_inst} -m 644 src/conf/cards/SI7018.conf              ${_dest}${_carddir}
${_inst} -m 644 src/conf/cards/SI7018/sndoc-mixer.alisp ${_dest}${_carddir}/SI7018
${_inst} -m 644 src/conf/cards/SI7018/sndop-mixer.alisp ${_dest}${_carddir}/SI7018
${_inst} -m 644 src/conf/cards/TRID4DWAVENX.conf        ${_dest}${_carddir}
${_inst} -m 644 src/conf/cards/USB-Audio.conf           ${_dest}${_carddir}
${_inst} -m 644 src/conf/cards/VIA686A.conf             ${_dest}${_carddir}
${_inst} -m 644 src/conf/cards/VIA8233.conf             ${_dest}${_carddir}
${_inst} -m 644 src/conf/cards/VIA8233A.conf            ${_dest}${_carddir}
${_inst} -m 644 src/conf/cards/VIA8237.conf             ${_dest}${_carddir}
${_inst} -m 644 src/conf/cards/VX222.conf               ${_dest}${_carddir}
${_inst} -m 644 src/conf/cards/VXPocket.conf            ${_dest}${_carddir}
${_inst} -m 644 src/conf/cards/VXPocket440.conf         ${_dest}${_carddir}
${_inst} -m 644 src/conf/cards/YMF744.conf              ${_dest}${_carddir}
${_inst} -m 644 src/conf/cards/aliases.alisp            ${_dest}${_carddir}
${_inst} -m 644 src/conf/cards/aliases.conf             ${_dest}${_carddir}
${_inst} -m 644 src/conf/pcm/center_lfe.conf  ${_dest}${_pcmdir}
${_inst} -m 644 src/conf/pcm/default.conf     ${_dest}${_pcmdir}
${_inst} -m 644 src/conf/pcm/dmix.conf        ${_dest}${_pcmdir}
${_inst} -m 644 src/conf/pcm/dpl.conf         ${_dest}${_pcmdir}
${_inst} -m 644 src/conf/pcm/dsnoop.conf      ${_dest}${_pcmdir}
${_inst} -m 644 src/conf/pcm/front.conf       ${_dest}${_pcmdir}
${_inst} -m 644 src/conf/pcm/hdmi.conf        ${_dest}${_pcmdir}
${_inst} -m 644 src/conf/pcm/iec958.conf      ${_dest}${_pcmdir}
${_inst} -m 644 src/conf/pcm/modem.conf       ${_dest}${_pcmdir}
${_inst} -m 644 src/conf/pcm/rear.conf        ${_dest}${_pcmdir}
${_inst} -m 644 src/conf/pcm/side.conf        ${_dest}${_pcmdir}
${_inst} -m 644 src/conf/pcm/surround40.conf  ${_dest}${_pcmdir}
${_inst} -m 644 src/conf/pcm/surround41.conf  ${_dest}${_pcmdir}
${_inst} -m 644 src/conf/pcm/surround50.conf  ${_dest}${_pcmdir}
${_inst} -m 644 src/conf/pcm/surround51.conf  ${_dest}${_pcmdir}
${_inst} -m 644 src/conf/pcm/surround71.conf  ${_dest}${_pcmdir}
${_inst} -m 644 src/conf/smixer.conf      ${_dest}/usr/share/alsa
${_inst} -m 644 src/conf/sndo-mixer.alisp ${_dest}/usr/share/alsa
unset _inst
unset _dest
unset _modlibdir
unset _carddir
unset _pcmdir
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
