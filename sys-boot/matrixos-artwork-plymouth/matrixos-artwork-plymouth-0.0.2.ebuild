# Copyright 2026 matrixOS
# Distributed under the terms of the GNU General Public License v2

EAPI=8

EGIT_REPO_URI="https://github.com/lxnay/matrixos-artwork.git"
EGIT_COMMIT="${P}"
inherit git-r3

DESCRIPTION="matrixOS themes and artwork for Plymouth"
HOMEPAGE="https://www.matrixos.org"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64"
IUSE=""
RESTRICT="binchecks strip"

src_unpack() {
	git-r3_src_unpack
}

src_install() {
	dodir /usr/share/plymouth
	insinto /usr/share/plymouth
	cd "${S}"/${PN}/ || die
	newins matrixos-logo-150x150.png bizcom.png
}
