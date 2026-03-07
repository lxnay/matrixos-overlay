# Copyright 2026 matrixOS
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="matrixOS sudoers config file"
HOMEPAGE="https://matrixos.org"

SRC_URI=""
S="${WORKDIR}"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64"
IUSE=""

src_install() {
	dodir /etc/sudoers.d
	insinto /etc/sudoers.d
	doins "${FILESDIR}/sudoers.d/50_matrixos"
}
