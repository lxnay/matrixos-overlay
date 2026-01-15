# Copyright 2026 matrixOS
# Distributed under the terms of the GNU General Public License v2

EAPI=8

EGIT_REPO_URI="https://git.matrixos.org/matrixos.git"
EGIT_COMMIT="${P}"
inherit git-r3

DESCRIPTION="matrixOS themes and artwork for GNOME"
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
	dodir /usr/share/pixmaps
	insinto /usr/share/pixmaps
	cd "${S}"/artwork/matrixos-artwork-gnome/pixmaps || die
	doins *.svg

	dodir /usr/share/pixmaps/faces
	insinto /usr/share/pixmaps/faces
	cd "${S}"/artwork/matrixos-artwork-gnome/pixmaps/faces || die
	doins *.jpg

}
