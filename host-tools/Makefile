# This file is part of the crosslinux software.
# The license which this software falls under is GPLv2 as follows:
#
# (C) 2013-2013 Douglas Jerome <djerome@crosslinux.org>
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


# *****************************************************************************
#
# FILE DESCRIPTION
#
#      This is the makefile used in making the host-resident tools used by
#      crosslinux build tool.
#
#      Conventions
#
#            Although the needed programs are known to exists, because
#            ./configure has successfully created this Makefile, use variables
#            such as $(install) for most all programs.  The reasons for this
#            are:
#            1) the path to the program may be unusual and ./configure has
#               found the path
#            2) to use the variables as they are set by ./configure, so when a
#               variable doesn't work then a needed program is found that is
#               not checked by ./configure.
#            The exceptions are the basic programs that a Linux system needs to
#            work, such as rm, rmdir, ls, cat, etc.  For any other programs
#            that could be not yet installed, or in an unusual path, use the
#            variables.
#
# CHANGE LOG
#
#      2013-07-01  drj  File creation.
#
# *****************************************************************************


# *************************************************************************** #
# Make MAKEFLAGS and Configuration                                            #
# *************************************************************************** #

# NOTICE (if this makefile need to re-invoke make on itself):
# GNU make 3.81 does not use MAKEFLAGS to set additional flags for the
# currently running make:  http://savannah.gnu.org/bugs/?20501
# The make manual says it should:
# http://www.gnu.org/software/make/manual/make.html#Options_002fRecursion

# Do not print directories as descend into or ascended from.
#
ifeq ($(filter --no-print-directory,$(MAKEFLAGS)),)
   CL_MAKEFLAGS += --no-print-directory
endif

MAKEFLAGS += $(CL_MAKEFLAGS)


# *************************************************************************** #
# Configuration Variables from ./configure                                    #
# *************************************************************************** #

export DATE            := 2013-07-01
export LOCAL           := no
export PACKAGE_TARNAME := crosslinux
export PACKAGE_VERSION := 0.0.1
export PROG_TXFORM     := s,x,x,

export awk             := /bin/awk
export bash            := /bin/bash
export bzip2           := /bin/bzip2
export find            := /bin/find
export grep            := /bin/grep -E
export gzip            := /bin/gzip
export install         := /bin/install
export ln              := /bin/ln
export make            := /bin/make
export sed             := /bin/sed
export tar             := /bin/tar
export wget            := /bin/wget
export xz              := /bin/xz

export prefix          := /home/djerome/crosslinux
export exec_prefix     := ${prefix}
export datarootdir     := ${prefix}/share
export bindir          := ${exec_prefix}/bin
export libdir          := ${exec_prefix}/lib/cl-bt.${PACKAGE_VERSION}
export docdir          := ${datarootdir}/doc/${PACKAGE_TARNAME}/cl-bt.${PACKAGE_VERSION}
export mandir          := ${datarootdir}/man


# *************************************************************************** #
# Make Variables and Default Rule                                             #
# *************************************************************************** #

export SHELL=/bin/bash

# GREP_OPTIONS=--color=always breaks the generated .in files, so clear it.
#
export GREP_OPTIONS=

FAKEROOT_URL := http://ftp.debian.org/debian/pool/main/f/fakeroot
FAKEROOT_ZIP := fakeroot_1.19.orig.tar.bz2
FAKEROOT_DIR := fakeroot-1.19

GENEXT2FS_URL := http://sourceforge.net/projects/genext2fs/files/genext2fs/1.4.1
GENEXT2FS_ZIP := genext2fs-1.4.1.tar.gz
GENEXT2FS_DIR := genext2fs-1.4.1

.PHONY:	default
default: Makefile build

# Make sure this makefile is up to date.
#
Makefile:	Makefile.in
	@echo "$< changed: you must re-run './configure'"
	@false


# *************************************************************************** #
# User Make Targets                                                           #
# *************************************************************************** #

.PHONY:	build clean install uninstall

build:	bld-prefix make-dirs get-tools make-fakeroot make-genext2fs bld-postfix

clean:
	@echo "RM    host-tools subdirectories"
	@rm --force --recursive bld
	@rm --force --recursive log

install:	build real-install

uninstall:	real-uninstall


# *************************************************************************** #
# Internal build Targets                                                      #
# *************************************************************************** #

.PHONY:	bld-prefix make-dirs get-tools make-fakeroot make-genext2fs bld-postfix

bld-prefix:
	@echo "========================="
	@echo "Start Making Host Tools  "
	@echo "========================="

bld-postfix:
	@echo "========================="
	@echo "Done Making Host Tools   "
	@echo "========================="

