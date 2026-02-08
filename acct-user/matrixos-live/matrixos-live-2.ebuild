# Copyright 2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="User for matrixOS"
KEYWORDS="amd64"
SLOT=0
S="${WORKDIR}"

src_install() {
	dodir /etc/sysusers.d
	insinto /etc/sysusers.d
	doins "${FILESDIR}/acct-user-matrix.conf"
}
