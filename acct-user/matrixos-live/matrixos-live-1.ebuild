# Copyright 2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit acct-user

DESCRIPTION="User for matrixOS"

ACCT_USER_ID=1000
ACCT_USER_NAME=matrix
ACCT_USER_COMMENT="matrixOS"
ACCT_USER_SHELL=/bin/bash
ACCT_USER_HOME=/home/matrix
ACCT_USER_GROUPS=( users wheel disk docker floppy audio video render usb kvm plugdev pipewire )

acct-user_add_deps