src/$(FAKEROOT_ZIP):
	@echo -n "=> Downloading $(FAKEROOT_ZIP) ..."
	@rm --force log/fakeroot-dl.log
	@if $(wget) -T 15 -nc --passive-ftp				\
		--progress=dot:binary --tries=3				\
		$(FAKEROOT_URL)/$(FAKEROOT_ZIP) >>log/fakeroot-dl.log 2>&1;\
	then								\
		echo " DONE";						\
		mv $(FAKEROOT_ZIP) src;					\
	else								\
		echo " ERROR";						\
		echo "***** Download failed";				\
		echo "***** See 'host-tools/log/fakeroot-dl.log'";	\
		exit 1;							\
	fi
	

src/$(GENEXT2FS_ZIP):
	@echo -n "=> Downloading $(GENEXT2FS_ZIP) ..."
	@rm --force log/genext2fs-dl.log
	@if $(wget) -T 15 -nc --passive-ftp				\
		--progress=dot:binary --tries=3				\
		$(GENEXT2FS_URL)/$(GENEXT2FS_ZIP) >>log/genext2fs-dl.log 2>&1;\
	then								\
		echo " DONE";						\
		mv $(GENEXT2FS_ZIP) src;				\
	else								\
		echo " ERROR";						\
		echo "***** Download failed";				\
		echo "***** See 'host-tools/log/genext2fs-dl.log'";	\
		exit 1;							\
	fi

log:
	@echo "=> Make host-tools/log directory"
	@mkdir --mode=0700 log

bld:
	@echo "=> Make host-tools/bld directory"
	@mkdir --mode=0700 bld

src:
	@echo "=> Make host-tools/src directory"
	@mkdir --mode=0700 src

make-dirs:	log bld src

get-tools:	src/$(FAKEROOT_ZIP) src/$(GENEXT2FS_ZIP)

make-fakeroot:
	@rm --force log/fakeroot-build.log
	@echo "=> Making fakeroot <="
	@echo "-> If error see log file 'host-tools/log/fakeroot-build.log'"
	@echo -n "-> Extracting $(FAKEROOT_ZIP) ... "
	@cd bld;							\
	if [ ! -d $(FAKEROOT_DIR) ]; then				\
		$(tar) --extract --file ../src/$(FAKEROOT_ZIP)		\
			>>../log/fakeroot-build.log 2>&1;		\
	fi
	@echo "DONE"
	@echo -n "-> ./configure fakeroot ... "
	@cd bld/$(FAKEROOT_DIR);					\
	./configure --prefix=$(libdir)/host-tools/usr			\
		>>../../log/fakeroot-build.log 2>&1
	@echo "DONE"
	@echo -n "-> Making fakeroot ... "
	@make -C bld/$(FAKEROOT_DIR) >>log/fakeroot-build.log 2>&1
	@echo "DONE"

make-genext2fs:
	@rm --force log/genext2fs-build.log
	@echo "=> Making genext2fs <="
	@echo "-> If error see log file 'host-tools/log/genext2fs-build.log'"
	@echo -n "-> Extracting $(GENEXT2FS_ZIP) ... "
	@cd bld;							\
	if [ ! -d $(GENEXT2FS_DIR) ]; then				\
		$(tar) --extract --file ../src/$(GENEXT2FS_ZIP)		\
			>>../log/genext2fs-build.log 2>&1;		\
	fi
	@echo "DONE"
	@echo -n "-> ./configure genext2fs ... "
	@cd bld/$(GENEXT2FS_DIR);					\
	./configure --prefix=$(libdir)/host-tools/usr			\
		>>../../log/genext2fs-build.log 2>&1
	@echo "DONE"
	@echo -n "-> Making genext2fs ... "
	@make -C bld/$(GENEXT2FS_DIR) >>log/genext2fs-build.log 2>&1
	@echo "DONE"


# *************************************************************************** #
# Internal install Targets                                                    #
# *************************************************************************** #

.PHONY: real-install

real-install:
	@echo "INST  fakeroot"
	@rm --force log/fakeroot-install.log
	@make -C bld/$(FAKEROOT_DIR) install >>log/fakeroot-install.log 2>&1
	@echo "INST  genext2fs"
	@rm --force log/genext2fs-install.log
	@make -C bld/$(GENEXT2FS_DIR) install >>log/genext2fs-install.log 2>&1


# *************************************************************************** #
# Internal uninstall Targets                                                  #
# *************************************************************************** #

.PHONY: real-uninstall

real-uninstall:
	@echo "RM    $(libdir)/host-tools contents"
	@rm --force --recursive $(libdir)/host-tools/*


# end of Makefile
