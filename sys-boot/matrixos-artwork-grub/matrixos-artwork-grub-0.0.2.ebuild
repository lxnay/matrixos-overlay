# Copyright 2026 matrixOS
# Distributed under the terms of the GNU General Public License v2

EAPI=8

EGIT_REPO_URI="https://git.matrixos.org/matrixos.git"
EGIT_COMMIT="${P}"
inherit git-r3

DESCRIPTION="matrixOS themes and artwork for GRUB"
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
	dodir /usr/share/grub/themes
	insinto /usr/share/grub/themes
	cd "${S}"/artwork/matrixos-artwork-grub/themes || die
	doins -r matrixos-theme
}
